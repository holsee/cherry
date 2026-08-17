---
title: "simhash_ex"
repo: "https://github.com/junovale/simhash_ex"
role: author
tags: [elixir, rust, nif]
highlights:
  - "SimHash for Elixir via a Rustler NIF on dirty schedulers"
  - "Roughly 40x faster than the pure-Elixir implementation it replaced"
cv:
  include: true
  weight: 30
---

Near-duplicate detection over document sets, written after the pure-Elixir
version turned out to be the slowest part of an ingestion pipeline.
