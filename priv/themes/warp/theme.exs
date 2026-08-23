[
  name: "warp",
  version: "0.1.0",
  description:
    "Velocity: a WebGL warp field of light streaks under a transparent mast and a banner title on every page, set in Syne.",
  cherry_contract: "1.1",
  # Warp ships only its layout: the field canvas and its island. Every
  # other declared template resolves to the default theme's copy
  # (contract 1.1); the band title is the default template's own h1,
  # planted in the field by CSS.
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
    "--color-bg": [default: "#fbf7f2", dark: "#08060f", doc: "Page background."],
    "--color-surface": [
      default: "#f2ece4",
      dark: "#130f1d",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#1c1520", dark: "#f1ebf5", doc: "Body text."],
    "--color-muted": [
      default: "#6b5f70",
      dark: "#a79db0",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#e6ddd4",
      dark: "#261f33",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#d4461c", dark: "#ff7a3d", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#a83512", dark: "#ffa071", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffd9c7", dark: "#4a2318", doc: "Text selection ground."],
    "--syn-keyword": [default: "#d4461c", dark: "#ff7a3d", doc: "Syntax: keywords."],
    "--syn-string": [default: "#1d6f5c", dark: "#5fdcbf", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#8a7f8f", dark: "#8c829a", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#7c2ebf", dark: "#cfa2ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#0b5fb0",
      dark: "#7fb8ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#9c5a00",
      dark: "#ffc46b",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#1c1520",
      dark: "#f1ebf5",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#6b5f70",
      dark: "#a79db0",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', sans-serif",
      doc:
        "Reading face (system sans, zero bytes). Titles and the mast use Syne (self-hosted 30 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "46rem", doc: "Reading column width."]
  ]
]
