defmodule Cherry.ServeTest do
  use ExUnit.Case

  # Serve tests share the fixture copy and a real TCP port; not async.

  alias Cherry.Serve.Reloader

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)

  @moduletag timeout: 30_000

  # Not ExUnit's :tmp_dir — that lives on the project mount, where inotify
  # events do not fire inside the devcontainer. The OS tmp dir is native.
  setup context do
    if context[:no_server] do
      # The degraded-mode test starts its own serve tree; a second one in
      # the same process would collide on the named reloader registry.
      :ok
    else
      start_shared_server()
    end
  end

  defp start_shared_server do
    tmp = Path.join(System.tmp_dir!(), "cherry-serve-#{System.unique_integer([:positive])}")
    File.mkdir_p!(tmp)
    on_exit(fn -> File.rm_rf!(tmp) end)

    site = Path.join(tmp, "site")
    File.cp_r!(@fixture, site)
    File.rm_rf!(Path.join(site, "expected"))

    {:ok, _pid, port} =
      Cherry.Serve.start(source: site, output: Path.join(site, "_site"), port: 0)

    Application.ensure_all_started(:inets)
    {:ok, site: site, port: port}
  end

  test "serves built pages with the livereload client injected", %{port: port} do
    {200, body} = get(port, "/hello-world/")

    assert body =~ "Hello, world"
    assert body =~ "__cherry/reload"

    # Assets come through with sensible types; drafts are included in serve mode.
    {200, css} = get(port, "/assets/site.css")
    assert css =~ "--color-accent"

    {200, _draft} = get(port, "/secret-draft/")
  end

  test "unknown paths serve the themed 404 with status 404", %{port: port} do
    {404, body} = get(port, "/no-such-page/")
    assert body =~ "Page not found"
  end

  test "path traversal is refused", %{port: port} do
    {status, _body} = get(port, "/../cherry.exs")
    assert status in [400, 404]
  end

  test "editing a post rebuilds and broadcasts a reload", %{site: site, port: port} do
    Reloader.subscribe()

    post = Path.join(site, "content/posts/2026-01-15-hello-world.md")
    edited = String.replace(File.read!(post), "Hello, world", "Hello, rebuilt world")

    # Retry the write: the recursive watch may still be establishing when
    # the test starts, and a write before that is invisible to inotify.
    reloaded? =
      Enum.find_value(1..10, fn attempt ->
        File.write!(post, edited <> "\n<!-- attempt #{attempt} -->\n")

        receive do
          :cherry_reload -> true
        after
          1_000 -> nil
        end
      end)

    assert reloaded?, "no reload broadcast after 10 edits"

    {200, body} = get(port, "/hello-world/")
    assert body =~ "Hello, rebuilt world"
  end

  test "a broken edit keeps the last good output serving", %{site: site, port: port} do
    Reloader.subscribe()

    about = Path.join(site, "content/pages/about.md")
    File.write!(about, "---\ndescription: no title\n---\nBroken.\n")

    # No reload broadcast for a failed build; the old page still serves.
    refute_receive :cherry_reload, 2_000
    {200, body} = get(port, "/about/")
    assert body =~ "About"
  end

  describe "without a watcher backend" do
    @tag :no_server
    test "serve degrades to no live reload and still serves" do
      tmp = Path.join(System.tmp_dir!(), "cherry-nowatch-#{System.unique_integer([:positive])}")
      site = Path.join(tmp, "site")
      File.mkdir_p!(site)
      on_exit(fn -> File.rm_rf!(tmp) end)
      File.cp_r!(@fixture, site)
      File.rm_rf!(Path.join(site, "expected"))

      # Simulate the backend-unavailable branch (inotify-tools missing);
      # file_system's real check cannot be forced portably from a test.
      Application.put_env(:cherry, :fs_watcher_start, fn _opts -> :ignore end)
      on_exit(fn -> Application.delete_env(:cherry, :fs_watcher_start) end)

      {result, stderr} =
        ExUnit.CaptureIO.with_io(:stderr, fn ->
          Cherry.Serve.start(source: site, output: Path.join(site, "_site"), port: 0)
        end)

      assert {:ok, pid, port} = result
      refute Cherry.Serve.live_reload?(pid)
      assert stderr =~ "live reload disabled"

      # The server itself is untouched by the missing watcher.
      {200, body} = get(port, "/hello-world/")
      assert body =~ "Hello, world"

      Supervisor.stop(pid)
    end
  end

  defp get(port, path) do
    url = ~c"http://localhost:#{port}#{path}"

    {:ok, {{_http, status, _reason}, _headers, body}} =
      :httpc.request(:get, {url, []}, [], body_format: :binary)

    {status, body}
  end
end
