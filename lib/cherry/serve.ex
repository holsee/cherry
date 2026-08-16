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
  `source/_site`), `:port` (default 4000). Returns the supervisor pid and
  the port actually bound (pass `port: 0` for an ephemeral port).
  """
  @spec start(keyword()) :: {:ok, pid(), :inet.port_number()} | {:error, String.t()}
  def start(opts) do
    source = Keyword.fetch!(opts, :source)
    output = Keyword.get(opts, :output, Path.join(source, "_site"))
    port = Keyword.get(opts, :port, 4000)

    with {:ok, _build} <- Cherry.build(source: source, output: output, drafts: true) do
      # Bandit.Clock caches the Date header in an ETS table owned by the
      # :bandit application. Starting only the child spec leaves that
      # table missing, and every response logs a warning.
      {:ok, _apps} = Application.ensure_all_started(:bandit)

      children = [
        {Registry, keys: :duplicate, name: Reloader.registry()},
        {Bandit, plug: {Cherry.Serve.Plug, %{output: output}}, port: port, startup_log: false},
        {Watcher, source: source, output: output}
      ]

      case Supervisor.start_link(children, strategy: :one_for_one) do
        {:ok, pid} -> {:ok, pid, bound_port(pid)}
        {:error, reason} -> {:error, "could not start server: #{inspect(reason)}"}
      end
    end
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
