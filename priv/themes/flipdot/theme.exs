[
  name: "flipdot",
  version: "0.1.0",
  description: "The departure board: titles flip in character by character, the blog index is the board, Doto's dot-matrix face on a dot-grid ground.",
  cherry_contract: "1.1",
  # Flipdot ships its layout (the station sign and the island) and the
  # post_list template (the board). Everything else resolves to the default
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
    "--color-bg": [default: "#f2efe6", dark: "#0a0a0a", doc: "Page background."],
    "--color-surface": [default: "#e7e3d7", dark: "#161512", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#1a1915", dark: "#f2e7cf", doc: "Body text."],
    "--color-muted": [default: "#5f5c52", dark: "#a39a82", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#cfcabb", dark: "#2b2a25", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#b2570a", dark: "#ffb020", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#8e4406", dark: "#ffc85c", doc: "Hover/active accent."],
    "--color-selection": [default: "#f5d9b8", dark: "#4a3408", doc: "Text selection ground."],
    "--syn-keyword": [default: "#b2570a", dark: "#ffb020", doc: "Syntax: keywords."],
    "--syn-string": [default: "#256b3a", dark: "#8fd88a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#847f72", dark: "#7d776a", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#7a3fa0", dark: "#d9a4ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#a11f1f", dark: "#ff8a5b", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#1d5f8a", dark: "#7fc9ff", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#1a1915", dark: "#f2e7cf", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#5f5c52", dark: "#a39a82", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Reading face: the system mono. Display and structure use Doto via --font-display."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "40rem", doc: "Reading column width."]
  ]
]
