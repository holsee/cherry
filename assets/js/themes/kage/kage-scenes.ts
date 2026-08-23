// Kage's scenes: blocks rise into view as they are scrolled to, the mast
// hides while reading down and returns on the way up, and a hairline of
// progress crosses the top. The `kage-js` class on <html> is what lets
// the stylesheet hide anything at all, so without this script every
// block is simply visible.

const root = document.documentElement;
root.classList.add("kage-js");

const blocks = Array.from(
  document.querySelectorAll<HTMLElement>(
    "main article > *, main .profile > *, main .timeline-year, main .cv > *, main .post-list > li, main .hero-home > *"
  )
);

// Blocks already in the first viewport are never hidden: they get both
// classes in the same frame, before first paint, so nothing depends on
// an observer tick that some engines skip on a fresh navigation.
const fold = window.innerHeight;
const below = blocks.filter((el) => {
  el.classList.add("kage-scene");
  if (el.getBoundingClientRect().top < fold) {
    el.classList.add("is-seen");
    return false;
  }
  return true;
});

if ("IntersectionObserver" in window) {
  let pending = 0;
  const seen = new IntersectionObserver(
    (entries) => {
      for (const entry of entries) {
        if (!entry.isIntersecting) continue;
        const el = entry.target as HTMLElement;
        // A small stagger for blocks revealed in the same tick.
        el.style.setProperty("--kage-delay", `${Math.min(pending, 6) * 70}ms`);
        pending++;
        el.classList.add("is-seen");
        seen.unobserve(el);
      }
      requestAnimationFrame(() => (pending = 0));
    },
    { rootMargin: "0px 0px -10% 0px", threshold: 0.05 }
  );
  for (const el of below) seen.observe(el);
  // Belt and braces: a bfcache restore shows whatever is on screen.
  window.addEventListener("pageshow", () => {
    for (const el of below) {
      if (!el.classList.contains("is-seen") && el.getBoundingClientRect().top < window.innerHeight) {
        el.classList.add("is-seen");
        seen.unobserve(el);
      }
    }
  });
} else {
  for (const el of below) el.classList.add("is-seen");
}

const progress = document.querySelector<HTMLElement>(".kage-progress");
const mast = document.querySelector<HTMLElement>(".site-header");
let lastY = window.scrollY;

function onScroll(): void {
  const y = window.scrollY;
  const max = root.scrollHeight - window.innerHeight;
  if (progress) progress.style.width = `${max > 0 ? Math.min(100, (y / max) * 100) : 0}%`;
  if (mast) mast.classList.toggle("is-hidden", y > lastY && y > 120);
  lastY = y;
}

window.addEventListener("scroll", onScroll, { passive: true });
onScroll();

export {};
