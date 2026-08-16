---
title: "Tacto"
status: paused
start: 2024-08-12
end: 2025-11-30
links:
  - {label: Source, url: "https://github.com/junovale/tacto"}
tags: [rust, tui, tooling]
highlights:
  - "Terminal client for reading event streams live"
  - "Renders a supervision tree next to the stream it is producing"
---

A terminal UI for watching an event stream while it happens: filter by
aggregate, pin a stream, and see the projection lag update as events land.

Written in Rust because the render loop needed to stay smooth at a few thousand
events per second, and because I wanted to find out whether the terminal was a
reasonable place to put an operational tool. It is, up to the point where you
want to share what you are looking at.

Paused, not abandoned. It does what I need.
