// Dev-only live-reload client, injected into HTML by `cherry serve`.
// EventSource reconnects on its own while the server restarts.
const source = new EventSource("/__cherry/reload");
source.onmessage = () => location.reload();

export {};
