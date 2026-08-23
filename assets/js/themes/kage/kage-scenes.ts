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
  for (const el of blocks) {
    el.classList.add("kage-scene");
    seen.observe(el);
  }
  // Some engines skip the first observer tick for content already in
  // view on a fresh navigation or a bfcache restore; anything in the
  // first viewport is shown regardless, shortly after load.
  const reveal = (): void => {
    const h = window.innerHeight;
    for (const el of blocks) {
      if (el.classList.contains("is-seen")) continue;
      if (el.getBoundingClientRect().top < h) {
        el.classList.add("is-seen");
        seen.unobserve(el);
      }
    }
  };
  window.addEventListener("load", () => setTimeout(reveal, 400));
  window.addEventListener("pageshow", reveal);
} else {
  for (const el of blocks) el.classList.add("kage-scene", "is-seen");
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
