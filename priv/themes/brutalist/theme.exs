[
  name: "brutalist",
  version: "0.1.0",
  description:
    "Raw: 3px black borders, Anton headlines the width of the page, a marquee ticker, a table for the index - blue links by day, hazard yellow by night.",
  cherry_contract: "1.1",
  # Brutalist ships its layout (the name box, ticker and nav row) and the
  # post list (the table). Everything else resolves to the default
  # theme's copy (contract 1.1).
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
    "--color-bg": [default: "#ffffff", dark: "#000000", doc: "Page background."],
    "--color-surface": [
      default: "#f2f2f2",
      dark: "#151515",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#000000", dark: "#ffffff", doc: "Body text."],
    "--color-muted": [
      default: "#444444",
      dark: "#b5b5b5",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#000000",
      dark: "#ffffff",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#0000ee", dark: "#ffe600", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#0000aa", dark: "#fff29a", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffe600", dark: "#0000ee", doc: "Text selection ground."],
    "--syn-keyword": [default: "#0000ee", dark: "#ffe600", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0a6b1a", dark: "#7dff8a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#6a6a6a", dark: "#8c8c8c", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#7a00b8", dark: "#d9a3ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#b80000",
      dark: "#ff7a7a",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#9a5000",
      dark: "#ffb070",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#000000",
      dark: "#ffffff",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#444444",
      dark: "#b5b5b5",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc:
        "Reading face (system mono, zero bytes). Headlines use Anton (self-hosted 9 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "52rem", doc: "Reading column width."]
  ]
]
