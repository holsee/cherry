[
  name: "halftone",
  version: "0.1.0",
  description:
    "Risograph: halftone dot screens, hard offset shadows, poster cards and Archivo set wide and loud - a print shop with no JavaScript at all.",
  cherry_contract: "1.1",
  # Halftone ships only the post list (poster cards). Every other
  # declared template resolves to the default theme's copy (contract 1.1);
  # the dot screens are pure CSS on the default layout.
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
    "--color-bg": [default: "#fff7ec", dark: "#141414", doc: "Page background."],
    "--color-surface": [
      default: "#f7ead8",
      dark: "#1f1d1a",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#1a1a1a", dark: "#f2ead9", doc: "Body text."],
    "--color-muted": [
      default: "#5c5248",
      dark: "#b0a597",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#1a1a1a",
      dark: "#f2ead9",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#e63b2e", dark: "#ff6b5e", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#b52418", dark: "#ff9a90", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffd5cf", dark: "#5a2520", doc: "Text selection ground."],
    "--syn-keyword": [default: "#e63b2e", dark: "#ff6b5e", doc: "Syntax: keywords."],
    "--syn-string": [default: "#1b6e3a", dark: "#6fd391", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#8a7f74", dark: "#8c8276", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6a2fb3", dark: "#c7a2ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#1d4fb8",
      dark: "#86b0ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#a85a00",
      dark: "#ffb660",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#1a1a1a",
      dark: "#f2ead9",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5c5248",
      dark: "#b0a597",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Archivo', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc:
        "Reading face (Archivo, self-hosted 29 KB latin subset, OFL). Headings use Archivo Expanded (21 KB)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "46rem", doc: "Reading column width."]
  ]
]
