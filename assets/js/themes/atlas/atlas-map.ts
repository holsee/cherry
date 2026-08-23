// Atlas's map: turns the grouped post list into a pannable, zoomable
// plane. Cards and regions already carry their coordinates as CSS
// variables from the template; this island only moves the camera.
//
//   - drag (pointer) and wheel pan; ctrl/cmd+wheel and pinch zoom
//   - arrow keys pan, +/- zoom, 0 recentres; the viewport is focusable
//   - a minimap shows every card and the camera's window
//   - "List view" flips back to the stacked list (the no-JS rendering)
//
// Without this script the list is the page. Reduced motion drops the
// camera easing; nothing else changes.

const root = document.querySelector<HTMLElement>("[data-atlas]");
const viewport = root?.querySelector<HTMLElement>("[data-atlas-viewport]");
const plane = root?.querySelector<HTMLElement>("[data-atlas-plane]");
const minimap = root?.querySelector<HTMLCanvasElement>("[data-atlas-minimap]");
const toggle = root?.querySelector<HTMLButtonElement>("[data-atlas-toggle]");

if (root && viewport && plane) {
  document.documentElement.classList.add("atlas-js");
  const view: HTMLElement = viewport;
  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  const rem = parseFloat(getComputedStyle(document.documentElement).fontSize) || 16;

  type Pt = { x: number; y: number; el: HTMLElement };
  const cards: Pt[] = Array.from(root.querySelectorAll<HTMLElement>(".atlas-card")).map((el) => ({
    x: parseFloat(el.style.getPropertyValue("--ax")) * rem,
    y: parseFloat(el.style.getPropertyValue("--ay")) * rem,
    el,
  }));
  const bounds = cards.reduce(
    (b, c) => ({ x0: Math.min(b.x0, c.x), x1: Math.max(b.x1, c.x), y0: Math.min(b.y0, c.y), y1: Math.max(b.y1, c.y) }),
    { x0: Infinity, x1: -Infinity, y0: Infinity, y1: -Infinity }
  );
  const pad = 14 * rem;

  let cx = 0;
  let cy = 0;
  let zoom = 1;
  let tx = 0;
  let ty = 0;
  let tz = 1;
  let raf = 0;

  const fit = (): void => {
    const w = viewport.clientWidth;
    const h = viewport.clientHeight;
    const spanX = bounds.x1 - bounds.x0 + pad * 2;
    const spanY = bounds.y1 - bounds.y0 + pad * 2;
    tz = Math.min(1, Math.max(0.35, Math.min(w / spanX, h / spanY)));
    tx = (bounds.x0 + bounds.x1) / 2;
    ty = (bounds.y0 + bounds.y1) / 2;
  };

  const apply = (): void => {
    const w = viewport.clientWidth;
    const h = viewport.clientHeight;
    plane.style.transform = `translate(${w / 2 - cx * zoom}px, ${h / 2 - cy * zoom}px) scale(${zoom})`;
    drawMinimap();
  };

  const tick = (): void => {
    const k = still.matches ? 1 : 0.18;
    cx += (tx - cx) * k;
    cy += (ty - cy) * k;
    zoom += (tz - zoom) * k;
    apply();
    if (Math.abs(tx - cx) > 0.2 || Math.abs(ty - cy) > 0.2 || Math.abs(tz - zoom) > 0.002) {
      raf = requestAnimationFrame(tick);
    } else {
      cx = tx;
      cy = ty;
      zoom = tz;
      apply();
      raf = 0;
    }
  };
  const go = (): void => {
    if (!raf) raf = requestAnimationFrame(tick);
  };

  // ---- minimap ----
  let ink = "0, 0, 0";
  let accent = "0, 0, 0";
  const probe = document.createElement("div");
  probe.style.display = "none";
  document.body.appendChild(probe);
  const token = (name: string): string => {
    probe.style.color = `var(${name})`;
    const m = getComputedStyle(probe).color.match(/[\d.]+/g);
    return m ? `${m[0]}, ${m[1]}, ${m[2]}` : "0, 0, 0";
  };
  const loadTokens = (): void => {
    ink = token("--color-muted");
    accent = token("--color-accent");
  };
  const mctx = minimap?.getContext("2d");
  function drawMinimap(): void {
    if (!minimap || !mctx) return;
    const W = minimap.width;
    const H = minimap.height;
    const sx = (W - 12) / (bounds.x1 - bounds.x0 + pad * 2);
    const sy = (H - 12) / (bounds.y1 - bounds.y0 + pad * 2);
    const s = Math.min(sx, sy);
    const ox = 6 + ((W - 12) - (bounds.x1 - bounds.x0 + pad * 2) * s) / 2 - (bounds.x0 - pad) * s;
    const oy = 6 + ((H - 12) - (bounds.y1 - bounds.y0 + pad * 2) * s) / 2 - (bounds.y0 - pad) * s;
    mctx.clearRect(0, 0, W, H);
    mctx.fillStyle = `rgba(${ink}, 0.7)`;
    for (const c of cards) {
      mctx.beginPath();
      mctx.arc(ox + c.x * s, oy + c.y * s, 1.6, 0, Math.PI * 2);
      mctx.fill();
    }
    const vw = (view.clientWidth / zoom) * s;
    const vh = (view.clientHeight / zoom) * s;
    mctx.strokeStyle = `rgba(${accent}, 0.9)`;
    mctx.lineWidth = 1;
    mctx.strokeRect(ox + cx * s - vw / 2, oy + cy * s - vh / 2, vw, vh);
  }

  // ---- input ----
  let dragging = false;
  let moved = false;
  let lx = 0;
  let ly = 0;
  viewport.addEventListener("pointerdown", (e) => {
    if (e.button !== 0) return;
    dragging = true;
    moved = false;
    lx = e.clientX;
    ly = e.clientY;
    viewport.setPointerCapture(e.pointerId);
  });
  viewport.addEventListener("pointermove", (e) => {
    if (!dragging) return;
    const dx = e.clientX - lx;
    const dy = e.clientY - ly;
    if (Math.abs(dx) + Math.abs(dy) > 3) moved = true;
    lx = e.clientX;
    ly = e.clientY;
    tx -= dx / zoom;
    ty -= dy / zoom;
    cx = tx;
    cy = ty;
    apply();
  });
  const release = (): void => {
    dragging = false;
    root.classList.toggle("is-dragging", false);
  };
  viewport.addEventListener("pointerup", release);
  viewport.addEventListener("pointercancel", release);
  // A drag must not open the card under the pointer.
  viewport.addEventListener("click", (e) => {
    if (moved) {
      e.preventDefault();
      e.stopPropagation();
      moved = false;
    }
  }, true);
  viewport.addEventListener("wheel", (e) => {
    e.preventDefault();
    if (e.ctrlKey || e.metaKey) {
      tz = Math.min(2.2, Math.max(0.3, tz * Math.exp(-e.deltaY * 0.0025)));
    } else {
      tx += e.deltaX / zoom;
      ty += e.deltaY / zoom;
    }
    go();
  }, { passive: false });
  viewport.addEventListener("keydown", (e) => {
    const step = 80 / zoom;
    switch (e.key) {
      case "ArrowLeft": tx -= step; break;
      case "ArrowRight": tx += step; break;
      case "ArrowUp": ty -= step; break;
      case "ArrowDown": ty += step; break;
      case "+": case "=": tz = Math.min(2.2, tz * 1.2); break;
      case "-": case "_": tz = Math.max(0.3, tz / 1.2); break;
      case "0": fit(); break;
      default: return;
    }
    e.preventDefault();
    go();
  });
  // Keyboard focus on a card brings it into the window.
  for (const c of cards) {
    c.el.querySelector("a")?.addEventListener("focus", () => {
      tx = c.x;
      ty = c.y;
      tz = Math.max(tz, 0.9);
      go();
    });
  }
  toggle?.addEventListener("click", () => {
    const list = root.classList.toggle("is-list");
    toggle.setAttribute("aria-pressed", String(list));
    toggle.textContent = list ? "Map view" : "List view";
    if (!list) {
      fit();
      cx = tx;
      cy = ty;
      zoom = tz;
      apply();
    }
  });

  // Paper gets the list.
  window.addEventListener("beforeprint", () => root.classList.add("is-list"));
  window.addEventListener("afterprint", () => root.classList.remove("is-list"));

  window.addEventListener("resize", () => {
    if (!root.classList.contains("is-list")) apply();
  });
  new MutationObserver(() => {
    loadTokens();
    drawMinimap();
  }).observe(document.documentElement, { attributes: true, attributeFilter: ["data-theme"] });
  window.matchMedia("(prefers-color-scheme: dark)").addEventListener("change", () => {
    loadTokens();
    drawMinimap();
  });

  loadTokens();
  fit();
  cx = tx;
  cy = ty;
  zoom = tz;
  apply();
}

export {};
