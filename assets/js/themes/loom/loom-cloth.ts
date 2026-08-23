// Loom's cloth: a verlet grid pinned along the top of the band, drawn
// as warp and weft threads on a canvas2d. The pointer pushes points
// near it; scrolling sends a small gust. Colours come from the tokens
// through the probe bridge. Reduced motion: the cloth settles once and
// is drawn still. Off-screen: the loop idles.

const band = document.querySelector<HTMLElement>(".loom-band");
const canvas = band?.querySelector<HTMLCanvasElement>(".loom-cloth");
const ctx = canvas?.getContext("2d");

if (band && canvas && ctx) {
  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);
  const rgb = (name: string): string => {
    probe.style.color = `var(${name})`;
    const m = getComputedStyle(probe).color.match(/[\d.]+/g);
    return m ? `${m[0]}, ${m[1]}, ${m[2]}` : "0, 0, 0";
  };

  type P = { x: number; y: number; ox: number; oy: number; pin: boolean };
  let cols = 48;
  let rows = 18;
  let pts: P[] = [];
  let w = 0;
  let h = 0;
  let dpr = 1;
  let thread = "0, 0, 0";
  let ground = "0, 0, 0";
  let surface = "0, 0, 0";
  let accent = "0, 0, 0";
  const pointer = { x: -1e4, y: -1e4, vx: 0, vy: 0 };
  let gust = 0;
  let lastScroll = window.scrollY;

  const loadTokens = (): void => {
    thread = rgb("--color-fg");
    ground = rgb("--color-bg");
    surface = rgb("--color-surface");
    accent = rgb("--color-accent");
  };

  const build = (): void => {
    cols = Math.max(24, Math.min(64, Math.floor(w / 26)));
    rows = Math.max(10, Math.min(22, Math.floor(h / 22)));
    pts = [];
    for (let j = 0; j <= rows; j++) {
      for (let i = 0; i <= cols; i++) {
        const x = (i / cols) * w;
        const y = (j / rows) * h * 0.92;
        pts.push({ x, y, ox: x, oy: y, pin: j === 0 });
      }
    }
  };

  const resize = (): void => {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    const r = band.getBoundingClientRect();
    w = r.width;
    h = r.height;
    canvas.width = Math.floor(w * dpr);
    canvas.height = Math.floor(h * dpr);
    ctx.setTransform(dpr, 0, 0, dpr, 0, 0);
    build();
  };

  const step = (): void => {
    const restX = w / cols;
    const restY = (h * 0.92) / rows;
    // verlet integrate with a pull back toward the hanging position
    for (const p of pts) {
      if (p.pin) continue;
      const vx = (p.x - p.ox) * 0.96;
      const vy = (p.y - p.oy) * 0.96;
      p.ox = p.x;
      p.oy = p.y;
      p.x += vx + gust * 0.4;
      p.y += vy + 0.05;
      const dx = pointer.x - p.x;
      const dy = pointer.y - p.y;
      const d2 = dx * dx + dy * dy;
      if (d2 < 130 * 130) {
        const f = (1 - Math.sqrt(d2) / 130) * 0.9;
        p.x += pointer.vx * f + (dx > 0 ? -f * 2 : f * 2);
        p.y += pointer.vy * f;
      }
    }
    // satisfy constraints a few times
    for (let k = 0; k < 3; k++) {
      for (let j = 0; j <= rows; j++) {
        for (let i = 0; i <= cols; i++) {
          const a = pts[j * (cols + 1) + i]!;
          if (i < cols) relax(a, pts[j * (cols + 1) + i + 1]!, restX);
          if (j < rows) relax(a, pts[(j + 1) * (cols + 1) + i]!, restY);
        }
      }
      // re-pin the top edge
      for (let i = 0; i <= cols; i++) {
        const p = pts[i]!;
        p.x = (i / cols) * w;
        p.y = 0;
      }
    }
    gust *= 0.9;
    pointer.vx *= 0.8;
    pointer.vy *= 0.8;
  };

  function relax(a: P, b: P, rest: number): void {
    const dx = b.x - a.x;
    const dy = b.y - a.y;
    const d = Math.hypot(dx, dy) || 1;
    const diff = ((d - rest) / d) * 0.5;
    const ox = dx * diff;
    const oy = dy * diff;
    if (!a.pin) {
      a.x += ox;
      a.y += oy;
    }
    if (!b.pin) {
      b.x -= ox;
      b.y -= oy;
    }
  }

  const draw = (): void => {
    ctx.clearRect(0, 0, w, h);
    ctx.fillStyle = `rgb(${surface})`;
    ctx.fillRect(0, 0, w, h);
    ctx.lineWidth = 1;
    // warp (vertical)
    ctx.strokeStyle = `rgba(${thread}, 0.28)`;
    for (let i = 0; i <= cols; i++) {
      ctx.beginPath();
      for (let j = 0; j <= rows; j++) {
        const p = pts[j * (cols + 1) + i]!;
        if (j === 0) ctx.moveTo(p.x, p.y);
        else ctx.lineTo(p.x, p.y);
      }
      ctx.stroke();
    }
    // weft (horizontal), every row; one in six in the accent
    for (let j = 0; j <= rows; j++) {
      ctx.strokeStyle = j % 6 === 3 ? `rgba(${accent}, 0.55)` : `rgba(${thread}, 0.22)`;
      ctx.beginPath();
      for (let i = 0; i <= cols; i++) {
        const p = pts[j * (cols + 1) + i]!;
        if (i === 0) ctx.moveTo(p.x, p.y);
        else ctx.lineTo(p.x, p.y);
      }
      ctx.stroke();
    }
    // fade into the page
    const g = ctx.createLinearGradient(0, h * 0.55, 0, h);
    g.addColorStop(0, `rgba(${ground}, 0)`);
    g.addColorStop(1, `rgba(${ground}, 1)`);
    ctx.fillStyle = g;
    ctx.fillRect(0, 0, w, h);
  };

  let raf = 0;
  const loop = (): void => {
    if (band.getBoundingClientRect().bottom > 0) {
      step();
      draw();
    }
    raf = requestAnimationFrame(loop);
  };
  const start = (): void => {
    cancelAnimationFrame(raf);
    loadTokens();
    resize();
    if (still.matches || document.hidden) {
      for (let i = 0; i < 40; i++) step();
      draw();
    } else {
      raf = requestAnimationFrame(loop);
    }
  };

  window.addEventListener("pointermove", (e) => {
    const r = band.getBoundingClientRect();
    const x = e.clientX - r.left;
    const y = e.clientY - r.top;
    pointer.vx = x - pointer.x;
    pointer.vy = y - pointer.y;
    if (Math.abs(pointer.vx) > 80) pointer.vx = 0;
    if (Math.abs(pointer.vy) > 80) pointer.vy = 0;
    pointer.x = x;
    pointer.y = y;
  });
  window.addEventListener("pointerleave", () => {
    pointer.x = -1e4;
    pointer.y = -1e4;
  });
  window.addEventListener("scroll", () => {
    gust += (window.scrollY - lastScroll) * 0.02;
    lastScroll = window.scrollY;
  }, { passive: true });
  window.addEventListener("resize", resize);
  document.addEventListener("visibilitychange", start);
  still.addEventListener("change", start);
  new MutationObserver(start).observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", start);
  canvas.dataset.ready = "";
  start();
}

export {};
