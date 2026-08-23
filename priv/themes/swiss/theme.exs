[
  name: "swiss",
  version: "0.1.0",
  description: "International Typographic Style: a visible twelve-column grid, flush-left asymmetry, red, black and white, nothing else; Familjen Grotesk.",
  cherry_contract: "1.1",
  # Swiss ships its layout (the grid), the page template (the home
  # composition) and the post_list template (the table). Everything else
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
    "--color-bg": [default: "#ffffff", dark: "#000000", doc: "Page background."],
    "--color-surface": [default: "#f2f2f2", dark: "#161616", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#000000", dark: "#ffffff", doc: "Body text."],
    "--color-muted": [default: "#555555", dark: "#a8a8a8", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#d0d0d0", dark: "#333333", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#e2001a", dark: "#ff2d3f", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#b30014", dark: "#ff6b78", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffd5d9", dark: "#5a0d14", doc: "Text selection ground."],
    "--syn-keyword": [default: "#e2001a", dark: "#ff2d3f", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0a6b3a", dark: "#6fd39a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#777777", dark: "#8a8a8a", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#000000", dark: "#ffffff", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#9a3b00", dark: "#ffb36b", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#00507a", dark: "#7fc8ee", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#000000", dark: "#ffffff", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#555555", dark: "#a8a8a8", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "'Familjen Grotesk', Helvetica, Arial, sans-serif", doc: "The one face (Familjen Grotesk, self-hosted 15 KB latin subset, OFL)."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "40rem", doc: "Reading column width."]
  ]
]
