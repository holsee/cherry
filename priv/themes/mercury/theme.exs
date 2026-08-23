[
  name: "mercury",
  version: "0.1.0",
  description: "Liquid metal: a WebGL chrome surface that deforms under the pointer behind the mast, titles filled with the same chrome; Dela Gothic One over Lexend.",
  cherry_contract: "1.1",
  # Mercury ships its layout (the chrome band canvas and the island) and the
  # page template (the home title cast in chrome). Everything else resolves
  # to the default theme's copy (contract 1.1).
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
    "--color-bg": [default: "#f3f3f5", dark: "#08090c", doc: "Page background."],
    "--color-surface": [default: "#ffffff", dark: "#1c1e25", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#121316", dark: "#eceef3", doc: "Body text."],
    "--color-muted": [default: "#5c5f68", dark: "#9a9eab", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#d4d5db", dark: "#2a2d37", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#4d3bd6", dark: "#a99bff", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#3a2ab0", dark: "#c9c0ff", doc: "Hover/active accent."],
    "--color-selection": [default: "#dcd8ff", dark: "#2f2860", doc: "Text selection ground."],
    "--syn-keyword": [default: "#4d3bd6", dark: "#a99bff", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0f7a5a", dark: "#5fd3a8", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7f828c", dark: "#6f7380", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#b0268a", dark: "#f08ad2", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#b85a00", dark: "#ffb36b", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#106e9a", dark: "#6ec6ee", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#121316", dark: "#eceef3", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#5c5f68", dark: "#9a9eab", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "'Lexend', system-ui, 'Segoe UI', Roboto, sans-serif", doc: "Reading face (Lexend, self-hosted 25 KB latin subset, OFL). Display is Dela Gothic One."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "42rem", doc: "Reading column width."]
  ]
]
