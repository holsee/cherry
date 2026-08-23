[
  name: "transit",
  version: "0.1.0",
  description: "Zero-JS page transitions: a post's title morphs from the index into its page with cross-document View Transitions, reading progress drawn by a scroll timeline; Gabarito.",
  cherry_contract: "1.1",
  # Transit ships its layout (the progress rule), the post template (the
  # rail) and the post_list template (named titles). Everything else
  # resolves to the default theme's copy (contract 1.1). No script.
  inherit_templates: true,
  templates: [
    layout: [
      assigns: [:site, :inner, :page_title, :head_extra, :nav, :search, :page_class],
      doc: "Outer HTML shell wrapped around every rendered page."
    ],
    page: [
      assigns: [:site, :doc],
      doc: "A freeform page from the pages collection."
    ],
    post: [
      assigns: [:site, :doc],
      doc: "A single blog post with title, date, and tags."
    ],
    post_list: [
      assigns: [:site, :posts],
      doc: "Reverse-chronological index of published posts."
    ],
    tag: [
      assigns: [:site, :tag, :posts, :story_href],
      doc: "Published posts carrying one tag; links to the tag's story when one exists."
    ],
    portfolio_timeline: [
      assigns: [:site, :portfolio, :cv_href],
      doc:
        "The timeline mode of the profile: dated entries, open source; " <>
          "cv_href links the switcher back to the CV view when public."
    ],
    story: [
      assigns: [:site, :tag, :portfolio, :posts],
      doc: "One tag across the whole story: portfolio entries plus blog posts."
    ],
    cv: [
      assigns: [:site, :cv],
      doc: "The employer-shaped CV: cv-curated entries in the careers layout, print-first."
    ],
    not_found: [
      assigns: [:site],
      doc: "The 404 page."
    ]
  ],
  # The token manifest is the theme's public styling API. `default:` is
  # the light value; `dark:` is the dark rendition of the same token
  # (the two halves of the light-dark() pair in site.css). Tokens
  # without `dark:` are rendition-independent.
  tokens: [
    "--color-bg": [default: "#fbfbf9", dark: "#0f1216", doc: "Page background."],
    "--color-surface": [default: "#f0f0ec", dark: "#171b21", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#101418", dark: "#e8eaee", doc: "Body text."],
    "--color-muted": [default: "#586069", dark: "#9aa3ad", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#d9dad4", dark: "#2a3038", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#0b5fff", dark: "#6ea8ff", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#0747c4", dark: "#9cc2ff", doc: "Hover/active accent."],
    "--color-selection": [default: "#d6e3ff", dark: "#1c3563", doc: "Text selection ground."],
    "--syn-keyword": [default: "#0b5fff", dark: "#6ea8ff", doc: "Syntax: keywords."],
    "--syn-string": [default: "#157347", dark: "#62d394", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7a8088", dark: "#6f7780", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#8a2ebf", dark: "#cf9bff", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#c2410c", dark: "#ffa366", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#0a6f8f", dark: "#66c9ea", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#101418", dark: "#e8eaee", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#586069", dark: "#9aa3ad", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "'Gabarito', system-ui, 'Segoe UI', Roboto, sans-serif", doc: "Reading and display face (Gabarito, self-hosted 30 KB latin subset, OFL)."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "40rem", doc: "Reading column width."]
  ]
]
