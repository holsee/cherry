[
  name: "cherrybomb",
  version: "0.1.0",
  description: "The brand theme — neon night wall by dark, poster paper by day.",
  cherry_contract: "1.0",
  templates: [
    layout: [
      assigns: [:site, :inner, :page_title, :head_extra, :nav, :search],
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
      assigns: [:site, :portfolio],
      doc: "The developer story: profile header, dated timeline, open source."
    ],
    story: [
      assigns: [:site, :tag, :portfolio, :posts],
      doc: "One tag across the whole story: portfolio entries plus blog posts."
    ],
    cv: [
      assigns: [:site, :cv],
      doc: "The employer-shaped CV: linear, dense, print-first."
    ],
    not_found: [
      assigns: [:site],
      doc: "The 404 page."
    ]
  ],
  # The token manifest is the theme's public styling API. Defaults are the
  # light rendition; the dark rendition redefines every color token.
  tokens: [
    "--color-bg": [default: "#fbf6f8", doc: "Page background (poster paper by day)."],
    "--color-surface": [default: "#f3e7ed", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#26141d", doc: "Body text."],
    "--color-muted": [default: "#6d5563", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#e6d2dc", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#c0134f", doc: "The hot pink: links, title stroke, glow."],
    "--color-accent-strong": [default: "#96063c", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffd3e0", doc: "Text selection ground."],
    "--syn-keyword": [default: "#c0134f", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0b7a5e", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#75616d", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6d3ac1", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#a55a00", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#0369a1", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#26141d", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#6d5563", doc: "Syntax: punctuation and operators."],
    "--font-prose": [
      default: "system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif",
      doc: "Reading face: the wall speaks sans (system stack, zero bytes)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "42rem", doc: "Reading column width (~66ch)."]
  ]
]
