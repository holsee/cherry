// Topo's relief: a fixed canvas tracing contour lines through a
// drifting value-noise field with marching squares. The field's
// amplitude drops to zero inside the reading column (main .wrap), so
// the writing sits in a clearing. Colours come from the tokens through
// the probe bridge. Reduced motion: one frame. Hidden tab: paused.

const canvas = document.querySelector<HTMLCanvasElement>(".topo-relief");
const ctx = canvas?.getContext("2d");

if (canvas && ctx) {
  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);
  const rgb = (name: string): string => {
    probe.style.color = `var(${name})`;
    const m = getComputedStyle(probe).color.match(/[\d.]+/g);
    return m ? `${m[0]}, ${m[1]}, ${m[2]}` : "0, 0, 0";
  };

  let w = 0;
  let h = 0;
  let dpr = 1;
  let cell = 14;
  let cols = 0;
  let rows = 0;
  let ink = "0, 0, 0";
  let accent = "0, 0, 0";
  let clearing = { x0: 0, x1: 0 };
  let levels = 8;

  // value noise with a fixed permutation so the map is the same each visit
  const perm = new Uint8Array(512);
  let seed = 1337;
  const rand = (): number => {
    seed = (seed * 1664525 + 1013904223) >>> 0;
    return seed / 4294967296;
  };
  for (let i = 0; i < 256; i++) perm[i] = i;
  for (let i = 255; i > 0; i--) {
    const j = Math.floor(rand() * (i + 1));
    const t = perm[i]!;
    perm[i] = perm[j]!;
    perm[j] = t;
  }
  for (let i = 0; i < 256; i++) perm[i + 256] = perm[i]!;
  const hash = (x: number, y: number): number => perm[(perm[x & 255]! + y) & 255]! / 255;
  const smooth = (t: number): number => t * t * (3 - 2 * t);
  const noise = (x: number, y: number): number => {
    const xi = Math.floor(x);
    const yi = Math.floor(y);
    const xf = x - xi;
    const yf = y - yi;
    const a = hash(xi, yi);
    const b = hash(xi + 1, yi);
    const c = hash(xi, yi + 1);
    const d = hash(xi + 1, yi + 1);
    const u = smooth(xf);
    const v = smooth(yf);
    return a + (b - a) * u + (c - a) * v + (a - b - c + d) * u * v;
  };
  const field = (px: number, py: number, t: number): number => {
    const x = px / 260 + t * 0.015;
    const y = py / 260 - t * 0.01;
    let v = 0.55 * noise(x, y) + 0.3 * noise(x * 2.1 + 7, y * 2.1 + 3) + 0.15 * noise(x * 4.3 + 11, y * 4.3 + 5);
    // the clearing: flatten inside the column, ease over 9rem outside it
    const margin = 9 * 16;
    const dx = px < clearing.x0 ? clearing.x0 - px : px > clearing.x1 ? px - clearing.x1 : 0;
    const k = Math.min(1, dx / margin);
    return v * smooth(k);
  };

  const measureClearing = (): void => {
    const wrap = document.querySelector<HTMLElement>("main .wrap");
    if (!wrap) {
      clearing = { x0: w / 2 - 300, x1: w / 2 + 300 };
      return;
    }
    const r = wrap.getBoundingClientRect();
    clearing = { x0: r.left + 8, x1: r.right - 8 };
  };

  const resize = (): void => {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    w = window.innerWidth;
    h = window.innerHeight;
    canvas.width = Math.floor(w * dpr);
    canvas.height = Math.floor(h * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    cell = w < 704 ? 18 : 14;
    levels = w < 704 ? 5 : 8;
    cols = Math.ceil(w / cell) + 1;
    rows = Math.ceil(h / cell) + 1;
    measureClearing();
  };

  const grid = (): Float32Array => new Float32Array(cols * rows);

  const draw = (t: number): void => {
    const g = grid();
    for (let j = 0; j < rows; j++) {
      for (let i = 0; i < cols; i++) {
        g[j * cols + i] = field(i * cell, j * cell, t);
      }
    }
    ctx.clearRect(0, 0, w, h);
    ctx.lineJoin = "round";
    for (let l = 1; l <= levels; l++) {
      const iso = l / (levels + 1);
      const index = l % 4 === 0;
      ctx.strokeStyle = index ? `rgba(${accent}, 0.55)` : `rgba(${ink}, 0.22)`;
      ctx.lineWidth = index ? 1.2 : 0.8;
      ctx.beginPath();
      for (let j = 0; j < rows - 1; j++) {
        for (let i = 0; i < cols - 1; i++) {
          const a = g[j * cols + i]!;
          const b = g[j * cols + i + 1]!;
          const c = g[(j + 1) * cols + i + 1]!;
          const d = g[(j + 1) * cols + i]!;
          const code = (a > iso ? 8 : 0) | (b > iso ? 4 : 0) | (c > iso ? 2 : 0) | (d > iso ? 1 : 0);
          if (code === 0 || code === 15) continue;
          const x = i * cell;
          const y = j * cell;
          const lerp = (p: number, q: number): number => (iso - p) / (q - p || 1e-6);
          const top: [number, number] = [x + cell * lerp(a, b), y];
          const right: [number, number] = [x + cell, y + cell * lerp(b, c)];
          const bottom: [number, number] = [x + cell * lerp(d, c), y + cell];
          const left: [number, number] = [x, y + cell * lerp(a, d)];
          const seg = (p: [number, number], q: [number, number]): void => {
            ctx.moveTo(p[0], p[1]);
            ctx.lineTo(q[0], q[1]);
          };
          switch (code) {
            case 1: case 14: seg(left, bottom); break;
            case 2: case 13: seg(bottom, right); break;
            case 3: case 12: seg(left, right); break;
            case 4: case 11: seg(top, right); break;
            case 5: seg(top, left); seg(bottom, right); break;
            case 6: case 9: seg(top, bottom); break;
            case 7: case 8: seg(top, left); break;
            case 10: seg(top, right); seg(left, bottom); break;
          }
        }
      }
      ctx.stroke();
    }
  };

  let raf = 0;
  let last = 0;
  const loop = (ms: number): void => {
    // the land moves slowly; 12 fps is plenty and keeps the CPU cool
    if (ms - last > 80) {
      last = ms;
      draw(ms / 1000);
    }
    raf = requestAnimationFrame(loop);
  };
  const start = (): void => {
    cancelAnimationFrame(raf);
    ink = rgb("--color-fg");
    accent = rgb("--color-accent");
    resize();
    if (still.matches || document.hidden) draw(4);
    else raf = requestAnimationFrame(loop);
  };

  window.addEventListener("resize", () => {
    resize();
    if (still.matches) draw(4);
  });
  document.addEventListener("visibilitychange", start);
  still.addEventListener("change", start);
  new MutationObserver(start).observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", start);
  canvas.dataset.ready = "";
  start();
}

export {};
