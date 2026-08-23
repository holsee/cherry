[
  name: "prism",
  version: "0.1.0",
  description: "Gradient-mesh atmosphere under glass — a live WebGL shader driven by the same tokens as the links.",
  cherry_contract: "1.1",
  # Prism ships exactly one template: its layout, which mounts the mesh
  # canvas and the prism-mesh island. Every other declared template
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
    "--color-bg": [default: "#fbfaff", dark: "#0b0d18", doc: "Page background."],
    "--color-surface": [
      default: "#f3f1fb",
      dark: "#151830",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#1e2138", dark: "#e2e3f2", doc: "Body text."],
    "--color-muted": [
      default: "#5d6280",
      dark: "#9ea3c0",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#e4e2f0",
      dark: "#272b4a",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#6d28d9", dark: "#a78bfa", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#501fae", dark: "#c4b5fd", doc: "Hover/active accent."],
    "--color-selection": [default: "#e9e2ff", dark: "#372a5e", doc: "Text selection ground."],
    "--syn-keyword": [default: "#6d28d9", dark: "#a78bfa", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0f766e", dark: "#5eead4", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#767b9c", dark: "#878da8", doc: "Syntax: comments (italic)."],
    "--syn-function": [
      default: "#a21caf",
      dark: "#e879f9",
      doc: "Syntax: functions and methods."
    ],
    "--syn-constant": [
      default: "#1d4ed8",
      dark: "#93bbfd",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#0e7490",
      dark: "#67e8f9",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#1e2138",
      dark: "#e2e3f2",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5d6280",
      dark: "#9ea3c0",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Instrument Sans', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc: "Reading face (Instrument Sans, self-hosted 56 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "42rem", doc: "Reading column width (~66ch)."]
  ]
]
