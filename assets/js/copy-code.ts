/**
 * Copy buttons for code blocks.
 *
 * Targets every `pre` plus any element opting in with `data-copy`
 * (the landing page's install one-liners). Progressive enhancement:
 * no clipboard API, no buttons.
 *
 * States are icons, not words: the button stays a compact square that
 * reads in any language and covers almost none of the code beneath it.
 * The words live in aria-label.
 */

const RESET_MS = 1600;

const SVG_OPEN =
  '<svg viewBox="0 0 24 24" width="14" height="14" aria-hidden="true" ' +
  'fill="none" stroke="currentColor" stroke-width="2" ' +
  'stroke-linecap="round" stroke-linejoin="round">';

const ICON_COPY =
  SVG_OPEN +
  '<rect x="9" y="9" width="13" height="13" rx="2"/>' +
  '<path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>';

const ICON_DONE = SVG_OPEN + '<path d="M20 6 9 17l-5-5"/></svg>';

const ICON_FAIL = SVG_OPEN + '<path d="M18 6 6 18M6 6l12 12"/></svg>';

function copyText(target: HTMLElement): string {
  const code = target.querySelector("code");
  const text = (code ?? target).innerText;
  return text.replace(/\n$/, "");
}

function setState(button: HTMLButtonElement, icon: string, label: string): void {
  button.innerHTML = icon;
  button.setAttribute("aria-label", label);
}

function attach(target: HTMLElement): void {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "copy-code";
  button.title = "Copy";
  setState(button, ICON_COPY, "Copy to clipboard");

  let timer: number | undefined;
  button.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(copyText(target));
      setState(button, ICON_DONE, "Copied");
      button.classList.add("copy-code-done");
    } catch {
      setState(button, ICON_FAIL, "Copy failed");
    }
    window.clearTimeout(timer);
    timer = window.setTimeout(() => {
      setState(button, ICON_COPY, "Copy to clipboard");
      button.classList.remove("copy-code-done");
    }, RESET_MS);
  });

  if (target.tagName === "PRE") {
    // Wrap so the button anchors to the block, not the scrolling content.
    const wrap = document.createElement("div");
    wrap.className = "code-copy";
    target.replaceWith(wrap);
    wrap.appendChild(target);
    wrap.appendChild(button);
  } else {
    target.appendChild(button);
  }
}

function init(): void {
  if (!("clipboard" in navigator)) return;
  const targets = document.querySelectorAll<HTMLElement>("pre, [data-copy]");
  targets.forEach((el) => {
    if (el.parentElement?.classList.contains("code-copy")) return;
    if (el.querySelector(":scope > .copy-code")) return;
    attach(el);
  });
}

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}

export {};
