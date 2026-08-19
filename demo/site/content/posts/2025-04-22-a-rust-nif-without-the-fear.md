---
title: "A Rust NIF Without the Fear"
tags: [elixir, rust, nif]
description: "A NIF can take down the whole VM. Here is the small set of habits that keep that from being your problem."
---

The received wisdom about NIFs is that they can bring down the entire VM, which
is true, and that you should therefore avoid them, which does not follow.

We needed SimHash over a few million documents. In pure Elixir it was about
40ms per document, which was not going to work. In Rust, via
[Rustler](https://github.com/rusterlium/rustler), it was under a millisecond.
That is the kind of gap worth taking a risk for — provided you know which risks
you are taking.

## Rule one: never block a scheduler

A NIF that runs longer than about a millisecond starves the scheduler it runs
on. The whole preemption model of the BEAM assumes it can take a process off a
core; a native function ignores that assumption entirely.

Rustler makes the fix a single annotation:

```rust
#[rustler::nif(schedule = "DirtyCpu")]
fn simhash(text: &str) -> u64 {
    hash_tokens(tokenize(text))
}
```

Dirty schedulers exist precisely for work that cannot be preempted. Use them
for anything you have not personally measured under a millisecond, and measure
before you decide you are the exception.

## Rule two: do not panic

A Rust panic across the NIF boundary takes the VM with it. Every fallible path
must return an error term instead:

```rust
#[rustler::nif(schedule = "DirtyCpu")]
fn parse(input: &str) -> Result<Document, Error> {
    serde_json::from_str(input).map_err(|e| Error::Term(Box::new(e.to_string())))
}
```

Then the Elixir side gets an ordinary tagged tuple, and an ordinary supervisor
handles it:

```elixir
case Native.parse(payload) do
  {:ok, document} -> {:ok, document}
  {:error, reason} -> Logger.warning("unparseable payload: #{reason}"); :skip
end
```

Deny panics at the crate level and the compiler helps you keep the rule:

```toml
[lints.clippy]
unwrap_used = "deny"
expect_used = "deny"
```

## Rule three: keep the boundary boring

The NIF should do one computational thing and hold no state. No global
mutable structures, no threads you spawn yourself, no callbacks back into
Elixir. Everything that needs supervision, retries, or lifecycle belongs on the
BEAM side where those things already work.

::figure{src="/images/nif-boundary.svg" alt="Two boxes: the BEAM side holds supervision, retries and state; the Rust side holds one stateless computation" caption="The whole architecture, honestly."}

:::tip{title="Where the fear lives"}
Every NIF horror story is a violation of one of the three rules. Check the
story against the rules before checking your code against the story.
:::

Three rules, and the fear mostly goes away. What is left is a normal
engineering tradeoff: a build dependency and a compile step, in exchange for
two orders of magnitude.
