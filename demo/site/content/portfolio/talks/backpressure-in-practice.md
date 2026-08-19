---
title: "Backpressure in Practice"
event: "ElixirConf EU"
date: 2025-05-15
slides: "https://junovale.example/slides/backpressure-in-practice"
tags: [elixir, broadway, backpressure]
highlights:
  - "Four honest answers to an overloaded queue, and how to choose between them"
  - "Why concurrency: is a policy setting wearing a performance costume"
cv:
  include: true
  weight: 20
---

A 30-minute version of the argument in
[Backpressure Is a Product Decision](/backpressure-is-a-product-decision/):
that tuning a pipeline is usually an attempt to avoid deciding what should
happen when you cannot keep up.

Live-demoed a Broadway pipeline under a synthetic burst, showing each of the
four strategies in turn and what each one does to the dependency downstream.

::video{youtube="q6Yr9DkTn2k" title="Backpressure in Practice — ElixirConf EU 2025"}
