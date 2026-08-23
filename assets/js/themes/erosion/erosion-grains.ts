// Erosion's sediment: grains carried on a slow flow field, drawn as tiny
// rectangles onto a canvas that is dimmed rather than cleared each frame,
// so deposits build up and erode. Colours come from the theme tokens
// (ground and accent) through the probe bridge, re-read on rendition
// changes. No canvas leaves clean stone; reduced motion paints one
// settled deposit; a hidden tab pauses the loop.

const canvas = document.querySelector<HTMLCanvasElement>(".erosion-grains");
const ctx = canvas?.getContext("2d", { alpha: false });

if (canvas && ctx) {
  type Grain = { x: number; y: number; life: number; hue: number };

  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);

  function token(name: string): string {
    probe.style.color = `var(${name})`;
    return getComputedStyle(probe).color;
  }

  function parts(color: string): string {
    const m = color.match(/[\d.]+/g);
    return m ? `${m[0]}, ${m[1]}, ${m[2]}` : "0, 0, 0";
  }

  let ground = "rgb(0, 0, 0)";
  let ink = "0, 0, 0";
  let accent = "0, 0, 0";
  let grains: Grain[] = [];
  let w = 0;
  let h = 0;
  let dpr = 1;
  const centre = { x: 0.5, y: 0.5 };

  function loadTokens(): void {
    ground = token("--color-bg");
    ink = parts(token("--color-muted"));
    accent = parts(token("--color-accent"));
  }

  function born(): Grain {
    return { x: Math.random() * w, y: Math.random() * h, life: 80 + Math.random() * 220, hue: Math.random() };
  }

  function resize(): void {
    dpr = Math.min(window.devicePixelRatio || 1, 1.5);
    w = window.innerWidth;
    h = window.innerHeight;
    canvas!.width = Math.floor(w * dpr);
    canvas!.height = Math.floor(h * dpr);
    ctx!.setTransform(dpr, 0, 0, dpr, 0, 0);
    const count = Math.min(2400, Math.floor((w * h) / 700));
    grains = Array.from({ length: count }, born);
    ctx!.fillStyle = ground;
    ctx!.fillRect(0, 0, w, h);
  }

  // The flow field: two crossed sine sheets drifting in time, bent
  // gently toward the pointer's side of the page.
  function flow(x: number, y: number, t: number): [number, number] {
    const nx = x / w - centre.x;
    const ny = y / h - centre.y;
    const a =
      Math.sin(y * 0.006 + t * 0.00025) * 1.3 +
      Math.cos(x * 0.004 - t * 0.0002) * 0.9 +
      Math.atan2(ny, nx) * 0.25;
    return [Math.cos(a), Math.sin(a)];
  }

  function frame(t: number, steps: number): void {
    // Dim, never clear: the trail is the deposit.
    ctx!.globalAlpha = 0.06;
    ctx!.fillStyle = ground;
    ctx!.fillRect(0, 0, w, h);
    ctx!.globalAlpha = 1;
    for (let s = 0; s < steps; s++) {
      for (const g of grains) {
        const [fx, fy] = flow(g.x, g.y, t);
        g.x += fx * 0.9;
        g.y += fy * 0.9 + 0.15;
        g.life -= 1;
        if (g.life <= 0 || g.x < 0 || g.x > w || g.y < 0 || g.y > h) Object.assign(g, born());
        const a = Math.min(1, g.life / 60) * 0.3;
        ctx!.fillStyle = g.hue > 0.82 ? `rgba(${accent}, ${a})` : `rgba(${ink}, ${a * 0.6})`;
        ctx!.fillRect(g.x, g.y, 1.2, 1.2);
      }
    }
  }

  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  let raf = 0;

  function loop(t: number): void {
    frame(t, 1);
    raf = requestAnimationFrame(loop);
  }

  function start(): void {
    cancelAnimationFrame(raf);
    loadTokens();
    ctx!.fillStyle = ground;
    ctx!.fillRect(0, 0, w, h);
    if (still.matches || document.hidden) {
      for (let i = 0; i < 40; i++) frame(i * 16, 3);
    } else {
      raf = requestAnimationFrame(loop);
    }
  }

  window.addEventListener("resize", () => {
    resize();
    start();
  });
  window.addEventListener("pointermove", (e) => {
    centre.x = e.clientX / w;
    centre.y = e.clientY / h;
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
