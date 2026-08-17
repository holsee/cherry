---
title: "A Year of Property Testing"
tags: [testing, property-testing, elixir]
description: "What a year of stream_data actually caught, and the properties that turned out to be worth writing."
---

A year ago I put property tests into a codebase that already had good
example-based coverage, mostly to find out whether the enthusiasm was
warranted. Here is what they actually caught.

## The score

Eleven genuine defects. Nine of them were in code that parsed, normalised, or
merged data — the boring seams between systems. Two were in domain logic. None
were in the places I expected.

The single most productive property was also the dullest:

```elixir
property "a document survives a round trip" do
  check all document <- document_generator() do
    assert document == document |> Codec.encode() |> Codec.decode!()
  end
end
```

That one found four bugs on its own: an empty tag list that came back as `nil`,
a timestamp that lost microseconds, a nested map whose key order the encoder
depended on, and a Unicode normalisation difference that only appeared for
strings containing combining characters.

Every one of those would have been possible to write as an example test. The
point is that nobody did, for years, because nobody thought of them.

## The properties worth writing

Four shapes covered nearly everything useful:

**Round trips.** `decode(encode(x)) == x`. Cheap, and it finds encoder bugs
example tests never reach.

**Invariants.** Something that must be true of every output, regardless of
input. Ours: a stock projection never disagrees with a fold over the same
events.

**Oracles.** A second, slower, obviously correct implementation to compare
against. We had a naive O(n²) deduplicator; the fast one had a bug at exactly
the block boundary.

**Idempotence.** `f(f(x)) == f(x)` for anything that normalises. This found a
sanitiser that stripped one layer of nesting per call.

## Where they were not worth it

I wrote properties for our HTTP handlers and deleted them a month later. The
generators were more code than the handlers, most of the interesting behaviour
was in the dependencies, and every failure took twenty minutes to interpret.
Example tests read better there and caught the same things.

I also stopped trying to shrink my way to understanding. `stream_data`'s
shrinking is good, but a minimal counterexample for a complex generator is
still a puzzle. Now, when a property fails, my first move is to write the
shrunk case down as an ordinary test with a name. The property found it; the
example test explains it.

That split — properties to search, examples to document — is the habit I would
keep if I had to give up everything else from this year.
