[
  name: "sylva",
  version: "0.1.0",
  description:
    "A living season: leaves, petals or snow drifting behind a serif index grouped by year - the canvas knows what month it is.",
  cherry_contract: "1.1",
  # Sylva ships its layout (the season canvas and island) and the post
  # list (grouped by year). Everything else resolves to the default
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
    "--color-bg": [default: "#f6f4ec", dark: "#0f140f", doc: "Page background."],
    "--color-surface": [
      default: "#ece9dd",
      dark: "#171e16",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#22281f", dark: "#e4e2d6", doc: "Body text."],
    "--color-muted": [
      default: "#5f6a58",
      dark: "#9ca594",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#dcd8c8",
      dark: "#28322a",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#3f6b2e", dark: "#9ccc7a", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#2c4d1f", dark: "#bde1a3", doc: "Hover/active accent."],
    "--color-selection": [default: "#dbe8cf", dark: "#2d4326", doc: "Text selection ground."],
    "--syn-keyword": [default: "#3f6b2e", dark: "#9ccc7a", doc: "Syntax: keywords."],
    "--syn-string": [default: "#8a4a1d", dark: "#f0b07c", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7f8678", dark: "#7f887a", doc: "Syntax: comments (italic)."],
    "--syn-function": [default: "#6b3a8f", dark: "#c9a6ef", doc: "Syntax: functions and methods."],
    "--syn-constant": [
      default: "#1f5f9e",
      dark: "#86b5f2",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#b4662a",
      dark: "#e8a063",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#22281f",
      dark: "#e4e2d6",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#5f6a58",
      dark: "#9ca594",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Newsreader', Charter, 'Iowan Old Style', Georgia, serif",
      doc: "Reading face (Newsreader, self-hosted 87 KB latin subsets upright + italic, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "42rem", doc: "Reading column width."]
  ]
]
