# Site configuration — every key is documented in Cherry's Site schema.
[
  title: "Juno Vale",
  # Set this to the site's real URL before deploying: canonical links,
  # feeds, and sitemap all derive from it.
  url: "https://junovale.example",
  description: "Notes on the BEAM, backpressure, and the long tail of distributed systems.",
  author: "Juno Vale",
  search: "cherry",
  # Written by `cherry config tokens.--color-accent ...` (GUIDE §10): the
  # default theme with its accent moved to violet, no CSS involved. A
  # light-dark() value carries both renditions in one override.
  tokens: [
    "--color-accent": "light-dark(#7c3aed, #a78bfa)",
    "--color-accent-strong": "light-dark(#5b21b6, #c4b5fd)"
  ]
]
