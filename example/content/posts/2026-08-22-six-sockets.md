---
title: "Six sockets: a live-reload leak in two acts"
tags: [debugging, elixir, serve, cherrypicker]
---

:::tip{title="TL;DR"}
A dev-site click stalled for 55 seconds while the server answered in
3 milliseconds. The browser's six-connections-per-host HTTP/1.1 limit
was full of abandoned live-reload SSE streams, held open by
back/forward-cached pages. Two fixes: cherry 0.4.1 closes its
`EventSource` on `pagehide` and heartbeats the SSE loop with
`receive ... after`, so a dead browser fails a write; cherrypicker
moves its upstream pull into a monitored reader and watches the client
socket with `active: :once`, so a leaving browser arrives as a message.
The rule underneath both: every way your wait can end must have a
wake-up path.
:::

Late last night I clicked a link on a `cherry serve` site and the browser
just sat there. Fifty-five seconds. Then the page appeared instantly, as
if nothing had happened. The same waterfall that recorded the freeze
showed the server answering in under three milliseconds. Both things were
true at once, and working out how turned into two bug fixes across two
projects and a small tour of how BEAM processes and TCP sockets actually
talk to each other. Consider this the devlog. The mistakes are ordinary
Elixir mistakes, which is exactly why they are worth writing up.

## The symptom that lies

The first instinct with a slow page is to blame the server, and the
Network panel seemed happy to oblige:

```text
Queueing            4.24 ms
Stalled             54.91 s
DNS Lookup          14 µs
Initial connection  306 ms
Request sent        73 µs
Waiting for server  2.62 ms
Content Download    0.31 ms
```

I stared at this for longer than I would like to admit before actually
reading it. "Waiting for server" is 2.62 milliseconds. The 55 seconds sit
in "Stalled", which is time the browser spent before it even tried to
connect. The request was not slow. It was never sent.

## The wrong suspect

