[
  name: "constellation",
  version: "0.1.0",
  description:
    "An observatory: a living constellation field behind a centred mast and a full-viewport home hero, Unbounded display over Geist.",
  cherry_contract: "1.1",
  # Constellation ships its layout (the field canvas, the centred mast)
  # and the page template (the full-viewport home hero). Everything else
  # resolves to the default theme's copy (contract 1.1).
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
    "--color-bg": [default: "#f7f8fc", dark: "#070a14", doc: "Page background."],
    "--color-surface": [
      default: "#eceef6",
      dark: "#0f1424",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#141a2e", dark: "#e6e9f5", doc: "Body text."],
    "--color-muted": [
      default: "#5b6382",
      dark: "#98a0bd",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#dde0ec",
      dark: "#1e2640",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#2447d1", dark: "#7ea0ff", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#1a35a8", dark: "#a9bfff", doc: "Hover/active accent."],
    "--color-selection": [default: "#dbe2ff", dark: "#1e2a5c", doc: "Text selection ground."],
    "--syn-keyword": [default: "#2447d1", dark: "#7ea0ff", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0e7c6b", dark: "#4fd1b5", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#737a95", dark: "#7c849e", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#8a36c9", dark: "#c69cff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#c2410c",
      dark: "#ffa46b",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#0f6e9e",
      dark: "#63c4f0",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#141a2e",
      dark: "#e6e9f5",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5b6382",
      dark: "#98a0bd",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Geist', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc:
        "Reading face (Geist, self-hosted 17 KB latin subset, OFL). Titles use Unbounded via --font-display."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "44rem", doc: "Reading column width."]
  ]
]
