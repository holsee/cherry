---
title: "cherrypicker: names for your ports"
description: Why we built a pure-Elixir alternative to portless in a day, how the register model works, and what cherry serve --name will do with it in the next release.
tags:
  - elixir
  - tooling
---
`localhost:4000` means nothing. `localhost:5173` means nothing. Six dev
servers into an afternoon, no port number means anything, and the one you
bookmarked yesterday is someone else now. Vercel's
[portless](https://github.com/vercel-labs/portless) named this problem
properly: dev servers should live at stable named URLs like
`http://docs.localhost`, and the port lottery should be the proxy's problem.

We wanted that for Cherry. We did not want it enough to install it.

## Why not just use portless

portless is a global npm install that self-elevates to bind port 443 and
installs a locally trusted root certificate authority. Each of those is
defensible on its own; together they are a lot of blast radius for a
convenience tool, sitting in the npm supply chain, which is the most
attacked package ecosystem there is. It also works by wrapping your dev
server as a child process and injecting the right port flag for each
framework it recognises, which means a compatibility list that has to chase
every CLI's flag changes forever.

So we built [cherrypicker](https://github.com/holsee/cherrypicker) in a
day: the same idea, on the BEAM, with the opposite instincts. Two runtime
dependencies (Bandit and Finch), no Node anywhere, no certificate authority
until TLS ships as an explicit opt-in verb, and no process wrapping at all.

## The register model

The design bet is one sentence: **apps register, nothing gets wrapped.**
Your dev server starts however it starts. Then something tells the daemon
where it is:

```text
$ cherrypicker route docs 8080
http://docs.localhost
```

That is the whole contract. The daemon is a loopback reverse proxy reading
the `Host` header: `docs.localhost` looks up `docs` in an ETS table and
streams the request to `127.0.0.1:8080`. Names resolve for free because
`*.localhost` already points at loopback on Windows, macOS and systemd
Linux. No DNS, no hosts file, nothing listening beyond your own machine.

Registering an existing name replaces its port, which is exactly what a dev
server restarting on a new ephemeral port wants. And discovery is a file,
not configuration: the daemon writes its bound port to
`~/.cherrypicker/daemon.json` on start and removes it on shutdown. A client
reads the file, speaks a four-endpoint JSON control API, and if no daemon
answers it gets `{:error, :no_daemon}` and carries on with plain port URLs.
Degradation is a designed path, not an error.

The proxy streams responses chunk by chunk in both directions, which
matters more than it sounds: server-sent events survive it, so a dev
server's live reload keeps working through the named URL. We proved that
the fun way, by serving this site's source through it and watching an edit
push a reload event through the proxy.

## Where cherry comes in

The next Cherry release grows two small serve features that make this
seamless. `cherry serve` now honours the `PORT` environment variable when
`--port` is absent, the convention every proxy runner and PaaS-style tool
already speaks. And it gains a flag:

```text
$ cherry serve --name mysite
Serving with live reload at http://mysite.localhost — Ctrl-C to stop.
```

With a cherrypicker daemon running, serve registers its bound port and
prints the named URL. Without one, you get the port URL as ever; the
feature costs one failed connect and never a failed serve. If the daemon
refuses the name, serve says why on stderr and falls back.

The interesting implementation choice is what Cherry does **not** do: it
takes no dependency on cherrypicker. The client inside Cherry is about
eighty lines of standard library, `:httpc` plus the built-in `JSON`
module, speaking the same control API. A dependency would drag a proxy
stack into every Cherry install for a feature most serves never touch, and
the whole point of the register model is that the contract is small enough
to not need a library. Elixir apps that do want the packaged client can
take [`cherrypicker` from Hex](https://github.com/holsee/cherrypicker) and
call `Cherrypicker.register/2` themselves; the daemon does not care which
kind of client is talking.

## How it will get used

The loop we are aiming at, once the release lands:

```text
$ cherrypicker start
proxy up — routes serve at http://<name>.localhost (Ctrl-C to stop)
```

```text
$ cherry serve --name blog
```

Then `http://blog.localhost` is your writing loop, today and next month,
whatever port serve actually bound. Agents get the same stability through
the `--json` envelopes on both tools, which is worth spelling out: a
stable URL is a small quality-of-life win for a human and a genuinely
load-bearing one for an agent, which otherwise has to re-discover the port
every session.

cherrypicker's own site, including the full API reference, is at
[holsee.github.io/cherrypicker](https://holsee.github.io/cherrypicker/),
and yes, it is built with Cherry. Dogfooding it immediately paid for
itself: building a Cherry site that takes Cherry from Hex surfaced an
overlay-resolution bug no repo-local site could ever hit, fixed the same
day. Tools you build for yourself are tools you debug for everyone.
