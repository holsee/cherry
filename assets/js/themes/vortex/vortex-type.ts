// Vortex's landing: split the page's first h1 into letter spans with a
// staggered delay so the title arrives letter by letter (CSS animates).
// Reduced motion is honoured in CSS; without this script the title is
// simply whole. Anchors inside the h1 are left intact.

const title = document.querySelector<HTMLHeadingElement>("main h1");

if (title && !window.matchMedia("(prefers-reduced-motion: reduce)").matches) {
  // Assistive tech reads the whole title, not forty spans.
  title.setAttribute("aria-label", title.textContent || "");
  const frag = document.createDocumentFragment();
  let i = 0;
  for (const node of Array.from(title.childNodes)) {
    if (node.nodeType !== Node.TEXT_NODE) {
      frag.appendChild(node);
      continue;
    }
    // Words stay unbreakable so the landing never splits one across lines.
    for (const word of (node.textContent || "").split(/(\s+)/)) {
      if (word.trim() === "") {
        if (word) frag.appendChild(document.createTextNode(" "));
        continue;
      }
      const w = document.createElement("span");
      w.className = "vx-word";
      for (const ch of word) {
        const span = document.createElement("span");
        span.className = "vx-letter";
        span.textContent = ch;
        span.style.setProperty("--vx-delay", `${Math.min(i, 40) * 28}ms`);
        i++;
        w.appendChild(span);
      }
      frag.appendChild(w);
    }
  }
  title.replaceChildren(frag);
}

export {};
