// Flipdot's board: every [data-flip] element and every main h1 arrives
// like a split-flap display. The text is wrapped into per-character
// cells; each cell cycles through glyphs a few ticks before settling
// on its own character, left to right. It runs once, when the element
// enters the viewport, and never loops. Reduced motion: text is just
// there. Without this script: the text is just there.

const still = window.matchMedia("(prefers-reduced-motion: reduce)");
const targets = Array.from(document.querySelectorAll<HTMLElement>("[data-flip], main h1"));
const GLYPHS = "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";

if (!still.matches && targets.length) {
  document.documentElement.classList.add("flip-js");

  const prepare = (el: HTMLElement): HTMLElement[] => {
    const text = el.textContent ?? "";
    el.setAttribute("aria-label", text);
    el.textContent = "";
    const cells: HTMLElement[] = [];
    text.split(" ").forEach((word, wi) => {
      if (wi > 0) el.appendChild(document.createTextNode(" "));
      const span = document.createElement("span");
      span.className = "flip-word";
      span.setAttribute("aria-hidden", "true");
      for (const ch of word) {
        const cell = document.createElement("span");
        cell.className = "flip-cell";
        cell.textContent = ch;
        cell.dataset.final = ch;
        span.appendChild(cell);
        cells.push(cell);
      }
      el.appendChild(span);
    });
    return cells;
  };

  const run = (cells: HTMLElement[]): void => {
    cells.forEach((cell, i) => {
      const final = cell.dataset.final;
      if (!final) return;
      const ticks = 3 + Math.floor(Math.random() * 5) + Math.floor(i / 3);
      let n = 0;
      cell.classList.add("is-flipping");
      const tick = (): void => {
        if (n++ < ticks) {
          cell.textContent = GLYPHS[Math.floor(Math.random() * GLYPHS.length)] ?? final;
          setTimeout(tick, 45 + Math.random() * 30);
        } else {
          cell.textContent = final;
          cell.classList.remove("is-flipping");
        }
      };
      setTimeout(tick, i * 22);
    });
  };

  const seen = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        seen.unobserve(entry.target);
        run(prepare(entry.target as HTMLElement));
      }
    },
    { threshold: 0.1 }
  );
  for (const el of targets) seen.observe(el);
}

export {};
