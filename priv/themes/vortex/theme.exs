[
  name: "vortex",
  version: "0.1.0",
  description:
    "Kinetic type: the site name spun on two counter-rotating text rings, titles that land letter by letter, Bricolage Grotesque at display size.",
  cherry_contract: "1.1",
  # Vortex ships only its layout: the text rings and the letter-landing
  # island. Every other declared template resolves to the default theme's
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
    "--color-bg": [default: "#f6f5f1", dark: "#0e0e10", doc: "Page background."],
    "--color-surface": [
      default: "#ecebe5",
      dark: "#17171b",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#121212", dark: "#f2f1ec", doc: "Body text."],
    "--color-muted": [
      default: "#5f5e5a",
      dark: "#a3a29c",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#dcdbd4",
      dark: "#2a2a30",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#d5006d", dark: "#ff5fa8", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#a30053", dark: "#ff8fc3", doc: "Hover/active accent."],
    "--color-selection": [default: "#ffd3e7", dark: "#4d1433", doc: "Text selection ground."],
    "--syn-keyword": [default: "#d5006d", dark: "#ff5fa8", doc: "Syntax: keywords."],
    "--syn-string": [default: "#1a6f4b", dark: "#5fd9a3", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#85847e", dark: "#808079", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#5f2fc2", dark: "#c4a3ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#0a5ac4",
      dark: "#7ab6ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#b35a00",
      dark: "#ffb565",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#121212",
      dark: "#f2f1ec",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5f5e5a",
      dark: "#a3a29c",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Bricolage Grotesque', system-ui, 'Segoe UI', Roboto, sans-serif",
      doc: "Reading and display face (Bricolage Grotesque, self-hosted 39 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "44rem", doc: "Reading column width."]
  ]
]