I blamed [cherrypicker](https://github.com/holsee/cherrypicker) at once.
It is a local reverse proxy I wrote to give dev servers stable
`name.localhost` URLs, it sits between the browser and everything, and
`netstat` made it look thoroughly guilty: twenty-one connections parked
in `CLOSE_WAIT` on its port, sockets the proxy had failed to close after
the browser hung up. I had the bug report half written in my head.

Then the stall reproduced against the dev server's port directly, with no
proxy in the path. Whatever was wrong travelled with the page. The proxy
was still guilty of something, mind. We will come back for it.

## The trace that names the culprit

A DevTools performance trace settled it. Six quick page views in fifteen
seconds, each opening a request to `/__cherry/reload`, and most of those
streams were still hanging open when the next click came:

```text
15.14 s  click /story/payments/   request created
60.03 s  request sent             connectStart: 44,883 ms
60.04 s  done                     server time: 10 ms
```

`/__cherry/reload` is cherry's live-reload stream: every page served in
dev opens a server-sent-events connection and waits for the server to say
"rebuilt". The client was one line of JavaScript:

```js
const source = new EventSource("/__cherry/reload");
source.onmessage = () => location.reload();
```

Nothing ever closed it. Navigate away and the browser puts the page in
the back/forward cache with its stream still open. And here is the trap:
SSE over HTTP/1.1 counts against the browser's limit of **six
connections per host**. Pile up a few cached pages behind the live one
and every slot is spoken for; when I counted, the browser held exactly
six established connections to the dev server. The next click queues in
"Stalled" until the browser evicts a cached page and frees a slot. On
this machine that took forty-five seconds.

If that limit is news to you, you are in good company. It dates from
the HTTP/1.1 era: a connection carries one request at a time, so
browsers parallelise by opening several. RFC 2616 asked for two per
host; browsers settled on six, shared across all your tabs. The cap is
deliberate politeness, not a bug: without a ceiling, every busy tab
becomes an accidental denial-of-service tool, and swarms of fresh
connections defeat TCP's congestion control, which tunes itself per
connection. Every fetch and every `EventSource` counts against the six,
and an SSE stream is the worst kind of tenant because it holds its slot
for the lifetime of the page - the classic "my app breaks when I open
six tabs" bug that haunts SSE dashboards. The real trap is that
production rarely shows it: over HTTPS the browser speaks HTTP/2, which
multiplexes any number of streams over one connection. Local dev is
plain HTTP, which means HTTP/1.1, which means six. The pitfall lives
exactly where the live-reload streams do.

## Act one: fix cherry's ends of the stream

The server side had the mirror image of the same bug. Cherry's SSE
handler is a plain Plug function that subscribes to a rebuild registry
and blocks. First pass was minimal, too minimal, when implementing the
reload stream:

```elixir
defp sse_loop(conn) do
  receive do
    :cherry_reload ->
      case chunk(conn, "data: reload\n\n") do
        {:ok, conn} -> sse_loop(conn)
        {:error, _reason} -> conn
      end
  end
end
```

Spot the assumption. The only way this process learns the browser is gone
is a failed `chunk/2`, and it only calls `chunk/2` when a rebuild
happens. Between rebuilds it sits in `receive` forever, holding a socket
for a browser that may have left hours ago. This shape rang alarm bells
at the time, in the form of "I must add a timeout here later", and
honestly I should have just handled it there and then.

> A process blocked in `receive` with no timeout can only learn things
> someone sends it, and TCP will not send your process a message about a
> peer's FIN unless you arrange for it.

<svg viewBox="0 0 800 285" role="img" aria-label="The broken shape: the handler blocks in a receive with a single clause fed by the watcher; the browser's FIN reaches a passive socket and produces no message, so the handler can never learn the browser left" style="max-width: 44rem; width: 100%; height: auto; display: block; margin: 1.5rem auto;" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" fill="currentColor">
  <defs>
    <marker id="ss-arrow2" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="currentColor"/>
    </marker>
  </defs>
  <g stroke="currentColor" stroke-width="1.2" fill="none">
    <rect x="180" y="40" width="340" height="190" rx="6"/>
    <rect x="16" y="112" width="110" height="56" rx="6"/>
    <rect x="610" y="112" width="150" height="64" rx="6"/>
    <line x1="610" y1="144" x2="524" y2="144" marker-end="url(#ss-arrow2)"/>
    <line x1="126" y1="140" x2="176" y2="140" stroke-dasharray="4 4" marker-end="url(#ss-arrow2)"/>
    <line x1="196" y1="100" x2="504" y2="100" opacity="0.25"/>
  </g>
  <g font-size="12.5">
    <text x="200" y="66" font-size="14" font-weight="600">handler</text>
    <text x="200" y="86" font-size="11.5" opacity="0.65">owns the client socket (passive, never read)</text>
    <text x="200" y="124">receive do</text>
    <text x="214" y="148">:cherry_reload</text>
    <text x="368" y="148" font-size="11" opacity="0.6">◄ watcher: rebuilt</text>
    <text x="200" y="172">end</text>
    <text x="200" y="204" font-size="11" opacity="0.6">no after clause: nothing else can ever wake it</text>
    <text x="71" y="145" text-anchor="middle">browser</text>
    <text x="685" y="138" text-anchor="middle" font-size="14" font-weight="600">watcher</text>
    <text x="685" y="158" text-anchor="middle" font-size="11.5" opacity="0.65">broadcasts on rebuild</text>
    <text x="151" y="128" text-anchor="middle" font-size="12">✕</text>
    <text x="400" y="266" text-anchor="middle" font-size="11.5" opacity="0.7">the browser's FIN reaches a passive socket: no message, no write, no way to notice</text>
  </g>
</svg>

The fix shipped in cherry 0.4.1, one half per side of the socket. The
client lets go when the page leaves:

```js
addEventListener("pagehide", () => source.close());
addEventListener("pageshow", (event) => {
  if (event.persisted) location.reload();
});
```

A page restored from the back/forward cache reloads instead of
reconnecting, because it has missed any rebuilds while it was cached.

The server gains a heartbeat, which in Elixir is nothing more exotic than
the `after` clause my `receive` was missing:

```elixir
defp sse_loop(conn, heartbeat_ms) do
  receive do
    :cherry_reload ->
      case chunk(conn, "data: reload\n\n") do
        {:ok, conn} -> sse_loop(conn, heartbeat_ms)
        {:error, _reason} -> conn
      end
  after
    heartbeat_ms ->
      case chunk(conn, ": ping\n\n") do
        {:ok, conn} -> sse_loop(conn, heartbeat_ms)
        {:error, _reason} -> conn
      end
  end
end
```

A line starting with a colon is an SSE comment frame; `EventSource`
ignores it entirely. The point is not the message but the write. Writing
to a closed socket fails, and the failure is how the server finally
learns the browser left. Twenty seconds after a client disconnects, the
socket count is back to zero.

<svg viewBox="0 0 800 285" role="img" aria-label="The fixed shape: the receive gains an after clause that writes a ping every heartbeat; the client closes its EventSource on pagehide; a dead browser fails the write, and the failure is how the handler learns" style="max-width: 44rem; width: 100%; height: auto; display: block; margin: 1.5rem auto;" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" fill="currentColor">
  <defs>
    <marker id="ss-arrow3" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="currentColor"/>
    </marker>
  </defs>
  <g stroke="currentColor" stroke-width="1.2" fill="none">
    <rect x="180" y="40" width="340" height="200" rx="6"/>
    <rect x="16" y="108" width="110" height="72" rx="6"/>
    <rect x="610" y="112" width="150" height="64" rx="6"/>
    <line x1="610" y1="144" x2="524" y2="144" marker-end="url(#ss-arrow3)"/>
    <line x1="180" y1="168" x2="130" y2="168" marker-end="url(#ss-arrow3)"/>
    <line x1="196" y1="100" x2="504" y2="100" opacity="0.25"/>
  </g>
  <g font-size="12.5">
    <text x="200" y="66" font-size="14" font-weight="600">handler</text>
    <text x="200" y="86" font-size="11.5" opacity="0.65">owns the client socket</text>
    <text x="200" y="124">receive do</text>
    <text x="214" y="148">:cherry_reload</text>
    <text x="368" y="148" font-size="11" opacity="0.6">◄ watcher: rebuilt</text>
    <text x="200" y="172">after heartbeat_ms</text>
    <text x="368" y="172" font-size="11" opacity="0.6">► ping the browser</text>
    <text x="200" y="196">end</text>
    <text x="200" y="224" font-size="10.5" opacity="0.6">the write is the detector: a dead socket fails it</text>
    <text x="71" y="138" text-anchor="middle">browser</text>
    <text x="71" y="156" text-anchor="middle" font-size="11.5" opacity="0.65">closes on</text>
    <text x="71" y="170" text-anchor="middle" font-size="11.5" opacity="0.65">pagehide</text>
    <text x="685" y="138" text-anchor="middle" font-size="14" font-weight="600">watcher</text>
    <text x="685" y="158" text-anchor="middle" font-size="11.5" opacity="0.65">broadcasts on rebuild</text>
    <text x="400" y="268" text-anchor="middle" font-size="11.5" opacity="0.7">every quiet heartbeat the handler writes; when the browser is gone the write fails</text>
  </g>
</svg>

One caveat before you copy this pattern: write-failure detection is
approximate. After a peer closes, the first write often succeeds into the
kernel's buffer and only the next one fails, so a heartbeat notices death
within a beat or two rather than instantly. For reaping abandoned
dev-server streams, that is plenty.

## Act two: the proxy deserved better than a well-behaved upstream

Back to those twenty-one `CLOSE_WAIT` sockets, because
[cherrypicker](https://github.com/holsee/cherrypicker) had made exactly
the same mistake, one hop along.

:::note{title="What is cherrypicker?"}
A pure-BEAM reverse proxy and route registry for local development: dev
servers bound to `localhost:PORT` register a name with its daemon and
become reachable at a stable `http://NAME.localhost` URL. `cherry serve
--name mysite` rides it. No Node, no npm, no root CA.
:::

The proxy's Bandit handler called `Finch.stream/5` with
`receive_timeout: :infinity`, relayed each chunk to the client, and
treated a failed client write as the end of the stream.
An idle upstream sends no chunks, so there are no writes, so a vanished
browser goes unnoticed, and now three things leak per abandoned stream:
the client socket stuck in `CLOSE_WAIT`, the handler process parked
inside `Finch.stream`, and the Finch connection to the upstream. Cherry's
new heartbeat happens to paper over this for cherry upstreams, since the
pings flow through the proxy and fail the write. But a proxy should not
need its upstreams to be polite.

The structural problem is that `Finch.stream` is synchronous. While the
handler is inside it, the handler can hear nothing else. So the fix
inverts the architecture: the Finch pull moves into a spawned, monitored
reader process that forwards events as messages, and the handler becomes
a relay loop that can listen to several things at once.

```elixir
owner = self()

reader =
  Task.Supervisor.async_nolink(Cherrypicker.ReaderSupervisor, fn ->
    Finch.stream(request, Cherrypicker.Finch, :ok, fn event, :ok ->
      send(owner, {:upstream, event})
      :ok
    end, receive_timeout: :infinity)
  end)
```

The second half of the trick: the handler owns the client socket, so it
can ask the kernel to turn the browser's departure into a message.

```elixir
:inet.setopts(client_socket, active: :once)
```

With the socket in `active: :once`, the peer's FIN lands in the handler's
mailbox as `{:tcp_closed, socket}` the moment it happens. No polling, no
writes, and it works for a stream that never carries a byte. The relay
loop is a single `receive` over both worlds:

```elixir
receive do
  {:upstream, {:data, data}}            -> # chunk to the client, loop
  {^ref, result}                        -> # the task's reply: finish
  {:DOWN, ^ref, :process, ^pid, reason} -> # reader crashed: 502
  {:tcp_closed, ^client}                -> # kill the reader; done
end
```

Now hold on. That is a bare `receive` with no `after` clause, one act
after I told you to distrust exactly that shape. The difference is what
silence means. A timeout exists to manufacture a signal when nobody else
will send one; cherry's SSE loop needed it because a quiet stream had no
other way to learn anything. The relay does not, because every way this
wait can end already produces a message. The reader finishing sends its
task reply. The reader crashing produces `{:DOWN, _, _, _, _}`, because
it is monitored. The browser leaving produces `{:tcp_closed, _}`,
because we put the socket in active mode. Silence here can only mean
everyone is alive and nothing has happened, which is the one situation
where blocking forever is correct.

> The discipline is not "always have a timeout". It is "every way your
> wait can end must have a wake-up path", and a timeout is the wake-up
> path of last resort.

Worth saying, too, why this is a plain `receive` and not a GenServer,
given how reflexively we reach for OTP behaviours. The handler is not a
long-lived service with an API; it is Bandit's per-connection process,
already sitting in a supervision tree that ThousandIsland manages,
living exactly as long as one request. For a finite, straight-line
lifecycle like that, a plain `receive` is the simplest tool that fits:
no state to name, no API to design, just a short wait with a clause for
every way it can end. The reader is the one process we start ourselves,
and
`async_nolink` earns each word of its name: a plain `Task.async` links,
and a link means a crashing reader takes the handler down with it before
the `{:DOWN, ...}` clause can turn the crash into a tidy 502. The
`Task.Supervisor` half matters just as much: the reader has a named
parent in the daemon's tree, so it shows up in observer and dies with
the tree, never orphaned by a handler that stopped without unwinding.

> A monitor delivers the failure as data instead of fate.

<svg viewBox="0 0 800 310" role="img" aria-label="Process tree: a supervised handler owns the client socket and blocks in receive; a monitored reader pulls the stream from the upstream; each receive clause is fed by one collaborator" style="max-width: 44rem; width: 100%; height: auto; display: block; margin: 1.5rem auto;" font-family="ui-monospace, SFMono-Regular, Menlo, Consolas, monospace" fill="currentColor">
  <defs>
    <marker id="ss-arrow" viewBox="0 0 10 10" refX="9" refY="5" markerWidth="7" markerHeight="7" orient="auto-start-reverse">
      <path d="M0,0 L10,5 L0,10 z" fill="currentColor"/>
    </marker>
  </defs>
  <g stroke="currentColor" stroke-width="1.2" fill="none">
    <rect x="230" y="14" width="270" height="34" rx="6"/>
    <rect x="180" y="76" width="340" height="210" rx="6"/>
    <rect x="16" y="150" width="110" height="56" rx="6"/>
    <rect x="610" y="96" width="150" height="64" rx="6"/>
    <rect x="610" y="216" width="150" height="56" rx="6"/>
    <line x1="365" y1="48" x2="365" y2="72" marker-end="url(#ss-arrow)"/>
    <line x1="126" y1="178" x2="176" y2="178" marker-end="url(#ss-arrow)"/>
    <line x1="520" y1="120" x2="606" y2="120" marker-end="url(#ss-arrow)"/>
    <line x1="685" y1="160" x2="685" y2="212" marker-end="url(#ss-arrow)"/>
    <line x1="196" y1="136" x2="504" y2="136" opacity="0.25"/>
  </g>
  <g font-size="12.5">
    <text x="365" y="36" text-anchor="middle">ThousandIsland pool · supervised</text>
    <text x="200" y="102" font-size="14" font-weight="600">handler</text>
    <text x="200" y="122" font-size="11.5" opacity="0.65">owns the client socket (active: :once)</text>
    <text x="200" y="160">receive do</text>
    <text x="214" y="184">{:upstream, event}</text>
    <text x="368" y="184" font-size="11" opacity="0.6">◄ reader: flowing</text>
    <text x="214" y="208">{ref, result}</text>
    <text x="368" y="208" font-size="11" opacity="0.6">◄ reader: finished</text>
    <text x="214" y="232">{:DOWN, _, _, _, _}</text>
    <text x="368" y="232" font-size="11" opacity="0.6">◄ runtime: reader died</text>
    <text x="214" y="256">{:tcp_closed, _}</text>
    <text x="368" y="256" font-size="11" opacity="0.6">◄ kernel: browser left</text>
    <text x="200" y="280">end</text>
    <text x="71" y="183" text-anchor="middle">browser</text>
    <text x="685" y="122" text-anchor="middle" font-size="14" font-weight="600">reader</text>
    <text x="685" y="142" text-anchor="middle" font-size="11.5" opacity="0.65">Finch.stream · supervised</text>
    <text x="685" y="240" text-anchor="middle" font-size="14" font-weight="600">upstream</text>
    <text x="685" y="258" text-anchor="middle" font-size="11.5" opacity="0.65">the dev server</text>
    <text x="377" y="66" font-size="11" opacity="0.6">supervises</text>
    <text x="563" y="110" text-anchor="middle" font-size="11" opacity="0.6">async_nolink</text>
  </g>
</svg>

A few BEAM details carry the weight here, and they are the part I
would want a fellow Elixir developer to walk away with.

Killing the reader releases the upstream for free, so simple it feels
like cheating. Finch's pool (NimblePool underneath)
monitors the process that checked a connection out; when the reader dies,
the pool sees the `DOWN` and closes the connection rather than reuse it
in an unknown state. One `Process.exit(reader, :kill)` and the client
socket, the handler, and the upstream connection all release together.

> There is no cleanup code, because the runtime is the cleanup code.

Mailbox ordering quietly does the work of a protocol. Messages between
two processes arrive in the order they were sent, so `{:upstream_done,
_}`, sent by the reader after its last event, is a natural terminator: by
the time the relay sees it, every data chunk has already been relayed. No
sequence numbers, no flushing dance.

And borrowed sockets go back the way you found them. Bandit expects the
socket passive between requests, so the relay restores `active: false`
and drains any stray messages before returning, keeping keep-alive
intact. If bytes arrive mid-response, that would be a pipelining client,
which browsers never are, so the connection ends rather than hand Bandit
a socket whose bytes we consumed. Reaching the raw socket does mean one
guarded trip through Bandit's adapter struct; an unrecognised shape
degrades to the old behaviour instead of crashing.

The regression test is the bug in miniature: a hand-rolled upstream that
sends SSE headers plus one event and goes silent, a raw `:gen_tcp` client
that reads the event and vanishes, and an assertion that the proxy closes
its upstream side. On the old code it times out. On the new code it
passes in milliseconds. Then the same check live, the way the bug was
found in the first place: five abandoned streams against a running
daemon, and seconds later zero `CLOSE_WAIT` and zero leaked upstream
connections. Few things in debugging are as satisfying as a clean
`netstat` that used to be filthy.

One loose end surfaced after this shipped, and it earns its place here
as a lesson in exception safety. `Plug.Conn.chunk` returns errors, but
Bandit's `send_chunked` raises when the client dies at just the wrong
moment, and the first version kept its reader cleanup in the happy
paths: a raise unwound past all of it and resurrected the exact leak
through the exception path. Two boring fixes made the guarantee real.
The reader is reaped in a `try/after` block, which every internal
unwind passes through, and it runs under the `Task.Supervisor`, so even
a handler that stops without unwinding leaves nothing behind. A purist
would instead link the pair and let one crash kill both - fewer
promises kept by me, more kept by the runtime - and that is the more
Erlang answer. Keeping the handler alive is a deliberate kindness: the
browser gets a tidy 502 instead of a dropped connection. The `after`
block is the price of the kindness.

## What travels

If you take one thing, take this: "Stalled" is a browser problem - the
problem of six sockets. The server had answered in milliseconds every
single time. When the waterfall shows a sliver of server time under a
mountain of stall, stop tuning the backend and start counting sockets.

The Elixir-shaped lesson is that a blocked process can only learn what
someone tells it. A `receive` without `after`, or a synchronous call with
an infinite timeout, is a process that has opted out of the news. Give it
a timeout so it writes and can fail, or move the blocking work to another
process and let the kernel deliver `{:tcp_closed, _}` where it can be
heard.

Two smaller ones ride along. Every long-lived connection needs an owner
on both ends; any end that nobody is responsible for noticing is a leak
waiting for traffic. And reproduce past your suspect before you fix it.
The proxy had a genuine bug and still was not the cause of the stall; one
request against the bare port was all it took to separate the two, and
each fix landed against the failure it actually owns.

Both fixes are out: the stream ends in cherry 0.4.1, the proxy on
cherrypicker's main, shipped the same day the trace was captured. The
browser and I are back on speaking terms.
