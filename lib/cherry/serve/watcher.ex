defmodule Cherry.Serve.Watcher do
  @moduledoc """
  Watches the site's inputs and rebuilds on change, debounced.

  Events under the output directory are ignored (our own writes must not
  retrigger builds). A broken edit prints its diagnostics and keeps the
  last good output serving; the next successful build broadcasts a reload.
  """

  use GenServer

  alias Cherry.Serve.Reloader

  @debounce_ms 120

  @spec start_link(keyword()) :: GenServer.on_start()
  def start_link(opts) do
    GenServer.start_link(__MODULE__, opts)
  end

  @impl GenServer
  def init(opts) do
    source = Keyword.fetch!(opts, :source)
    output = Keyword.fetch!(opts, :output)

    case fs_start().(dirs: [source]) do
      {:ok, watcher} ->
        FileSystem.subscribe(watcher)
        {:ok, %{source: source, output: Path.expand(output), pending?: false}}

      # No watcher backend (e.g. inotify-tools missing on Linux): serve
      # must still serve. `:ignore` leaves this child unstarted and the
      # rest of the tree — server and reloader — running normally.
      _unavailable ->
        IO.puts(:stderr, "warning: #{unavailable_message()}")
        :ignore
    end
  end

  # The seam tests use to simulate a missing watcher backend —
  # file_system cannot be forced into its unavailable branch portably.
  defp fs_start do
    Application.get_env(:cherry, :fs_watcher_start, &FileSystem.start_link/1)
  end

  @doc "Why live reload is off, with the platform's remedy."
  @spec unavailable_message() :: String.t()
  def unavailable_message do
    hint =
      case :os.type() do
        {:unix, :linux} -> "install inotify-tools and restart serve"
        {:unix, :darwin} -> "the bundled mac_listener failed to start; reinstall cherry"
        {:win32, _} -> "the bundled inotifywait.exe failed to start; reinstall cherry"
        _ -> "no file-watcher backend exists for this platform"
      end

    "live reload disabled — the file watcher could not start (#{hint}); " <>
      "serving without rebuild-on-change"
  end

  @impl GenServer
  def handle_info({:file_event, _pid, {path, _events}}, state) do
    if relevant?(path, state.output) and not state.pending? do
      Process.send_after(self(), :rebuild, @debounce_ms)
      {:noreply, %{state | pending?: true}}
    else
      {:noreply, state}
    end
  end

  def handle_info({:file_event, _pid, :stop}, state), do: {:noreply, state}

  def handle_info(:rebuild, state) do
    case Cherry.build(source: state.source, output: state.output, drafts: true) do
      {:ok, _build} ->
        IO.puts("rebuilt — reloading browsers")
        Reloader.broadcast()

      {:error, message} ->
        IO.puts(:stderr, "build failed (still serving the last good output):\n#{message}")
    end

    {:noreply, %{state | pending?: false}}
  end

  defp relevant?(path, output) do
    expanded = Path.expand(path)
    not String.starts_with?(expanded, output <> "/") and expanded != output
  end
end
