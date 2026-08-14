[
  name: "default",
  version: "0.1.0",
  description: "Cherry's default theme — typography-first, light/dark via tokens.",
  cherry_contract: "1.0",
  templates: [
    layout: [
      assigns: [:site, :inner, :page_title],
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
      assigns: [:site, :tag, :posts],
      doc: "Published posts carrying one tag."
    ],
    not_found: [
      assigns: [:site],
      doc: "The 404 page."
    ]
  ],
  # The token manifest is the theme's public styling API; it is filled in
  # by the design pass (DO_NEXT slice 6).
  tokens: []
]
