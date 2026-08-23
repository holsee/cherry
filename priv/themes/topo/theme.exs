[
  name: "topo",
  version: "0.1.0",
  description: "Contour lines: a drifting marching-squares relief field across the page that clears around the reading column; Alegreya and Alegreya Sans.",
  cherry_contract: "1.1",
  # Topo ships only its layout (the relief canvas, the island, the scale
  # bar). Everything else resolves to the default theme's copy (contract 1.1).
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
    "--color-bg": [default: "#eef0e4", dark: "#151a12", doc: "Page background."],
    "--color-surface": [default: "#e3e6d6", dark: "#1d2419", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#2b2418", dark: "#ece8da", doc: "Body text."],
    "--color-muted": [default: "#6b6350", dark: "#a6a18c", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#cfd2c0", dark: "#2e3628", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#b5451b", dark: "#e0895a", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#8f3514", dark: "#f0aa84", doc: "Hover/active accent."],
    "--color-selection": [default: "#f3d7c8", dark: "#4a3322", doc: "Text selection ground."],
    "--syn-keyword": [default: "#b5451b", dark: "#e0895a", doc: "Syntax: keywords."],
    "--syn-string": [default: "#3e6b2a", dark: "#9ccf7e", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#87846f", dark: "#7c8270", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6a3d9a", dark: "#c8a6f0", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#9a5f00", dark: "#f0c070", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#2a5f7a", dark: "#7fc4d6", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#2b2418", dark: "#ece8da", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#6b6350", dark: "#a6a18c", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "'Alegreya', Georgia, 'Times New Roman', serif", doc: "Reading face (Alegreya, self-hosted latin subsets, OFL). Structure uses Alegreya Sans."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "40rem", doc: "Reading column width."]
  ]
]
