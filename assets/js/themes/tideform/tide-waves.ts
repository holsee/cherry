// Tideform's swell: four layers of summed sines rolling across the band
// canvas under the mast, far to near, each filled with the accent mixed
// deeper into the ground. Colours come from the tokens through the probe
// bridge and are re-read on rendition changes. No canvas leaves the CSS
// horizon; reduced motion freezes one swell; the loop stops once the
// band has scrolled off.

const canvas = document.querySelector<HTMLCanvasElement>(".tide-waves");
const ctx = canvas?.getContext("2d", { alpha: true });

if (canvas && ctx) {
  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);

  type RGB = [number, number, number];

  function token(name: string): RGB {
    probe.style.color = `var(${name})`;
    const m = getComputedStyle(probe).color.match(/[\d.]+/g);
    return m ? [Number(m[0]), Number(m[1]), Number(m[2])] : [0, 0, 0];
  }

  function mix(a: RGB, b: RGB, t: number): string {
    const c = (i: 0 | 1 | 2): number => Math.round(a[i] * t + b[i] * (1 - t));
    return `rgb(${c(0)}, ${c(1)}, ${c(2)})`;
  }

  const layers = [
    { depth: 0.15, amp: 10, speed: 0.00018, freq: 0.0045, base: 0.42 },
    { depth: 0.28, amp: 14, speed: 0.00026, freq: 0.0062, base: 0.55 },
    { depth: 0.42, amp: 16, speed: 0.00034, freq: 0.0081, base: 0.68 },
    { depth: 0.6, amp: 18, speed: 0.00044, freq: 0.0105, base: 0.8 },
  ];
  let fills: string[] = [];
  let w = 0;
  let h = 0;

  function loadTokens(): void {
    const ground = token("--color-bg");
    const accent = token("--color-accent");
    fills = layers.map((l) => mix(accent, ground, l.depth));
  }

  function resize(): void {
    const dpr = Math.min(window.devicePixelRatio || 1, 2);
    const rect = canvas!.getBoundingClientRect();
    w = rect.width;
    h = rect.height;
    canvas!.width = Math.floor(w * dpr);
    canvas!.height = Math.floor(h * dpr);
    ctx!.setTransform(dpr, 0, 0, dpr, 0, 0);
  }

  function frame(t: number): void {
    ctx!.clearRect(0, 0, w, h);
    layers.forEach((l, i) => {
      ctx!.fillStyle = fills[i] ?? "transparent";
      ctx!.beginPath();
      ctx!.moveTo(0, h);
      for (let x = 0; x <= w; x += 6) {
        const y =
          h * l.base +
          Math.sin(x * l.freq + t * l.speed) * l.amp +
          Math.sin(x * l.freq * 2.3 - t * l.speed * 1.7) * l.amp * 0.4 +
          Math.sin(x * l.freq * 0.5 + t * l.speed * 0.6 + i) * l.amp * 0.7;
        ctx!.lineTo(x, y);
      }
      ctx!.lineTo(w, h);
      ctx!.closePath();
      ctx!.fill();
    });
  }

  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  let raf = 0;

  function loop(t: number): void {
    if (canvas!.getBoundingClientRect().bottom > 0) frame(t);
    raf = requestAnimationFrame(loop);
  }

  function start(): void {
    cancelAnimationFrame(raf);
    loadTokens();
    resize();
    if (still.matches || document.hidden) {
      frame(4000);
    } else {
      raf = requestAnimationFrame(loop);
    }
  }

  window.addEventListener("resize", () => {
    resize();
    if (still.matches) frame(4000);
  });
  document.addEventListener("visibilitychange", start);
  still.addEventListener("change", start);
  new MutationObserver(start).observe(document.documentElement, {
    attributes: true,
    attributeFilter: ["data-theme"],
  });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", start);

  canvas.dataset.ready = "";
  start();
}

export {};
