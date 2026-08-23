[
  name: "tideform",
  version: "0.1.0",
  description:
    "A horizon: four layers of procedural swell rolling under the mast of every page, sea-blue on salt, Schibsted Grotesk.",
  cherry_contract: "1.1",
  # Tideform ships only its layout: the tide band canvas and its island.
  # Every other declared template resolves to the default theme's copy
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
    "--color-bg": [default: "#f3f7f9", dark: "#061018", doc: "Page background."],
    "--color-surface": [
      default: "#e7eef3",
      dark: "#0e1b26",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#0f1b24", dark: "#e3edf4", doc: "Body text."],
    "--color-muted": [
      default: "#546674",
      dark: "#8fa3b3",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#d3dde5",
      dark: "#1c2e3c",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#0b5fa5", dark: "#5cb5ff", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#08457a", dark: "#93ceff", doc: "Hover/active accent."],
    "--color-selection": [default: "#cfe4f7", dark: "#16395a", doc: "Text selection ground."],
    "--syn-keyword": [default: "#0b5fa5", dark: "#5cb5ff", doc: "Syntax: keywords."],
    "--syn-string": [default: "#1b7a52", dark: "#6fd9a8", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7b8a96", dark: "#76899a", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6b3fc4", dark: "#c6a8ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#b0461a",
      dark: "#ffa477",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#9a2f7a",
      dark: "#ff8fd0",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#0f1b24",
      dark: "#e3edf4",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#546674",
      dark: "#8fa3b3",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Schibsted Grotesk', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc: "Reading and display face (Schibsted Grotesk, self-hosted 41 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "46rem", doc: "Reading column width."]
  ]
]
