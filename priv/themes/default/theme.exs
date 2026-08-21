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
    "--color-bg": [default: "#ffffff", dark: "#15171b", doc: "Page background."],
    "--color-surface": [
      default: "#f6f6f4",
      dark: "#1d2025",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#1f2328", dark: "#e3e1dd", doc: "Body text."],
    "--color-muted": [
      default: "#59626c",
      dark: "#a2a6ad",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#e4e4e1",
      dark: "#2a2e35",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#b3173e", dark: "#f4718c", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#8f1132", dark: "#ff93a8", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffdce2", dark: "#4a2430", doc: "Text selection ground."],
    "--syn-keyword": [default: "#b3173e", dark: "#f4718c", doc: "Syntax: keywords."],
    "--syn-string": [default: "#0a3069", dark: "#a5d6ff", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#5d6570", dark: "#8b949e", doc: "Syntax: comments (italic)."],
    "--syn-function": [
      default: "#6639ba",
      dark: "#d2a8ff",
      doc: "Syntax: functions and methods."
    ],
    "--syn-constant": [
      default: "#0550ae",
      dark: "#79c0ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#953800",
      dark: "#ffa657",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#1f2328",
      dark: "#e3e1dd",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#59626c",
      dark: "#a2a6ad",
      doc: "Syntax: punctuation and operators."
    ],
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
