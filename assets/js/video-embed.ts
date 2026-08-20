// The video facade island: `::video{youtube="…"}` renders as a plain
// link that makes no third-party request. This upgrades the click to an
// in-place youtube-nocookie embed; without JS the link goes to YouTube.

const EMBED = "https://www.youtube-nocookie.com/embed/";

for (const link of document.querySelectorAll<HTMLAnchorElement>("a[data-video-embed]")) {
  link.addEventListener("click", (event) => {
    event.preventDefault();
    const id = link.dataset.videoEmbed ?? "";
    const title = link.querySelector(".video-embed-title")?.textContent ?? "Video";

    const frame = document.createElement("iframe");
    frame.className = "video-embed-frame";
    frame.src = `${EMBED}${encodeURIComponent(id)}?autoplay=1`;
    frame.title = title;
    frame.allow = "autoplay; encrypted-media; picture-in-picture";
    frame.allowFullscreen = true;
    link.replaceWith(frame);
  });
}

export {};
