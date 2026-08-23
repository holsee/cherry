[
  name: "desktop",
  version: "0.1.0",
  description: "The retro OS, played straight: a window with a title bar and gadgets, bevelled controls, a Finder list view for the index, a dialog for 404; Pixelify Sans chrome over the system stack.",
  cherry_contract: "1.1",
  # Desktop ships its layout (the window), the post_list template (the list view) and the not_found template (the dialog). Everything else resolves to the default theme's copy (contract 1.1). No script of its own.
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
    "--color-bg": [default: "#ffffff", dark: "#1c1c1e", doc: "Page background."],
    "--color-surface": [default: "#d6d6d6", dark: "#353538", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#000000", dark: "#ececec", doc: "Body text."],
    "--color-muted": [default: "#4d4d4d", dark: "#b0b0b4", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#9a9a9a", dark: "#6b6b70", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#1b2fa8", dark: "#7fa2ff", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#101f7a", dark: "#a9c0ff", doc: "Hover/active accent."],
    "--color-selection": [default: "#b8c2ff", dark: "#2e3c7a", doc: "Text selection ground."],
    "--syn-keyword": [default: "#1b2fa8", dark: "#7fa2ff", doc: "Syntax: keywords."],
    "--syn-string": [default: "#006b3c", dark: "#6fd39a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#6b6b6b", dark: "#8a8a90", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#7a1fa2", dark: "#d2a0ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#b3261e", dark: "#ff9d8a", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#0a6a8a", dark: "#6fcbe8", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#000000", dark: "#ececec", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#4d4d4d", dark: "#b0b0b4", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "system-ui, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif", doc: "Reading face: the system stack. The chrome uses Pixelify Sans."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "42rem", doc: "Reading column width."]
  ]
]
