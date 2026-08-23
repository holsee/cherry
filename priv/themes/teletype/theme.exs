[
  name: "teletype",
  version: "0.1.0",
  description: "All-mono devlog: paper printout by day, amber-phosphor terminal by night.",
  cherry_contract: "1.1",
  # CSS-only (contract 1.1): the inventory below is declared in full, but
  # every template resolves to the default theme's copy.
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
    "--color-bg": [default: "#fafaf7", dark: "#0f1210", doc: "Page background."],
    "--color-surface": [
      default: "#f0f0ea",
      dark: "#171b18",
      doc: "Raised ground: code blocks, inline code."
    ],
    "--color-fg": [default: "#30353a", dark: "#c9d1c9", doc: "Body text."],
    "--color-muted": [
      default: "#676f77",
      dark: "#8b9a8b",
      doc: "Secondary text: metadata, nav, footer."
    ],
    "--color-border": [
      default: "#e0e2dc",
      dark: "#263029",
      doc: "Hairline rules and control borders."
    ],
    "--color-accent": [default: "#9a6700", dark: "#e3b341", doc: "Links and interactive accents."],
    "--color-accent-strong": [default: "#7a5200", dark: "#f0ca6a", doc: "Hover/active accent."],
    "--color-selection": [default: "#fff0c2", dark: "#4a3a10", doc: "Text selection ground."],
    "--syn-keyword": [default: "#9a6700", dark: "#e3b341", doc: "Syntax: keywords."],
    "--syn-string": [default: "#116329", dark: "#7ce38b", doc: "Syntax: strings and characters."],
    "--syn-comment": [default: "#6e7781", dark: "#768390", doc: "Syntax: comments (italic)."],
    "--syn-function": [
      default: "#0b6bcb",
      dark: "#6cb6ff",
      doc: "Syntax: functions and methods."
    ],
    "--syn-constant": [
      default: "#8250df",
      dark: "#c8a1ff",
      doc: "Syntax: constants, numbers, booleans."
    ],
    "--syn-type": [
      default: "#0e7490",
      dark: "#76c7da",
      doc: "Syntax: types, modules, tags, attributes."
    ],
    "--syn-variable": [
      default: "#30353a",
      dark: "#c9d1c9",
      doc: "Syntax: variables and default code text."
    ],
    "--syn-punct": [
      default: "#676f77",
      dark: "#8b9a8b",
      doc: "Syntax: punctuation and operators."
    ],
    "--font-prose": [
      default: "'Noto Sans Mono', ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Reading face — the same mono as everything else (Noto Sans Mono, self-hosted 32 KB latin subset, OFL)."
    ],
    "--font-mono": [
      default: "'Noto Sans Mono', ui-monospace, 'Cascadia Code', 'SF Mono', Consolas, 'DejaVu Sans Mono', monospace",
      doc: "Structure and code face — identical to --font-prose by design."
    ],
    "--measure": [default: "40rem", doc: "Reading column width (~72ch of mono)."]
  ]
]
