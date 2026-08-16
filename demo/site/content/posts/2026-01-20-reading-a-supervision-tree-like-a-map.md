---
title: "Reading a Supervision Tree Like a Map"
tags: [elixir, otp, operations]
description: "A supervision tree is a diagram of what your system believes about failure. Most outages are places where that belief was wrong."
---

When I join a BEAM codebase, the first file I open is `application.ex`. Not the
router, not the schema — the supervision tree. It is the only place where the
system states, in code, what it thinks should happen when things break.

```elixir
def start(_type, _args) do
  children = [
    Ledgerbeam.Repo,
    {Phoenix.PubSub, name: Ledgerbeam.PubSub},
    {Finch, name: Ledgerbeam.HTTP},
    Ledgerbeam.Inventory.Supervisor,
    Ledgerbeam.Ingest.Pipeline,
    LedgerbeamWeb.Endpoint
  ]

  Supervisor.start_link(children, strategy: :one_for_one, name: Ledgerbeam.Supervisor)
end
```

Six lines, and each one is a claim.

## What the order tells you

Children start in order and stop in reverse. So this tree claims the endpoint
should be the last thing up and the first thing down — traffic only arrives
once the repo, the pipeline, and the domain supervisors are ready, and traffic
stops before they go away.

That is almost always what you want, and it is worth checking, because the
failure mode is subtle: put the endpoint too early and you accept requests
against a half-built system for a few hundred milliseconds on every deploy.

## What the strategy tells you

`:one_for_one` says these six things are independent — if the ingest pipeline
dies, the endpoint should carry on. Is that true? For us it was: the site stays
up and serves reads while ingestion restarts.

But look for a `:one_for_all` and ask what it is protecting. It says the
children share state that cannot survive one of them restarting, which is a
real thing, and also a design smell worth a second look.

`:rest_for_one` is the interesting one: it says there is a dependency order
here, and everything after this child needs it. That is a map of your real
coupling, drawn by someone who had to think about it.

## Where the tree lies

The tree is a set of beliefs, and outages are where the beliefs were wrong. Two
that catch people:

**A process that restarts fine but reconnects slowly.** The supervisor's job is
done in microseconds; the connection pool underneath takes eight seconds. The
tree looks healthy and the system is not.

**`restart: :temporary` on something that matters.** It will not come back, ever,
and the supervisor will not tell you. This is correct for a one-shot task and
quietly catastrophic on a consumer.

Neither shows up in the diagram. Both show up in `:observer`, and in the first
five minutes of an incident, which is why I read the tree before I read
anything else.
