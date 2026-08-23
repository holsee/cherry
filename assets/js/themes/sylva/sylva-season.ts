// Sylva's season: petals, leaves, amber leaves or snow drifting down a
// fixed canvas, chosen by the month (or ?season=spring|summer|autumn|
// winter for previews). The tint is the canvas's own computed `color`,
// which the stylesheet sets per season from the tokens - the script
// carries no colours. Re-read on rendition changes; reduced motion
// settles a few shapes and stops; a hidden tab pauses the loop.

const canvas = document.querySelector<HTMLCanvasElement>(".sylva-season");
const ctx = canvas?.getContext("2d", { alpha: true });

if (canvas && ctx) {
  type Shape = { x: number; y: number; vy: number; sway: number; phase: number; size: number; spin: number; a: number };

  const seasons = ["winter", "spring", "summer", "autumn"];
  const forced = location.search.match(/[?&]season=(spring|summer|autumn|winter)/);
  const month = new Date().getMonth();
  const season = forced ? forced[1] : seasons[Math.floor(((month + 1) % 12) / 3)];
  document.documentElement.dataset.season = season;

  let tint = "0, 0, 0";
  let shapes: Shape[] = [];
  let w = 0;
  let h = 0;

  function loadTint(): void {
    const m = getComputedStyle(canvas!).color.match(/[\d.]+/g);
    tint = m ? `${m[0]}, ${m[1]}, ${m[2]}` : "0, 0, 0";
  }

  function born(fromTop: boolean): Shape {
    const size = season === "winter" ? 1.5 + Math.random() * 2.5 : 5 + Math.random() * 9;
    return {
      x: Math.random() * w,
      y: fromTop ? -20 : Math.random() * h,
      vy: (season === "winter" ? 0.25 : 0.35) + Math.random() * 0.5,
      sway: 0.4 + Math.random() * 0.9,
      phase: Math.random() * Math.PI * 2,
      size,
      spin: (Math.random() - 0.5) * 0.03,
      a: 0.35 + Math.random() * 0.45,
    };
  }

  function resize(): void {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    w = window.innerWidth;
    h = window.innerHeight;
    canvas!.width = Math.floor(w * dpr);
    canvas!.height = Math.floor(h * dpr);
    ctx!.setTransform(dpr, 0, 0, dpr, 0, 0);
    const count = Math.min(90, Math.floor((w * h) / 14000));
    shapes = Array.from({ length: count }, () => born(false));
  }

  function draw(s: Shape, t: number): void {
    ctx!.save();
    ctx!.translate(s.x, s.y);
    ctx!.fillStyle = `rgba(${tint}, ${s.a})`;
    if (season === "winter") {
      ctx!.beginPath();
      ctx!.arc(0, 0, s.size, 0, Math.PI * 2);
      ctx!.fill();
    } else {
      ctx!.rotate(s.phase + t * s.spin * 0.06);
      ctx!.beginPath();
      // A leaf or petal: two arcs meeting at the tips.
      ctx!.moveTo(0, -s.size);
      ctx!.quadraticCurveTo(s.size * 0.9, 0, 0, s.size);
      ctx!.quadraticCurveTo(-s.size * 0.9, 0, 0, -s.size);
      ctx!.fill();
    }
    ctx!.restore();
  }

  function frame(t: number, advance: boolean): void {
    ctx!.clearRect(0, 0, w, h);
    for (const s of shapes) {
      if (advance) {
        s.y += s.vy;
        s.x += Math.sin(t * 0.001 * s.sway + s.phase) * 0.4;
        if (s.y > h + 20) Object.assign(s, born(true));
      }
      draw(s, t);
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
    loadTint();
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
