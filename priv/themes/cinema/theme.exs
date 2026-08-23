[
  name: "cinema",
  version: "0.1.0",
  description:
    "A film opening: a looping video background under the home title, a transparent mast, Big Shoulders Display over Manrope.",
  cherry_contract: "1.1",
  # Cinema ships its layout (the home-aware mast) and the page template
  # (the video hero). Everything else resolves to the default theme's
  # copy (contract 1.1). The film (assets/hero.mp4, 200 KB, 16 s loop,
  # silent) and its poster are theme assets.
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
    "--color-bg": [default: "#f2f2f2", dark: "#0a0a0a", doc: "Page background."],
    "--color-surface": [
      default: "#e8e8e8",
      dark: "#161616",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#111111", dark: "#f0f0f0", doc: "Body text."],
    "--color-muted": [
      default: "#5a5a5a",
      dark: "#9a9a9a",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#d8d8d8",
      dark: "#262626",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#c8102e", dark: "#ff3b4e", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#960b22", dark: "#ff7a87", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffd6dc", dark: "#4a1219", doc: "Text selection ground."],
    "--syn-keyword": [default: "#c8102e", dark: "#ff3b4e", doc: "Syntax: keywords."],
    "--syn-string": [default: "#1f6f4a", dark: "#7fd9a8", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#808080", dark: "#7a7a7a", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6a2fb8", dark: "#c9a6ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#1a55b8",
      dark: "#8db8ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#a05a00",
      dark: "#ffb06a",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#111111",
      dark: "#f0f0f0",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5a5a5a",
      dark: "#9a9a9a",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Manrope', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc:
        "Reading face (Manrope, self-hosted 21 KB latin subset, OFL). Titles use Big Shoulders Display (24 KB)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "44rem", doc: "Reading column width."]
  ]
]
