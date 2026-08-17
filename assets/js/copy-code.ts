/**
 * Copy buttons for code blocks.
 *
 * Targets every `pre` plus any element opting in with `data-copy`
 * (the landing page's install one-liners). Progressive enhancement:
 * no clipboard API, no buttons.
 */

const RESET_MS = 1600;

function copyText(target: HTMLElement): string {
  const code = target.querySelector("code");
  const text = (code ?? target).innerText;
  return text.replace(/\n$/, "");
}

function attach(target: HTMLElement): void {
  const button = document.createElement("button");
  button.type = "button";
  button.className = "copy-code";
  button.textContent = "copy";
  button.setAttribute("aria-label", "Copy to clipboard");

  let timer: number | undefined;
  button.addEventListener("click", async () => {
    try {
      await navigator.clipboard.writeText(copyText(target));
      button.textContent = "copied";
      button.classList.add("copy-code-done");
    } catch {
      button.textContent = "failed";
    }
    window.clearTimeout(timer);
    timer = window.setTimeout(() => {
      button.textContent = "copy";
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
