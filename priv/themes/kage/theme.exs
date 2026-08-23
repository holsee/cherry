[
  name: "kage",
  version: "0.1.0",
  description:
    "Cinema: a dark-first scroll of scenes - every block rises into view, the mast hides as you read, a progress hairline - Instrument Serif italic over Hanken Grotesk.",
  cherry_contract: "1.1",
  # Kage ships its layout (the progress hairline, the scenes island) and
  # the page template (the home title card). Everything else resolves to
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
    "--color-bg": [default: "#f4f2ec", dark: "#0b0b0c", doc: "Page background."],
    "--color-surface": [
      default: "#ebe8df",
      dark: "#151516",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#141413", dark: "#ecebe6", doc: "Body text."],
    "--color-muted": [
      default: "#5f5c55",
      dark: "#9b9991",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#dcd8cc",
      dark: "#26262a",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#8a6a1f", dark: "#c9a45c", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#6a4f12", dark: "#e3c484", doc: "Hover/active accent."],
    "--color-selection": [default: "#efe2bb", dark: "#3d3320", doc: "Text selection ground."],
    "--syn-keyword": [default: "#8a6a1f", dark: "#c9a45c", doc: "Syntax: keywords."],
    "--syn-string": [default: "#2f6b4a", dark: "#8fd0a8", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#8a877e", dark: "#76756f", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6a3f9e", dark: "#c6a8ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#1f5a9e",
      dark: "#8ab8ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#9a3c2a",
      dark: "#ff9a86",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#141413",
      dark: "#ecebe6",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5f5c55",
      dark: "#9b9991",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Hanken Grotesk', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc:
        "Reading face (Hanken Grotesk, self-hosted 27 KB latin subset, OFL). Titles use Instrument Serif (28 KB)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "40rem", doc: "Reading column width."]
  ]
]
