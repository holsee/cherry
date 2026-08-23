# Prism theme — design system

The cutting-edge lane's proof (catalog issue #112, #128): the ThreeUI
homage done Cherry's way. A live gradient mesh and glass surfaces, and
every colour still flows through the same token API as the quietest
official theme. Modern is not a licence to leave the contract.

## World

- **Ground:** pearl daylight (`#fbfaff`) / deep space (`#0b0d18`);
  violet accent family (`light-dark(#6d28d9, #a78bfa)`) drives links
  *and* the mesh.
- **The mesh:** a fixed full-viewport canvas behind everything, painted
  by `prism-mesh.js` — a ~5 KB hand-written WebGL fragment shader
  (three drifting radial fields, half-resolution, DPR-capped). No
  three.js, no requests.
- **Glass:** sticky header and code surfaces are translucent
  `color-mix` over the tokens, with `backdrop-filter` blur where the
  engine has it and an honest solid surface where it does not.
- **Face:** Instrument Sans (self-hosted latin subset, upright +
  italic, 28 + 28 KB, OFL); system mono for structure.

## The token → uniform bridge

The shader carries no colours. Its uniforms are read from the CSS
custom properties by painting `var(--token)` onto a probe element and
letting the browser resolve it — hex, `light-dark()`, `color-mix()`
all included — then re-read when `[data-theme]` flips or the system
scheme changes. `cherry config tokens.--color-accent` restyles the
mesh exactly like it restyles a link. The pattern is documented in the
theming reference for any theme to use.

## Honest degradation (in order)

1. **JS off / WebGL unavailable:** the body paints a static poster
   gradient from the same tokens; the canvas stays invisible. Content
   is complete.
2. **`prefers-reduced-motion`:** the shader paints one frame and the
   loop never starts.
3. **Print:** the canvas is `display: none`, the body drops to the
   plain light ground, black on white.

## Rules

- Contract 1.1, `inherit_templates: true`, shipping exactly one
  template: the layout that mounts the canvas and its island. The
  other eight resolve to the default theme's copies.
- Theme-local islands live in `assets/js/themes/prism/` and build like
  the official islands (esbuild via build.mjs); the shared three ship
  byte-identical as everywhere.
- No colour literals outside token definitions (`theme_tokens_test`,
  prism is in the loop); token API identical to `default` key-for-key.
