[
  name: "broadsheet",
  version: "0.1.0",
  description:
    "A newspaper: a centred masthead between double rules, a three-column front page with drop caps, Playfair Display over the system serif.",
  cherry_contract: "1.1",
  # Broadsheet ships its layout (the masthead) and the post list (the
  # three-column front page). Everything else resolves to the default
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
    "--color-bg": [default: "#f9f7f1", dark: "#141311", doc: "Page background."],
    "--color-surface": [
      default: "#efece3",
      dark: "#1d1b18",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#161412", dark: "#e9e4d8", doc: "Body text."],
    "--color-muted": [
      default: "#5a5650",
      dark: "#a39d91",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#161412",
      dark: "#e9e4d8",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#8a1c1c", dark: "#e36b6b", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#5e1111", dark: "#f09a9a", doc: "Hover/active accent."],
    "--color-selection": [default: "#f1dcdc", dark: "#4a2424", doc: "Text selection ground."],
    "--syn-keyword": [default: "#8a1c1c", dark: "#e36b6b", doc: "Syntax: keywords."],
    "--syn-string": [default: "#1f5f3a", dark: "#86cf9f", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7c786f", dark: "#837e74", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#5a3a8e", dark: "#c9a8ff", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#1f4f8e",
      dark: "#8fb5f0",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#8a5a12",
      dark: "#e6b36a",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#161412",
      dark: "#e9e4d8",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5a5650",
      dark: "#a39d91",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "Charter, 'Iowan Old Style', 'Palatino Linotype', Georgia, serif",
      doc:
        "Body copy (system serif, zero bytes). Masthead and headlines use Playfair Display (self-hosted 67 KB latin subsets, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "46rem", doc: "Reading column width."]
  ]
]
