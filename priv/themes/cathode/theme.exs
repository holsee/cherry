[
  name: "cathode",
  version: "0.1.0",
  description:
    "A CRT: scanlines, phosphor bloom, a bezel around the page and a cursor that blinks after every title - Azeret Mono at 300 to 800.",
  cherry_contract: "1.1",
  # Cathode ships only its layout: the bezel wrapper and the scanline
  # layer. Every other declared template resolves to the default theme's
  # copy (contract 1.1).
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
    "--color-bg": [default: "#e8ecdf", dark: "#050806", doc: "Page background."],
    "--color-surface": [
      default: "#dde3d0",
      dark: "#0b120c",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#1d2a1a", dark: "#b8f0b0", doc: "Body text."],
    "--color-muted": [
      default: "#586852",
      dark: "#6fa868",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#c9d1bc",
      dark: "#1e3320",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#1d6b2d", dark: "#4dff6a", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#134d20", dark: "#8fff9f", doc: "Hover/active accent."],
    "--color-selection": [default: "#c4e2c4", dark: "#1b4a22", doc: "Text selection ground."],
    "--syn-keyword": [default: "#1d6b2d", dark: "#4dff6a", doc: "Syntax: keywords."],
    "--syn-string": [default: "#8a4f10", dark: "#ffd27a", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#778270", dark: "#5f8a5a", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#5a3a9e", dark: "#b8ff8a", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#1d4f9a",
      dark: "#7ad9ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#9a2f2f",
      dark: "#ffa35c",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#1d2a1a",
      dark: "#b8f0b0",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#586852",
      dark: "#6fa868",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Azeret Mono', ui-monospace, 'Cascadia Code', Consolas, monospace",
      doc: "Reading face (Azeret Mono, self-hosted 22 KB latin subset, OFL). Everything is mono."
    ],
    "--font-mono": [
      default: "'Azeret Mono', ui-monospace, 'Cascadia Code', Consolas, monospace",
      doc: "Structure and code face (the same Azeret Mono)."
    ],
    "--measure": [default: "40rem", doc: "Reading column width."]
  ]
]
