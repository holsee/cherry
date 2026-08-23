// Compiles the client-side islands from assets/js/ into every official
// theme's assets/, plus the serve and search bundles. Themes are
// discovered from priv/themes/ so a new theme ships the islands by
// existing — the byte-identity test (theme_assets_sync_test) then holds
// for free.
import { buildSync } from "esbuild";
import { existsSync, readdirSync } from "node:fs";

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

  // Theme-local islands (the island convention): a theme owning extra
  // behaviour keeps its sources in assets/js/themes/<theme>/ and its
  // layout includes the built file from assets/ like any island.
  const local = `assets/js/themes/${theme}`;
  if (existsSync(local)) {
    for (const entry of readdirSync(local).filter((f) => f.endsWith(".ts"))) {
      buildSync({
        ...opts,
        entryPoints: [`${local}/${entry}`],
        outfile: `priv/themes/${theme}/assets/${entry.replace(/\.ts$/, ".js")}`,
      });
    }
  }
}

buildSync({ ...opts, entryPoints: ["assets/js/livereload.ts"], outfile: "priv/serve/livereload.js" });
buildSync({ ...opts, entryPoints: ["assets/js/search.ts"], outfile: "priv/search/search.js" });

console.log(`islands built for: ${themes.join(", ")}`);
