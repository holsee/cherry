---
title: The embedded server
description: How cherry serve works inside. Bandit, a Registry as the whole pubsub, server-sent events, and a file watcher that refuses to lie.
tags:
  - elixir
  - design
---
Cherry's output is aggressively static: plain files, no runtime, deploy anywhere. But `cherry serve`, the dev loop, is the one place we run long-lived processes, and it is a nice little tour of why the BEAM is such a pleasant place to build tools. This post walks the real code.

## The whole tree

```elixir
children = [
  {Registry, keys: :duplicate, name: Reloader.registry()},
  {Bandit, plug: {Cherry.Serve.Plug, %{output: output}}, port: port, startup_log: false},
  {Watcher, source: source, output: output}
]

Supervisor.start_link(children, strategy: :one_for_one)
```

Three children. [Bandit](https://hex.pm/packages/bandit) serves the built `_site/`; a `Registry` is the entire pubsub; a `GenServer` watches your files. `one_for_one` means a crashing watcher never takes the web server down with it: worst case you lose live reload while the supervisor restarts one child, and your browser tab never notices.

## A Registry is the whole pubsub

Live reload needs exactly one message: "the site was rebuilt". You do not need a message broker for that, because the standard library ships one:

```elixir
def subscribe do
  {:ok, _} = Registry.register(@registry, :reload, nil)
  :ok
end

def broadcast do
  Registry.dispatch(@registry, :reload, fn entries ->
    for {pid, _value} <- entries, do: send(pid, :cherry_reload)
  end)
end
```

That is the complete fanout module, minus the moduledoc. A duplicate-key `Registry` holds every subscribed connection; `dispatch` sends each one a message. When a connection process dies (you closed the tab), the Registry cleans up its entry automatically, because the BEAM links process lifetime to state for free. No heartbeats, no reaping, no stale-connection bugs.

## Reload over server-sent events

Each open page holds a connection to `/__cherry/reload`, which subscribes and then chunks out SSE events as they arrive:

```elixir
defp sse(conn) do
  Reloader.subscribe()

  conn
  |> put_resp_header("content-type", "text/event-stream")
  |> put_resp_header("cache-control", "no-cache")
  |> send_chunked(200)
  |> sse_loop()
end
```

We picked SSE over WebSockets because the traffic is strictly one-way and the client is four lines of `EventSource`. Every HTML page gets a tiny script injected at serve time only; the production build never sees it. A blocked process per connection sounds expensive until you remember these are BEAM processes: a few kilobytes each, scheduled cooperatively, and the server would not blink at a thousand of them.

## The rebuild loop survives your typos

The watcher debounces file events (editors love writing files three times), then rebuilds:

```elixir
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
```

A broken edit prints its diagnostics and the last good output keeps serving. This falls out of the architecture rather than being engineered: the build is a pure function over the tree, the server serves whatever `_site/` holds, and a failed build simply never touches `_site/`. Save the fix and the next event broadcasts a reload. Your browser never sees a stack trace page, because there is no such page to see.

## The watcher that refuses to lie

My favourite part of this module has no algorithmic content at all; it is pure honesty engineering. A file watcher that *starts* is not a file watcher that *works*: on a Docker bind mount from a Windows or macOS host, inotify accepts the subscription and then never delivers a single event. A naive serve would promise live reload and silently never reload.

So the watcher proves the filesystem before believing it:

```elixir
defp started(source, output) do
  if delivers_events?(source) do
    {:ok, %{source: source, output: Path.expand(output), pending?: false}}
  else
    IO.puts(:stderr, "warning: #{blind_message()}")
    :ignore
  end
end
```

It writes a probe file where your edits actually happen (`content/posts/`, not the watch root, because bind mounts have been observed delivering root events while dropping subdirectory ones), waits for the event to come back, and rewrites the probe on an interval because the backend can accept a subscription before its watch is established. If nothing comes back by the deadline, it says so, out loud, and returns `:ignore`.

`:ignore` is the quiet star. It is a standard child-start return meaning "leave me out of the tree"; the supervisor carries on with the server and reloader, and serve keeps serving without rebuild-on-change. One honest warning, degraded gracefully, nothing crashed. The `--json` envelope carries `live_reload: false`, so even a script driving serve learns the truth without parsing stderr.

## The ephemeral port trick

One more small kindness: `cherry serve --port 0` asks the OS for any free port, then reports the one actually bound, in the banner and the envelope. Agents and CI use it so a taken port 4000 can never fail a run. On the BEAM this is a one-liner (bind to zero, ask the listener for its port), and it removes an entire category of flaky automation.

None of this is exotic Elixir. A supervisor, a Registry, a GenServer, chunked responses: the standard toolbox, arranged so that the failure modes degrade instead of cascade. That is the whole trick, and the BEAM makes it the path of least resistance. The [serve reference](/docs/cli/) has the flags; `cherry new` and thirty seconds get you the loop itself.
