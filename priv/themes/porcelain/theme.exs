[
  name: "porcelain",
  version: "0.1.0",
  description: "Glazed-ceramic ground, Literata serif, sage accent — the clinical restyle target.",
  cherry_contract: "1.1",
  # CSS-only (contract 1.1): the inventory below is declared in full, but
  # every template resolves to the default theme's copy. Porcelain is a
  # manifest, a stylesheet, and two font files - nothing copied, nothing
  # to drift.
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
    "--color-bg": [default: "#faf9f6", dark: "#171916", doc: "Page background."],
    "--color-surface": [
      default: "#f1efe9",
      dark: "#1f221d",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#262a24", dark: "#d9d9cf", doc: "Body text."],
    "--color-muted": [
      default: "#636a5d",
      dark: "#a0a698",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#e4e1d6",
      dark: "#2c3029",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#47664e", dark: "#a6c4a7", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#32493a", dark: "#c3dac3", doc: "Hover/active accent."],
    "--color-selection": [default: "#dde7da", dark: "#344134", doc: "Text selection ground."],
    "--syn-keyword": [default: "#47664e", dark: "#a6c4a7", doc: "Syntax: keywords."],
    "--syn-string": [default: "#33586b", dark: "#9dc4d8", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#7b8172", dark: "#8e9585", doc: "Syntax: comments (italic)."],
    "--syn-function": [
      default: "#6d5486",
      dark: "#c0a8d8",
      doc: "Syntax: functions and methods."
    ],
    "--syn-constant": [
      default: "#35608a",
      dark: "#92b8dc",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#8a5a33",
      dark: "#d3a878",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#262a24",
      dark: "#d9d9cf",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#636a5d",
      dark: "#a0a698",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Literata', Charter, 'Bitstream Charter', Cambria, Georgia, serif",
      doc: "Long-form reading face (Literata, self-hosted 72 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default:
        "ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face."
    ],
    "--measure": [default: "42rem", doc: "Reading column width (~66ch)."]
  ]
]
