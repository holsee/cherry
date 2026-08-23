[
  name: "sketchbook",
  version: "0.1.0",
  description: "Drawn by hand: wobbling rules and underlines that draw themselves as they scroll into view, paper grain, taped corners; Shantell Sans over Atkinson Hyperlegible Next.",
  cherry_contract: "1.1",
  # Sketchbook ships only its layout (the grain layer and the drawn baseline
  # under the mast). Everything else resolves to the default theme's copy
  # (contract 1.1). No script.
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
    "--color-bg": [default: "#fcfbf7", dark: "#1b1f22", doc: "Page background."],
    "--color-surface": [default: "#f1efe8", dark: "#252a2e", doc: "Raised ground: code blocks, inline code."],
    "--color-fg": [default: "#22252b", dark: "#eeeae0", doc: "Body text."],
    "--color-muted": [default: "#646a75", dark: "#a7aba8", doc: "Secondary text: metadata, nav, footer."],
    "--color-border": [default: "#d7d5cc", dark: "#3a4045", doc: "Hairline rules and control borders."],
    "--color-accent": [default: "#1f5fbf", dark: "#8ab4ff", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#174a96", dark: "#b3cdff", doc: "Hover/active accent."],
    "--color-selection": [default: "#d9e6fb", dark: "#2d4269", doc: "Text selection ground."],
    "--syn-keyword": [default: "#1f5fbf", dark: "#8ab4ff", doc: "Syntax: keywords."],
    "--syn-string": [default: "#2a7a4b", dark: "#8fd5a4", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#8a8e98", dark: "#7f8589", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#8a3fb5", dark: "#d4a6ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [default: "#c2511e", dark: "#ffab7a", doc: "Syntax: constants, numbers, booleans."],
    "--syn-type": [default: "#0f6e8c", dark: "#79cfe6", doc: "Syntax: types, modules, tags, attributes."],
    "--syn-variable": [default: "#22252b", dark: "#eeeae0", doc: "Syntax: variables and default code text."],
    "--syn-punct": [default: "#646a75", dark: "#a7aba8", doc: "Syntax: punctuation and operators."],
    "--font-prose": [default: "'Atkinson Hyperlegible Next', system-ui, 'Segoe UI', Roboto, sans-serif", doc: "Reading face (Atkinson Hyperlegible Next, self-hosted latin subsets, OFL). Display uses Shantell Sans."],
    "--font-mono": [default: "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace", doc: "Structure and code face."],
    "--measure": [default: "40rem", doc: "Reading column width."]
  ]
]
