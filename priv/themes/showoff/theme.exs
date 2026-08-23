[
  name: "showoff",
  version: "0.1.0",
  description:
    "Everything at once: an aurora shader, a comet cursor, gradient type, tilting cards, a marquee, magnetic nav and scroll reveals - the theme that shows what the contract allows.",
  cherry_contract: "1.1",
  # Showoff ships its layout (aurora and comet canvases, the marquee, the
  # island), the page template (the home hero) and the post list (the
  # tilting cards). Everything else resolves to the default theme's copy
  # (contract 1.1).
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
    "--color-bg": [default: "#fdf7ff", dark: "#07030f", doc: "Page background."],
    "--color-surface": [
      default: "#f6edff",
      dark: "#140a24",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#1a0b2e", dark: "#f6efff", doc: "Body text."],
    "--color-muted": [
      default: "#6b5a85",
      dark: "#b09fcf",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#e9dcf7",
      dark: "#2a1a45",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#e0107f", dark: "#ff4fa8", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#7c3aed", dark: "#b388ff", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffd2ea", dark: "#4a1838", doc: "Text selection ground."],
    "--syn-keyword": [default: "#e0107f", dark: "#ff4fa8", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0d8a6a", dark: "#5fe3bf", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#8f82a8", dark: "#8a7da6", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#7c3aed", dark: "#c4a6ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#0b6fd6",
      dark: "#7fc0ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#d9630a",
      dark: "#ffb15c",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#1a0b2e",
      dark: "#f6efff",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#6b5a85",
      dark: "#b09fcf",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif",
      doc:
        "Reading face (system sans, zero bytes). Display uses Unbounded (36 KB), ledes Instrument Serif italic (14 KB)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "46rem", doc: "Reading column width."]
  ]
]
