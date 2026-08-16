---
title: "The Kata I Keep Coming Back To"
tags: [testing, kata, elixir]
description: "Parsing dates from strings looks trivial for about four minutes, which is what makes it a good exercise."
---

Every so often I redo the string-date-parsing kata. Not because I have
forgotten how to parse a date, but because it is the shortest exercise I know
that punishes vagueness.

The brief: given a string, return a date. Start with `"2025-10-15"`.

```elixir
def parse(input), do: Date.from_iso8601(input)
```

Four minutes in, you are done. Then the examples arrive.

## The examples

```
"2025-10-15"     the easy one
"15/10/2025"     day first
"10/15/2025"     month first
"15 Oct 2025"    names, abbreviated
"October 15th"   no year, ordinal suffix
"yesterday"      relative to what?
"" and nil       the caller has a bug
```

Nothing here is hard. What is hard is that `"01/02/2025"` is genuinely
ambiguous, and you cannot resolve it inside the parser. It is January 2nd or
February 1st depending on a fact the string does not contain.

The kata's real lesson is that this is where the design happens. Every attempt
I make eventually arrives at the same shape: the ambiguity becomes a parameter.

```elixir
@type locale_order :: :day_first | :month_first

@spec parse(String.t(), keyword()) :: {:ok, Date.t()} | {:error, term()}
def parse(input, opts \\ []) do
  order = Keyword.get(opts, :order, :day_first)
  today = Keyword.get(opts, :today, Date.utc_today())

  input
  |> String.trim()
  |> attempt([&iso/1, &numeric(&1, order), &named/1, &relative(&1, today)])
end
```

Two details that took me several attempts to arrive at:

**`today` is an argument.** A parser that reads the clock cannot be tested for
`"yesterday"` without either freezing time or accepting flaky tests. Passing the
date in makes the whole thing a pure function, and the tests get boring.

**The strategies are a list.** Each one returns `{:ok, date}` or `:error`, and
`attempt/2` walks them in order. Adding a format is adding a function, and the
precedence is visible in one place rather than distributed across a `cond`.

## Why it stays useful

Most katas train you to write code. This one trains you to notice that the
requirements are underspecified, and to put the missing decision somewhere the
caller can see it. That skill transfers to almost everything, which is more
than I can say for FizzBuzz.
