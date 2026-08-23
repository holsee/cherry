[
  name: "loom",
  version: "0.1.0",
  description: "Woven cloth: a verlet cloth hangs behind the mast and ripples under the pointer, warp-thread rules, a weaver's draft for the index; Young Serif over Atkinson Hyperlegible Next.",
  cherry_contract: "1.1",
  # Loom ships its layout (the cloth band and the island) and the post_list
  # template (the weaver's draft). Everything else resolves to the default
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
    "--color-bg": [default: "#f4efe6", dark: "#121826", doc: "Page background."],
    "--color-surface": [default: "#eae3d6", dark: "#1a2233", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#23201c", dark: "#ece6da", doc: "Body text."],
    "--color-muted": [default: "#6a6259", dark: "#a39c90", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#d6cdbf", dark: "#2c3649", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#a8322b", dark: "#e8705f", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#86261f", dark: "#f39a8c", doc: "Hover/active accent."],
    "--color-selection": [default: "#f1d5cf", dark: "#4a2a2a", doc: "Text selection ground."],
    "--syn-keyword": [default: "#a8322b", dark: "#e8705f", doc: "Syntax: keywords."],
    "--syn-string": [default: "#2f6b4a", dark: "#8ccf9f", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#8a8174", dark: "#77808f", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#5b3f9e", dark: "#c3a9ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#9a5a0a", dark: "#f0b56a", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#2d5f8a", dark: "#7cbbe8", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#23201c", dark: "#ece6da", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#6a6259", dark: "#a39c90", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "'Atkinson Hyperlegible Next', system-ui, 'Segoe UI', Roboto, sans-serif", doc: "Reading face (Atkinson Hyperlegible Next, self-hosted latin subsets, OFL). Headings use Young Serif."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "42rem", doc: "Reading column width."]
  ]
]
