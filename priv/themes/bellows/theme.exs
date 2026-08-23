[
  name: "bellows",
  version: "0.1.0",
  description: "Type that breathes: Anybody's width axis is bound to scroll, so every title widens and narrows as it passes; pure CSS, no script.",
  cherry_contract: "1.1",
  # Bellows ships only the page template (the home word). Everything else
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
    "--color-bg": [default: "#f6f4ee", dark: "#0e1226", doc: "Page background."],
    "--color-surface": [default: "#ebe8df", dark: "#171c35", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#141826", dark: "#eef0f7", doc: "Body text."],
    "--color-muted": [default: "#5a5f73", dark: "#a2a8c2", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#d5d2c7", dark: "#2b3152", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#d7431b", dark: "#ff7a4d", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#b13413", dark: "#ffa07f", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffd9cc", dark: "#4a2b1f", doc: "Text selection ground."],
    "--syn-keyword": [default: "#d7431b", dark: "#ff7a4d", doc: "Syntax: keywords."],
    "--syn-string": [default: "#1f6f3a", dark: "#74d99a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7e8294", dark: "#7a80a0", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#3c47b8", dark: "#a3acff", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#9a4f00", dark: "#ffc36b", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#1d6f8c", dark: "#6fd0ee", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#141826", dark: "#eef0f7", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#5a5f73", dark: "#a2a8c2", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "'Anybody', system-ui, 'Segoe UI', Roboto, sans-serif", doc: "The one face (Anybody, variable width and weight, self-hosted 50 KB latin subset, OFL)."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "40rem", doc: "Reading column width."]
  ]
]
