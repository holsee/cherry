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
  @probe_timeout_ms 5_000
  @probe_interval_ms 250
  @probe_name ".cherry-live-probe"

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
        started(source, output)

      # No watcher backend (e.g. inotify-tools missing on Linux): serve
      # must still serve. `:ignore` leaves this child unstarted and the
      # rest of the tree — server and reloader — running normally.
      _unavailable ->
        IO.puts(:stderr, "warning: #{unavailable_message()}")
        :ignore
    end
  end

  # A watcher that starts is not a watcher that works: on a Docker bind
  # mount from a Windows or macOS host, inotify is accepted and no event
  # is ever delivered. Serve would promise live reload and silently never
  # reload, so prove it once with a probe file before believing it.
  defp started(source, output) do
    if delivers_events?(source) do
      {:ok, %{source: source, output: Path.expand(output), pending?: false}}
    else
      IO.puts(:stderr, "warning: #{blind_message()}")
      :ignore
    end
  end

  defp delivers_events?(source) do
    probe = Path.join(probe_dir(source), @probe_name)
    delivered? = probe(probe, Path.expand(probe), deadline())
    File.rm(probe)
    drain()
    delivered?
  end

  # The backend accepts the subscription before its watch is established
  # (inotifywait has to spawn), so a single write can land in the gap and
  # look like a dead filesystem. Rewrite the probe until an event comes
  # back or the deadline passes.
  defp probe(probe, expanded, deadline) do
    cond do
      now() >= deadline ->
        false

      # An unwritable source cannot be probed. Assume the watcher works
      # rather than claim a fault we have not observed.
      File.write(probe, "#{now()}") != :ok ->
        true

      await(expanded, min(now() + @probe_interval_ms, deadline)) ->
        true

      true ->
        probe(probe, expanded, deadline)
    end
  end

  defp await(probe, deadline) do
    remaining = deadline - now()

    if remaining <= 0 do
      false
    else
      receive do
        {:file_event, _pid, {path, _events}} ->
          Path.expand(path) == probe or await(probe, deadline)
      after
        remaining -> false
      end
    end
  end

  # Probe where edits actually happen. A Docker bind mount can deliver
  # events for the watch root while delivering none for its
  # subdirectories, so probing the root would pass on a filesystem where
  # editing a post reloads nothing.
  defp probe_dir(source) do
    ["content/posts", "content", "."]
    |> Enum.map(&Path.join(source, &1))
    |> Enum.find(source, &File.dir?/1)
  end

  defp now, do: System.monotonic_time(:millisecond)

  # The probe's own delete event must not schedule a rebuild.
  defp drain do
    receive do
      {:file_event, _pid, _payload} -> drain()
    after
      0 -> :ok
    end
  end

  defp deadline do
    now() + Application.get_env(:cherry, :fs_probe_timeout, @probe_timeout_ms)
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

  @doc "Why live reload is off when the watcher started but sees nothing."
  @spec blind_message() :: String.t()
  def blind_message do
    "live reload disabled — the file watcher started but this filesystem " <>
      "delivers no change events (usual cause: the source is a Docker bind " <>
      "mount or a network share); serving without rebuild-on-change"
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
