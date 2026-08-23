[
  name: "erosion",
  version: "0.1.0",
  description:
    "Sediment: thousands of grains carried on a slow flow field behind a soft-serif magazine layout, verdigris on stone.",
  cherry_contract: "1.1",
  # Erosion ships its layout (the grain canvas and island) and the post
  # list (the two-column magazine index). Everything else resolves to
  # the default theme's copy (contract 1.1).
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
    "--color-bg": [default: "#f1f0ea", dark: "#0e1311", doc: "Page background."],
    "--color-surface": [
      default: "#e8e6dd",
      dark: "#161d1a",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#1f2422", dark: "#e3e4dc", doc: "Body text."],
    "--color-muted": [
      default: "#5f6863",
      dark: "#99a29c",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#d9d7cc",
      dark: "#243029",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#2e7264", dark: "#6fcfb6", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#1f5548", dark: "#9be3d0", doc: "Hover/active accent."],
    "--color-selection": [default: "#cfe6dd", dark: "#1f4a3e", doc: "Text selection ground."],
    "--syn-keyword": [default: "#2e7264", dark: "#6fcfb6", doc: "Syntax: keywords."],
    "--syn-string": [default: "#8a4b1f", dark: "#f0b27a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7d847f", dark: "#7f8a84", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6b3f9e", dark: "#c9a6ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#1f5aa6",
      dark: "#8ab8ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#9a3d3d",
      dark: "#ff9b9b",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#1f2422",
      dark: "#e3e4dc",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5f6863",
      dark: "#99a29c",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Fraunces', Charter, 'Iowan Old Style', Georgia, serif",
      doc: "Reading face (Fraunces, self-hosted 77 KB latin subsets upright + italic, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "48rem", doc: "Reading column width."]
  ]
]
