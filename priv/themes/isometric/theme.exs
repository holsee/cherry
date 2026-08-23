[
  name: "isometric",
  version: "0.1.0",
  description:
    "A product site: left rail navigation over an animated isometric grid floor, teal on graphite, Sora throughout - all CSS.",
  cherry_contract: "1.1",
  # Isometric ships no templates of its own: the rail layout and the
  # grid floor are pure CSS on the default theme's markup. Every declared
  # template resolves to the default theme's copy (contract 1.1).
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
    "--color-bg": [default: "#f4f7fb", dark: "#0a0f14", doc: "Page background."],
    "--color-surface": [
      default: "#e9eef5",
      dark: "#121a22",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#0f1720", dark: "#e4ecf3", doc: "Body text."],
    "--color-muted": [
      default: "#55657a",
      dark: "#92a3b5",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#d6dde8",
      dark: "#1f2b38",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#0f766e", dark: "#2dd4bf", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#0b5a54", dark: "#7ee8da", doc: "Hover/active accent."],
    "--color-selection": [default: "#c8ece8", dark: "#12403b", doc: "Text selection ground."],
    "--syn-keyword": [default: "#0f766e", dark: "#2dd4bf", doc: "Syntax: keywords."],
    "--syn-string": [default: "#a1431c", dark: "#ffb088", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7d8a9c", dark: "#7b8a9b", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#5b3bc4", dark: "#c4b0ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#1f5fc4",
      dark: "#8fb8ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#9b2c6f",
      dark: "#ff8ac7",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#0f1720",
      dark: "#e4ecf3",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#55657a",
      dark: "#92a3b5",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Sora', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc: "Reading and display face (Sora, self-hosted 32 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "44rem", doc: "Reading column width."]
  ]
]
