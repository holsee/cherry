defmodule Cherry.Serve do
  @moduledoc """
  The dev server: Bandit serving the built `_site/`, a file watcher that
  rebuilds on change, and live reload over server-sent events.

  Serve mode is the one place Cherry runs long-lived processes; production
  output stays plain static files.
  """

  alias Cherry.Serve.{Reloader, Watcher}

  @doc """
  Builds the site once, then starts the server + watcher supervision tree.

  Options: `:source` (site root, required), `:output` (default
  `source/_site`), `:port` (default 4000), `:verbose` (log every request).
  Returns the supervisor pid, the port actually bound (pass `port: 0`
  for an ephemeral port), and the site's URL prefix — `""` for a root
  site, `"/repo"` for a `base_path` site, whose pages then serve under
  that prefix exactly as production will. Changing `base_path` needs a
  serve restart; rebuilds pick up content, not a new prefix.
  """
  @spec start(keyword()) :: {:ok, pid(), :inet.port_number(), String.t()} | {:error, String.t()}
  def start(opts) do
    source = Keyword.fetch!(opts, :source)
    output = Keyword.get(opts, :output, Path.join(source, "_site"))
    port = Keyword.get(opts, :port, 4000)
    verbose? = Keyword.get(opts, :verbose, false)

    # SSE heartbeat cadence; tests shrink it to observe disconnect reaping.
    heartbeat_ms = Keyword.get(opts, :heartbeat_ms, 15_000)

    with {:ok, build} <- Cherry.build(source: source, output: output, drafts: true) do
      base = base_segments(build.site.base_path)

      # Bandit.Clock caches the Date header in an ETS table owned by the
      # :bandit application. Starting only the child spec leaves that
      # table missing, and every response logs a warning.
      {:ok, _apps} = Application.ensure_all_started(:bandit)

      plug_config = %{output: output, base: base, verbose?: verbose?, heartbeat_ms: heartbeat_ms}

      children = [
        {Registry, keys: :duplicate, name: Reloader.registry()},
        {Bandit, bandit_opts(plug_config, port, :inet)},
        {Watcher, source: source, output: output}
      ]

      case Supervisor.start_link(children, strategy: :one_for_one) do
        {:ok, pid} ->
          bound = bound_port(pid)
          add_ipv6_listener(pid, plug_config, bound)
          {:ok, pid, bound, base_prefix(base)}

        {:error, reason} ->
          {:error, "could not start server: #{inspect(reason)}"}
      end
    end
  end

  defp base_segments("/"), do: []
  defp base_segments(base_path), do: base_path |> String.split("/", trim: true)

  defp base_prefix([]), do: ""
  defp base_prefix(segments), do: "/" <> Enum.join(segments, "/")

  # `localhost` resolves to `::1` first on Windows and macOS, so with
  # only an IPv4 listener every click stalls on an IPv6 connect before
  # the browser falls back. One dual-stack socket is not portable —
  # Windows returns :einval for `ipv6_v6only: false` — so a second,
  # v6-only listener joins the tree on the same port. A host without
  # usable IPv6 keeps just the IPv4 listener, the old behaviour.
  defp add_ipv6_listener(supervisor, plug_config, port) do
    spec =
      Supervisor.child_spec({Bandit, bandit_opts(plug_config, port, :inet6)},
        id: :bandit_ipv6
      )

    case Supervisor.start_child(supervisor, spec) do
      {:ok, _pid} -> :ok
      {:error, _reason} -> :ok
    end
  end

  defp bandit_opts(plug_config, port, :inet) do
    [
      plug: {Cherry.Serve.Plug, plug_config},
      port: port,
      startup_log: false
    ]
  end

  defp bandit_opts(plug_config, port, :inet6) do
    bandit_opts(plug_config, port, :inet) ++
      [thousand_island_options: [transport_options: [:inet6, ipv6_v6only: true]]]
  end

  @doc """
  Whether the file watcher is actually running under this serve tree.

  False when the watcher backend was unavailable and `Watcher.init/1`
  degraded to `:ignore` — the site serves, but without rebuild-on-change.
  """
  @spec live_reload?(pid()) :: boolean()
  def live_reload?(supervisor) do
    Enum.any?(Supervisor.which_children(supervisor), fn
      {Watcher, pid, _type, _mods} -> is_pid(pid)
      _child -> false
    end)
  end

  defp bound_port(supervisor) do
    {_, bandit_pid, _, _} =
      supervisor
      |> Supervisor.which_children()
      |> Enum.find(fn
        {{Bandit, _ref}, _pid, _type, _mods} -> true
        {_id, _pid, _type, mods} -> mods == [Bandit]
      end)

    {:ok, {_ip, port}} = ThousandIsland.listener_info(bandit_pid)
    port
  end
end
