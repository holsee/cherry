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

    {:ok, watcher} = FileSystem.start_link(dirs: [source])
    FileSystem.subscribe(watcher)

    {:ok, %{source: source, output: Path.expand(output), pending?: false}}
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
