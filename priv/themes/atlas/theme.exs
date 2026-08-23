[
  name: "atlas",
  version: "0.1.0",
  description: "A survey sheet: the blog index is a map you pan and zoom, posts placed as cards in tag regions with a minimap; Geologica throughout.",
  cherry_contract: "1.1",
  # Atlas ships its layout (the island), the page template (the survey
  # title block on the home page) and the post_list template (the map).
  # Everything else resolves to the default theme's copy (contract 1.1).
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
    "--color-bg": [default: "#f4f6f2", dark: "#0b1417", doc: "Page background."],
    "--color-surface": [default: "#e9ede6", dark: "#122024", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#172221", dark: "#e3ebe9", doc: "Body text."],
    "--color-muted": [default: "#56676a", dark: "#8fa3a3", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#cfd7d1", dark: "#22353a", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#0b6e6e", dark: "#5ad1c4", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#075353", dark: "#8fe6dc", doc: "Hover/active accent."],
    "--color-selection": [default: "#cfe9e6", dark: "#153e3d", doc: "Text selection ground."],
    "--syn-keyword": [default: "#0b6e6e", dark: "#5ad1c4", doc: "Syntax: keywords."],
    "--syn-string": [default: "#7a5a00", dark: "#e4c46a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7d8a8a", dark: "#6f8484", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#8a2f7a", dark: "#e49ad8", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#b4461a", dark: "#ffa270", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#1d5ea8", dark: "#7fb7ff", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#172221", dark: "#e3ebe9", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#56676a", dark: "#8fa3a3", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "'Geologica', system-ui, 'Segoe UI', Roboto, sans-serif", doc: "Reading and display face (Geologica, self-hosted 22 KB latin subset, OFL)."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "42rem", doc: "Reading column width."]
  ]
]
