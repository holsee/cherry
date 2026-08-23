// Cinema's film: the <video> plays by its own attributes; this island only
// holds it still when the visitor asked for stillness (reduced motion),
// is saving data, or has scrolled the hero out of view.

const video = document.querySelector<HTMLVideoElement>(".hero-video");

if (video) {
  const still = window.matchMedia("(prefers-reduced-motion: reduce)");
  const nav = navigator as Navigator & { connection?: { saveData?: boolean } };
  const frugal = Boolean(nav.connection && nav.connection.saveData);
  let inView = true;

  function settle(): void {
    if (still.matches || frugal || !inView || document.hidden) {
      video!.pause();
    } else {
      const p = video!.play();
      if (p && typeof p.catch === "function") p.catch(() => undefined);
    }
  }

  if ("IntersectionObserver" in window) {
    new IntersectionObserver(
      (entries) => {
        inView = entries.some((e) => e.isIntersecting);
        settle();
      },
      { threshold: 0.05 }
    ).observe(video);
  }
  still.addEventListener("change", settle);
  document.addEventListener("visibilitychange", settle);
  settle();
}

export {};
