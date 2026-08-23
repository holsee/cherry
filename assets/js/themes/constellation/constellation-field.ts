// Constellation's field: a fixed full-viewport canvas2d particle system -
// stars drifting slowly, hairlines forming between near neighbours and
// fading with distance, the pointer pulling the nearest stars a little.
//
// Colours come from the theme's tokens through the probe bridge (see the
// theming reference), so a site's `tokens:` override recolours the sky
// exactly like it recolours a link. Re-read on [data-theme] flips and on
// system scheme changes.
//
// Honest degradation: no canvas leaves the body's CSS gradient; reduced
// motion paints one still sky; a hidden tab pauses the loop.

const canvas = document.querySelector<HTMLCanvasElement>(".constellation-field");
const ctx = canvas?.getContext("2d", { alpha: true });

if (canvas && ctx) {
  type Star = { x: number; y: number; vx: number; vy: number; r: number; tw: number };

  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);

  function token(name: string): string {
    probe.style.color = `var(${name})`;
    return getComputedStyle(probe).color;
  }

  function rgb(color: string): string {
    const m = color.match(/[\d.]+/g);
    return m ? `${m[0]}, ${m[1]}, ${m[2]}` : "0, 0, 0";
  }

  let star = "0, 0, 0";
  let line = "0, 0, 0";
  let stars: Star[] = [];
  let w = 0;
  let h = 0;
  let dpr = 1;
  const pointer = { x: -1e4, y: -1e4 };
  const LINK = 120;

  function loadTokens(): void {
    star = rgb(token("--color-accent"));
    line = rgb(token("--color-fg"));
  }

  function seed(): void {
    const count = Math.min(220, Math.floor((w * h) / 9000));
    stars = Array.from({ length: count }, () => ({
      x: Math.random() * w,
      y: Math.random() * h,
      vx: (Math.random() - 0.5) * 0.18,
      vy: (Math.random() - 0.5) * 0.18,
      r: 0.6 + Math.random() * 1.6,
      tw: Math.random() * Math.PI * 2,
    }));
  }

  function resize(): void {
    dpr = Math.min(window.devicePixelRatio || 1, 2);
    w = window.innerWidth;
    h = window.innerHeight;
    canvas!.width = Math.floor(w * dpr);
    canvas!.height = Math.floor(h * dpr);
    ctx!.setTransform(dpr, 0, 0, dpr, 0, 0);
    seed();
  }

  function frame(t: number, advance: boolean): void {
    ctx!.clearRect(0, 0, w, h);
    for (const s of stars) {
      if (advance) {
        const dx = pointer.x - s.x;
        const dy = pointer.y - s.y;
        const d2 = dx * dx + dy * dy;
        if (d2 < 160 * 160 && d2 > 1) {
          const pull = 0.015 / Math.sqrt(d2);
          s.vx += dx * pull;
          s.vy += dy * pull;
        }
        s.vx *= 0.995;
        s.vy *= 0.995;
        s.x += s.vx;
        s.y += s.vy;
        if (s.x < -10) s.x = w + 10;
        if (s.x > w + 10) s.x = -10;
        if (s.y < -10) s.y = h + 10;
        if (s.y > h + 10) s.y = -10;
      }
    }
    ctx!.lineWidth = 1;
    for (let i = 0; i < stars.length; i++) {
      const a = stars[i]!;
      for (let j = i + 1; j < stars.length; j++) {
        const b = stars[j]!;
        const dx = a.x - b.x;
        const dy = a.y - b.y;
        const d = Math.sqrt(dx * dx + dy * dy);
        if (d < LINK) {
          ctx!.strokeStyle = `rgba(${line}, ${(0.16 * (1 - d / LINK)).toFixed(3)})`;
          ctx!.beginPath();
          ctx!.moveTo(a.x, a.y);
          ctx!.lineTo(b.x, b.y);
          ctx!.stroke();
        }
      }
    }
    for (const s of stars) {
      const glow = 0.55 + 0.45 * Math.sin(t * 0.0012 + s.tw);
      ctx!.fillStyle = `rgba(${star}, ${(0.35 + 0.55 * glow).toFixed(3)})`;
      ctx!.beginPath();
      ctx!.arc(s.x, s.y, s.r, 0, Math.PI * 2);
      ctx!.fill();
    }
  }

  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  let raf = 0;

  function loop(t: number): void {
    frame(t, true);
    raf = requestAnimationFrame(loop);
  }

  function start(): void {
    cancelAnimationFrame(raf);
    loadTokens();
    if (still.matches || document.hidden) {
      frame(0, false);
    } else {
      raf = requestAnimationFrame(loop);
    }
  }

  window.addEventListener("resize", () => {
    resize();
    if (still.matches) frame(0, false);
  });
  window.addEventListener("pointermove", (e) => {
    pointer.x = e.clientX;
    pointer.y = e.clientY;
  });
  window.addEventListener("pointerleave", () => {
    pointer.x = -1e4;
    pointer.y = -1e4;
  });
  document.addEventListener("visibilitychange", start);
  still.addEventListener("change", start);
  new MutationObserver(start).observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"],
  });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", start);

  resize();
  canvas.dataset.ready = "";
  start();
}

export {};
