// The theme toggle island: cycles auto → light → dark.
//
// The no-flash <script> in the layout's <head> already applied the stored
// choice before first paint; this island only owns the button. Without JS
// the button stays hidden and the site follows the system preference.

type Mode = "auto" | "light" | "dark";

const KEY = "cherry-theme";
const CYCLE: Record<Mode, Mode> = { auto: "light", light: "dark", dark: "auto" };

function storedMode(): Mode {
  const value = localStorage.getItem(KEY);
  return value === "light" || value === "dark" ? value : "auto";
}

function apply(mode: Mode): void {
  if (mode === "auto") {
    delete document.documentElement.dataset.theme;
    localStorage.removeItem(KEY);
  } else {
    document.documentElement.dataset.theme = mode;
    localStorage.setItem(KEY, mode);
  }
}

function render(button: HTMLElement, mode: Mode): void {
  const label = button.querySelector<HTMLElement>("[data-theme-label]");
  if (label) label.textContent = mode;
  button.setAttribute("aria-label", `Theme: ${mode}. Activate to change.`);
  for (const icon of button.querySelectorAll<HTMLElement>("[data-theme-icon]")) {
    icon.style.display = icon.dataset.themeIcon === mode ? "" : "none";
  }
}

const button = document.querySelector<HTMLElement>(".theme-toggle");
if (button) {
  let mode = storedMode();
  render(button, mode);
  button.dataset.ready = "";
  button.addEventListener("click", () => {
    mode = CYCLE[mode];
    apply(mode);
    render(button, mode);
  });
}

export {};
