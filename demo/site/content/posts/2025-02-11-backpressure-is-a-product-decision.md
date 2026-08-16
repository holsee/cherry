---
title: "Backpressure Is a Product Decision"
tags: [elixir, broadway, backpressure]
description: "Every queue that fills up is answering a question somebody should have answered on purpose."
---

We spent a week tuning a Broadway pipeline that kept falling behind, and the
fix turned out not to be a number at all.

The pipeline ingested webhook deliveries from a payments provider. Under normal
load it kept up comfortably. During a merchant's flash sale it did not, and the
queue depth climbed until the delivery provider started retrying, which added
load, which climbed the queue further.

The instinct is to add concurrency:

```elixir
def start_link(_opts) do
  Broadway.start_link(__MODULE__,
    name: __MODULE__,
    producer: [module: {SQSProducer, []}, concurrency: 4],
    processors: [default: [concurrency: 80]]
  )
end
```

Eighty processors did make the queue drain. It also pushed the database to the
point where unrelated requests started timing out. We had not removed the
bottleneck, we had moved it somewhere with worse failure behaviour.

## The question nobody had asked

What should happen when deliveries arrive faster than we can durably record
them?

There are only a few honest answers, and each of them is a product decision:

- **Slow the producer down.** Correct when the upstream can wait. The payments
  provider retried with backoff, so it could.
- **Shed load.** Correct when late data is worthless. Ours was not.
- **Buffer, and accept that recovery takes time.** Correct when the burst is
  bounded and you can afford the storage.
- **Degrade the work itself** — record the delivery now, enrich it later.

We picked the last one, and the pipeline stopped being a tuning problem:

```elixir
@impl true
def handle_message(_processor, message, _context) do
  message
  |> Message.update_data(&Delivery.parse!/1)
  |> Message.put_batcher(:record)
end

@impl true
def handle_batch(:record, messages, _batch_info, _context) do
  messages
  |> Enum.map(& &1.data)
  |> Deliveries.insert_all()

  messages
end
```

Enrichment moved to a separate pipeline reading from the recorded rows, with
its own concurrency and its own failure domain. The write path got simple
enough that eight processors outperformed the eighty we had before.

## What the numbers were hiding

`concurrency:` looks like a performance knob and behaves like a policy. Setting
it high says "I would rather overwhelm my dependencies than fall behind."
Setting it low says the opposite. Neither is wrong, but you should be able to
say which one you meant, and why, without opening the dashboard.

The BEAM makes it unusually cheap to express any of these answers. It does not
tell you which one your product needs.
