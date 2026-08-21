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

    {:ok, _pid, port, ""} =
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

  test "answers on IPv6 loopback — localhost must not stall on ::1-first hosts", %{port: port} do
    case :gen_tcp.connect({0, 0, 0, 0, 0, 0, 0, 1}, port, [:binary, active: false], 1_000) do
      {:ok, socket} ->
        request = "GET /hello-world/ HTTP/1.1\r\nhost: localhost\r\nconnection: close\r\n\r\n"
        :ok = :gen_tcp.send(socket, request)
        {:ok, response} = :gen_tcp.recv(socket, 0, 5_000)
        :gen_tcp.close(socket)

        assert response =~ "HTTP/1.1 200"

      # A host without IPv6 at all exercises the IPv4-only fallback
      # instead; nothing to prove here.
      {:error, reason} when reason in [:eafnosupport, :enetunreach, :eaddrnotavail] ->
        :ok
    end
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

      assert {:ok, pid, port, _base} = result
      refute Cherry.Serve.live_reload?(pid)
      assert stderr =~ "live reload disabled"

      # The server itself is untouched by the missing watcher.
      {200, body} = get(port, "/hello-world/")
      assert body =~ "Hello, world"

      Supervisor.stop(pid)
    end
  end

  describe "with a watcher that sees nothing" do
    @tag :no_server
    test "serve degrades rather than promising a reload that never comes" do
      tmp = Path.join(System.tmp_dir!(), "cherry-blindfs-#{System.unique_integer([:positive])}")
      site = Path.join(tmp, "site")
      File.mkdir_p!(site)
      on_exit(fn -> File.rm_rf!(tmp) end)
      File.cp_r!(@fixture, site)
      File.rm_rf!(Path.join(site, "expected"))

      # A zero-length probe window is a filesystem that never delivers:
      # the watcher starts, and no event can arrive in time. This is what
      # a Docker bind mount does for real, on every edit.
      Application.put_env(:cherry, :fs_probe_timeout, 0)
      on_exit(fn -> Application.delete_env(:cherry, :fs_probe_timeout) end)

      {result, stderr} =
        ExUnit.CaptureIO.with_io(:stderr, fn ->
          Cherry.Serve.start(source: site, output: Path.join(site, "_site"), port: 0)
        end)

      assert {:ok, pid, port, _base} = result
      refute Cherry.Serve.live_reload?(pid)
      assert stderr =~ "delivers no change events"

      {200, body} = get(port, "/hello-world/")
      assert body =~ "Hello, world"

      refute File.exists?(Path.join([site, "content", "posts", ".cherry-live-probe"])),
             "the probe file must not survive the check"

      Supervisor.stop(pid)
    end
  end

  describe "with --verbose" do
    @tag :no_server
    test "every request logs method, path, status, and duration" do
      tmp = Path.join(System.tmp_dir!(), "cherry-verbose-#{System.unique_integer([:positive])}")
      site = Path.join(tmp, "site")
      File.mkdir_p!(site)
      on_exit(fn -> File.rm_rf!(tmp) end)
      File.cp_r!(@fixture, site)
      File.rm_rf!(Path.join(site, "expected"))

      # The tree starts inside the capture so the request-handler
      # processes inherit the captured group leader.
      output =
        ExUnit.CaptureIO.capture_io(fn ->
          {:ok, pid, port, _base} =
            Cherry.Serve.start(
              source: site,
              output: Path.join(site, "_site"),
              port: 0,
              verbose: true
            )

          Application.ensure_all_started(:inets)
          {200, _body} = get(port, "/hello-world/")
          {404, _body} = get(port, "/no-such-page/")

          Supervisor.stop(pid)
        end)

      assert output =~ ~r"GET /hello-world/ → 200 \d"
      assert output =~ ~r"GET /no-such-page/ → 404 \d"
    end
  end

  describe "with a base_path" do
    @tag :no_server
    test "the site serves under its prefix, exactly as production will" do
      tmp = Path.join(System.tmp_dir!(), "cherry-basepath-#{System.unique_integer([:positive])}")
      site = Path.join(tmp, "site")
      File.mkdir_p!(site)
      on_exit(fn -> File.rm_rf!(tmp) end)
      File.cp_r!(@fixture, site)
      File.rm_rf!(Path.join(site, "expected"))

      config = Path.join(site, "cherry.exs")

      File.write!(
        config,
        String.replace(File.read!(config), "[\n", "[\n  base_path: \"/blog\",\n")
      )

      {:ok, pid, port, base} =
        Cherry.Serve.start(source: site, output: Path.join(site, "_site"), port: 0)

      assert base == "/blog"
      Application.ensure_all_started(:inets)

      # Pages and assets answer under the prefix, livereload included.
      {200, body} = get(port, "/blog/hello-world/")
      assert body =~ "Hello, world"
      assert body =~ "__cherry/reload"
      {200, css} = get(port, "/blog/assets/site.css")
      assert css =~ "--color-accent"

      # The bare root redirects to the prefix rather than 404ing.
      assert {302, "/blog/"} = get_redirect(port, "/")

      # An unprefixed path that would 404 on the real host 404s here too —
      # exactly the hardcoded-root-link bug this mirroring exists to catch.
      {404, _body} = get(port, "/hello-world/")

      Supervisor.stop(pid)
    end
  end

  # The shared server proves the healthy path: "editing a post rebuilds"
  # above cannot pass unless the probe accepted this filesystem.
  test "the probe that proves live reload leaves nothing behind", %{site: site} do
    refute File.exists?(Path.join([site, "content", "posts", ".cherry-live-probe"]))
  end

  defp get(port, path) do
    url = ~c"http://localhost:#{port}#{path}"

    {:ok, {{_http, status, _reason}, _headers, body}} =
      :httpc.request(:get, {url, []}, [], body_format: :binary)

    {status, body}
  end

  # httpc follows redirects by default; this asks it not to, so a 302
  # and its location can be asserted directly.
  defp get_redirect(port, path) do
    url = ~c"http://localhost:#{port}#{path}"

    {:ok, {{_http, status, _reason}, headers, _body}} =
      :httpc.request(:get, {url, []}, [autoredirect: false], body_format: :binary)

    location =
      Enum.find_value(headers, fn {name, value} ->
        if List.to_string(name) == "location", do: List.to_string(value)
      end)

    {status, location}
  end
end
