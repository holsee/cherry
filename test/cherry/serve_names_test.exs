defmodule Cherry.ServeNamesTest do
  # Not async: real ports, PORT/CHERRYPICKER_HOME env, and the named
  # serve registry.
  use ExUnit.Case

  @moduledoc """
  The serve-side of #83/#84: `PORT` env fallback and `--name`
  registration against a cherrypicker daemon's control API (stubbed
  here — cherrypicker's own suite owns the real daemon).
  """

  alias Cherry.CLI.Context
  alias Cherry.Commands.Serve

  @fixture Path.expand("../fixtures/sites/blog", __DIR__)
  @moduletag timeout: 120_000

  defmodule StubControl do
    @moduledoc false
    @behaviour Plug
    import Plug.Conn

    @impl Plug
    def init(opts), do: opts

    @impl Plug
    def call(%Plug.Conn{method: "PUT", path_info: ["routes", name]} = conn, _opts) do
      {:ok, body, conn} = read_body(conn)
      send(:serve_names_test, {:registered, name, JSON.decode!(body)})

      conn
      |> put_resp_content_type("application/json")
      |> send_resp(200, JSON.encode!(%{ok: true, url: "http://#{name}.localhost"}))
    end

    def call(conn, _opts), do: send_resp(conn, 404, "")
  end

  setup do
    tmp = Path.join(System.tmp_dir!(), "cherry-names-#{System.unique_integer([:positive])}")
    site = Path.join(tmp, "site")
    File.mkdir_p!(site)
    on_exit(fn -> File.rm_rf!(tmp) end)
    File.cp_r!(@fixture, site)
    File.rm_rf!(Path.join(site, "expected"))

    home = Path.join(tmp, "picker-home")
    System.put_env("CHERRYPICKER_HOME", home)
    on_exit(fn -> System.delete_env("CHERRYPICKER_HOME") end)
    on_exit(fn -> System.delete_env("PORT") end)

    {:ok, site: site, home: home}
  end

  test "PORT env is honoured when --port is absent", %{site: site} do
    System.put_env("PORT", "0")

    assert {:ok, %{port: port}} = Serve.run(%Context{verb: :serve, opts: [source: site]})
    assert port != 4000
  end

  test "a malformed PORT falls back to the default", %{site: site} do
    System.put_env("PORT", "not-a-port")

    assert {:ok, %{port: 4000}} = Serve.run(%Context{verb: :serve, opts: [source: site]})
  end

  test "--name registers with the daemon and the URL goes named", ctx do
    Process.register(self(), :serve_names_test)

    stub =
      start_supervised!(
        {Bandit,
         plug: StubControl,
         port: 0,
         startup_log: false,
         thousand_island_options: [shutdown_timeout: 100]}
      )

    {:ok, {_ip, stub_port}} = ThousandIsland.listener_info(stub)
    File.mkdir_p!(ctx.home)
    File.write!(Path.join(ctx.home, "daemon.json"), JSON.encode!(%{port: stub_port}))

    assert {:ok, %{url: url, port: port}} =
             Serve.run(%Context{verb: :serve, opts: [source: ctx.site, port: 0, name: "mysite"]})

    assert url == "http://mysite.localhost:#{stub_port}"
    assert_receive {:registered, "mysite", %{"port" => ^port}}
  end

  test "--name with no daemon falls back to the port URL", ctx do
    assert {:ok, %{url: url, port: port}} =
             Serve.run(%Context{verb: :serve, opts: [source: ctx.site, port: 0, name: "mysite"]})

    assert url == "http://localhost:#{port}"
  end
end
