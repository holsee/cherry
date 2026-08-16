---
title: "Event Sourcing Taught Me to Delete Code"
tags: [event-sourcing, design, elixir]
description: "The best thing event sourcing did for our codebase was make a whole category of defensive code obviously unnecessary."
---

I came to event sourcing expecting an audit log and got something more useful:
a reason to delete about a third of the inventory service.

## The code that went away

The old service had a table of stock levels and a great deal of code protecting
it. Compensating updates when a shipment was cancelled. A nightly reconciliation
job. A `stock_adjustments` table nobody could explain, holding rows that existed
only to correct earlier rows.

All of that was there because the current level was the only thing we stored.
When it went wrong, we had no way to ask *how*, so we wrote code to guess.

Storing decisions instead of state removed the guessing:

```elixir
defmodule Inventory.Events do
  defstruct StockReceived, [:sku, :quantity, :received_at, :purchase_order]
  defstruct StockPicked, [:sku, :quantity, :picked_at, :order_id]
  defstruct StockWrittenOff, [:sku, :quantity, :reason, :approved_by]
end
```

The level is now a fold:

```elixir
def level(sku) do
  sku
  |> Store.stream()
  |> Enum.reduce(0, fn
    %StockReceived{quantity: n}, level -> level + n
    %StockPicked{quantity: n}, level -> level - n
    %StockWrittenOff{quantity: n}, level -> level - n
  end)
end
```

The reconciliation job had nothing left to reconcile. The adjustments table
became a write-off event with a `reason` and an `approved_by`, which is what
everyone had wanted from it in the first place.

## What it did not fix

It is worth being clear about what event sourcing cost us, because the posts
that skip this part are the ones that get people into trouble.

**Versioning is forever.** The moment an event is persisted, its shape is a
public API. We now write upcasters, and we treat an event struct with the same
care as a database migration.

**Projections drift.** Every read model is eventually consistent with the
stream, and every part of the UI that pretended otherwise had to learn to say
"pending".

**Streams grow.** A fold over five years of movements for a fast-moving SKU is
not free. Snapshots solve it, and snapshots are cache invalidation wearing a
hat.

Those are real costs. I would pay them again for the deletions alone. The
service went from a thing we were afraid to touch on a Friday to one where the
question "how did this SKU get to negative four" has a literal answer.
