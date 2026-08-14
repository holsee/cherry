[
  name: "default",
  version: "0.1.0",
  description: "Cherry's default theme — typography-first, light/dark via tokens.",
  cherry_contract: "1.0",
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
    "--color-bg": [default: "#ffffff", doc: "Page background."],
    "--color-surface": [default: "#f6f6f4", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#1f2328", doc: "Body text."],
    "--color-muted": [default: "#59626c", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#e4e4e1", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#b3173e", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#8f1132", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffdce2", doc: "Text selection ground."],
    "--syn-keyword": [default: "#b3173e", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0a3069", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#5d6570", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6639ba", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#0550ae", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#953800", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#1f2328", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#59626c", doc: "Syntax: punctuation and operators."],
    "--font-prose": [
      default: "Charter, 'Bitstream Charter', 'Sitka Text', Cambria, Georgia, serif",
      doc: "Long-form reading face (system stack, zero bytes)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "42rem", doc: "Reading column width (~66ch)."]
  ]
]
