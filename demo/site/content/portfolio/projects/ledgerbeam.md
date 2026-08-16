---
title: "Ledgerbeam"
status: active
start: 2023-03-06
links:
  - {label: Site, url: "https://ledgerbeam.example"}
tags: [elixir, event-sourcing, distributed-systems]
highlights:
  - "Event-sourced inventory for mid-size distributors"
  - "Rebuilt stock projections as a fold over movements, deleting the nightly reconciliation job"
  - "Ingestion pipeline sustained a 40x burst without shedding orders"
cv:
  include: true
  weight: 10
---

Event-sourced inventory for distributors who outgrew a spreadsheet but cannot
afford a six-month ERP migration.

The core is a movement stream per SKU — received, picked, written off,
transferred — with projections for the levels people actually query. The
interesting engineering is in ingestion: partner systems send the same shipment
two or three times, out of order, with fields that disagree, and the pipeline
has to arrive at one answer without dropping the disagreement on the floor.
