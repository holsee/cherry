// theme_shots.mjs — the theme QA screenshot harness (#115).
//
// Captures the standard page set of a running site at two viewports in
// both renditions, plus a print PDF of /cv/. Renditions ride the
// ?theme=light|dark query param every official layout honours before
// first paint. Driven through puppeteer-core (CDP viewport emulation)
// because Chromium clamps real windows to a ~500px minimum width, which
// silently crops every mobile capture taken via --window-size.
//
//   node scripts/theme_shots.mjs BASE_URL OUT_DIR [NAME=PATH ...]
//
//   BASE_URL   e.g. http://localhost:4001
//   OUT_DIR    created if missing; files land as NAME-VIEWPORT-RENDITION.png
//   NAME=PATH  extra pages beyond the defaults (post=/blog/a-post/);
//              NAME= (empty) drops a default page.
//
// Defaults: home=/ blog=/blog/ cv=/cv/ timeline=/cv/timeline/ 404=/404.html
// Browser: THEME_SHOTS_BROWSER, or the first Edge/Chrome found.

import { existsSync, mkdirSync } from "node:fs";
import puppeteer from "puppeteer-core";

const [base, outDir, ...extra] = process.argv.slice(2);
if (!base || !outDir) {
  console.error("usage: node scripts/theme_shots.mjs BASE_URL OUT_DIR [NAME=PATH ...]");
  process.exit(2);
}

const CANDIDATES = [
  process.env.THEME_SHOTS_BROWSER,
  "C:/Program Files (x86)/Microsoft/Edge/Application/msedge.exe",
  "C:/Program Files/Microsoft/Edge/Application/msedge.exe",
  "/usr/bin/google-chrome",
  "/usr/bin/chromium",
  "/usr/bin/chromium-browser",
].filter(Boolean);

const executablePath = CANDIDATES.find((p) => existsSync(p));
if (!executablePath) {
  console.error("no browser found — set THEME_SHOTS_BROWSER");
  process.exit(1);
}

const pages = new Map([
  ["home", "/"],
  ["blog", "/blog/"],
  ["cv", "/cv/"],
  ["timeline", "/cv/timeline/"],
  ["404", "/404.html"],
]);
for (const spec of extra) {
  const eq = spec.indexOf("=");
  const name = spec.slice(0, eq);
  let path = spec.slice(eq + 1);
  // Git Bash rewrites leading-slash args into Windows paths under its
  // install root (MSYS path conversion). Undo it so `post=/blog/x/`
  // works without MSYS_NO_PATHCONV=1.
  const msys = path.match(/^[A-Za-z]:.*?\/Git(\/.*)$/i);
  if (msys) path = msys[1];
  if (path === "") pages.delete(name);
  else pages.set(name, path);
}

const viewports = [
  ["desktop", { width: 1280, height: 900 }],
  ["mobile", { width: 390, height: 844 }],
];

const withTheme = (path, rendition) =>
  `${base.replace(/\/$/, "")}${path}${path.includes("?") ? "&" : "?"}theme=${rendition}`;

mkdirSync(outDir, { recursive: true });

const browser = await puppeteer.launch({
  executablePath,
  headless: true,
  args: ["--disable-gpu", "--hide-scrollbars"],
});

let total = 0;
try {
  const page = await browser.newPage();

  for (const [name, path] of pages) {
    const probe = await page.goto(`${base.replace(/\/$/, "")}${path}`, {
      waitUntil: "domcontentloaded",
    });
    if (probe.status() !== 200 && name !== "404") {
      console.log(`-- ${name} (${path}) returned ${probe.status()} — skipping`);
      continue;
    }

    for (const rendition of ["light", "dark"]) {
      for (const [vpName, viewport] of viewports) {
        await page.setViewport(viewport);
        await page.goto(withTheme(path, rendition), { waitUntil: "networkidle2" });
        await page.screenshot({ path: `${outDir}/${name}-${vpName}-${rendition}.png` });
        total += 1;
      }
    }
    console.log(`== ${name} (${path}): 4 captures`);
  }

  // Print rendition of the CV — the page that must survive paper.
  if (pages.has("cv")) {
    const cv = `${base.replace(/\/$/, "")}${pages.get("cv")}`;
    const probe = await page.goto(cv, { waitUntil: "domcontentloaded" });
    if (probe.status() === 200) {
      await page.pdf({ path: `${outDir}/cv-print.pdf`, printBackground: false });
      console.log("== cv print PDF");
      total += 1;
    }
  }
} finally {
  await browser.close();
}

console.log(`done: ${total} captures in ${outDir}`);
