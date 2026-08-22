// Dev-only live-reload client, injected into HTML by `cherry serve`.
// EventSource reconnects on its own while the server restarts.
const source = new EventSource("/__cherry/reload");
source.onmessage = () => location.reload();

// A page leaving the viewport (navigation, back/forward cache) must not
// hold one of the browser's six per-host sockets hostage; a cached page
// restored later has missed any rebuilds, so it reloads instead.
addEventListener("pagehide", () => source.close());
addEventListener("pageshow", (event) => {
  if (event.persisted) location.reload();
});

export {};
