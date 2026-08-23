// Compiles the client-side islands from assets/js/ into every official
// theme's assets/, plus the serve and search bundles. Themes are
// discovered from priv/themes/ so a new theme ships the islands by
// existing — the byte-identity test (theme_assets_sync_test) then holds
// for free.
import { buildSync } from "esbuild";
import { readdirSync } from "node:fs";

const opts = {
  bundle: true,
  minify: true,
  format: "iife",
  target: "es2020",
};

const themes = readdirSync("priv/themes", { withFileTypes: true })
  .filter((entry) => entry.isDirectory())
  .map((entry) => entry.name)
  .sort();

const islands = ["theme-toggle", "copy-code", "video-embed"];

for (const theme of themes) {
  for (const island of islands) {
    buildSync({
      ...opts,
      entryPoints: [`assets/js/${island}.ts`],
      outfile: `priv/themes/${theme}/assets/${island}.js`,
    });
  }
}

buildSync({ ...opts, entryPoints: ["assets/js/livereload.ts"], outfile: "priv/serve/livereload.js" });
buildSync({ ...opts, entryPoints: ["assets/js/search.ts"], outfile: "priv/search/search.js" });

console.log(`islands built for: ${themes.join(", ")}`);
