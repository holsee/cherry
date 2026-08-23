[
  name: "bento",
  version: "0.1.0",
  description:
    "Tiles: a bento grid for the home and the index - rounded, soft-shadowed, the first post spanning two columns - Onest at every weight.",
  cherry_contract: "1.1",
  # Bento ships its layout (the nav tiles on the home page), the page
  # template (the home tiles) and the post list (the index tiles).
  # Everything else resolves to the default theme's copy (contract 1.1).
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
    "--color-bg": [default: "#f5f5f7", dark: "#000000", doc: "Page background."],
    "--color-surface": [
      default: "#ffffff",
      dark: "#1c1c1e",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#1d1d1f", dark: "#f5f5f7", doc: "Body text."],
    "--color-muted": [
      default: "#6e6e73",
      dark: "#a1a1a6",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#e5e5ea",
      dark: "#2c2c2e",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#0066cc", dark: "#2997ff", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#004a99", dark: "#6fb8ff", doc: "Hover/active accent."],
    "--color-selection": [default: "#d2e6ff", dark: "#143a66", doc: "Text selection ground."],
    "--syn-keyword": [default: "#0066cc", dark: "#2997ff", doc: "Syntax: keywords."],
    "--syn-string": [default: "#1f7a4d", dark: "#6fd39a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#8e8e93", dark: "#8e8e93", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6e34c9", dark: "#c3a3ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#c2410c",
      dark: "#ffa46b",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#a0127a",
      dark: "#ff8ad4",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#1d1d1f",
      dark: "#f5f5f7",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#6e6e73",
      dark: "#a1a1a6",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Onest', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc: "Reading and display face (Onest, self-hosted 30 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "44rem", doc: "Reading column width."]
  ]
]
