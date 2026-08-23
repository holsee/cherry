# Porcelain theme — design system

The clinical lane's reference restyle (catalog issue #112, lane proof
#120): what the default theme's markup looks like when a single serif,
a ceramic ground, and one sage accent do all the talking. Quality bar:
the default theme's own restraint, plus Literata set the way a book
designer would.

## World

- **Ground:** glazed porcelain (`#faf9f6`) / unlit studio (`#171916`) —
  both warm, both designed, the toggle swaps one kiln light for another.
- **Faces:** Literata for prose (self-hosted latin subset, upright and
  italic variable woff2, 38 + 34 KB, OFL); the system mono stack for
  structure — dates, nav, metadata, code. One shipped face, used
  everywhere reading happens.
- **Accent:** one sage green (`--color-accent`), applied like a maker's
  mark: links and focus, nothing else.
- **Understatement as identity:** headings at 600, hairline rules, a
  short centred `hr`, italic blockquotes, generous leading (1.75) and
  vertical air. The page recedes; the writing stays.

## Rules

- **CSS-only (contract 1.1).** `inherit_templates: true`: the manifest
  declares the full inventory, ships none of it, and every template
  resolves to the default theme's copy. Nothing copied, nothing to
  drift; the byte-identity that matters is upstream's.
- Every color lives in a token; templates and component rules never
  carry a literal — test-enforced (`theme_tokens_test.exs`, porcelain is
  in the loop).
- Each color token is one `light-dark()` pair plus a plain light
  fallback line; print forces the light rendition of the six print
  tokens exactly as the default theme does.
- The token API is identical to the default theme's key-for-key
  (`porcelain_theme_test.exs`), so site overrides port across a theme
  swap unchanged.
- Zero third-party requests: the two Literata files ship in
  `assets/fonts/` beside the stylesheet.
