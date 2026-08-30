/**
 * Consent gate for analytics that stores something on the visitor's device.
 *
 * This file only reaches a page when the site configures a provider whose
 * consent class is `:required` — GA4 and its `_ga` cookies. The cookieless
 * providers (Cloudflare, Plausible, GoatCounter) render their beacon
 * directly and never ship this code: a banner for them would be consent
 * theatre, and it trains people to dismiss the banners that matter.
 *
 * The gate is real, not decorative. The provider's script is not in the
 * document until the visitor accepts, so a page view taken before the
 * choice is made stores nothing. Recording the choice itself is the one
 * piece of storage the ePrivacy Directive exempts as strictly necessary,
 * which is why localStorage is fair game here and needs no consent of
 * its own.
 *
 * Accept and reject are the same button at the same size: under EDPB and
 * CNIL guidance refusing must be exactly as easy as agreeing, so an
 * accept-only bar — or a reject hidden a layer down — is non-compliant.
 */

const KEY = "cherry-consent";

const MESSAGE =
  "This site would use Google Analytics cookies to count visits. " +
  "Nothing is stored unless you agree.";

type Choice = "granted" | "denied";

declare global {
  interface Window {
    cherryConsent?: { choice(): Choice | null; reset(): void };
    dataLayer?: unknown[];
  }
}

const script = document.currentScript as HTMLScriptElement | null;
const measurementId = script?.dataset["cherryConsentId"] ?? "";

function stored(): Choice | null {
  try {
    const value = localStorage.getItem(KEY);
    return value === "granted" || value === "denied" ? value : null;
  } catch {
    // Private mode or storage disabled: no memory, so the bar returns
    // next page view. Erring toward asking again beats assuming consent.
    return null;
  }
}

function remember(choice: Choice): void {
  try {
    localStorage.setItem(KEY, choice);
  } catch {
    // The choice still holds for this page view; only the memory is lost.
  }
}

/** Loads GA4 — called only from a granted choice, never on page load. */
function activate(): void {
  if (!measurementId || document.getElementById("cherry-ga")) return;

  const tag = document.createElement("script");
  tag.id = "cherry-ga";
  tag.async = true;
  tag.src =
    "https://www.googletagmanager.com/gtag/js?id=" + encodeURIComponent(measurementId);
  document.head.appendChild(tag);

  window.dataLayer = window.dataLayer || [];
  function gtag(..._args: unknown[]): void {
    // GA reads the arguments object positionally; an array is not the
    // same shape, so this stays the vendor's own idiom.
    // eslint-disable-next-line prefer-rest-params
    window.dataLayer!.push(arguments);
  }
  gtag("js", new Date());
  gtag("config", measurementId);
}

// Its own layer, inserted as the head's first stylesheet, so the layer
// lands below the theme's `@layer theme`: a theme restyles the bar by
// naming it, and an unlayered assets/custom.css beats both.
const CSS = `
@layer cherry {
.cherry-consent {
  position: fixed;
  inset-inline: 0;
  inset-block-end: 0;
  z-index: 2147483647;
  display: flex;
  flex-wrap: wrap;
  gap: 0.75rem 1.25rem;
  align-items: center;
  justify-content: center;
  padding: 0.875rem 1.25rem;
  background: var(--color-surface, var(--color-bg, #fff));
  color: var(--color-fg, #111);
  border-block-start: 1px solid var(--color-border, #ddd);
  font: inherit;
  font-size: 0.875rem;
  line-height: 1.5;
}
.cherry-consent-text { margin: 0; max-width: 60ch; }
.cherry-consent-actions { display: flex; gap: 0.5rem; flex-shrink: 0; }
.cherry-consent button {
  font: inherit;
  font-size: 0.875rem;
  padding: 0.4rem 1.1rem;
  cursor: pointer;
  color: inherit;
  background: transparent;
  border: 1px solid var(--color-border, #ddd);
  border-radius: 0.25rem;
}
.cherry-consent button:hover { border-color: var(--color-accent, currentColor); }
.cherry-consent button:focus-visible {
  outline: 2px solid var(--color-accent, currentColor);
  outline-offset: 2px;
}
}
`;

function styles(): void {
  if (document.getElementById("cherry-consent-style")) return;
  const style = document.createElement("style");
  style.id = "cherry-consent-style";
  style.textContent = CSS;
  document.head.insertBefore(style, document.head.firstChild);
}

function button(label: string, onClick: () => void): HTMLButtonElement {
  const element = document.createElement("button");
  element.type = "button";
  element.textContent = label;
  element.addEventListener("click", onClick);
  return element;
}

function ask(): void {
  if (document.querySelector(".cherry-consent")) return;
  styles();

  const bar = document.createElement("div");
  bar.className = "cherry-consent";
  bar.setAttribute("role", "dialog");
  bar.setAttribute("aria-label", "Cookie consent");

  const text = document.createElement("p");
  text.className = "cherry-consent-text";
  text.textContent = MESSAGE;

  const actions = document.createElement("div");
  actions.className = "cherry-consent-actions";

  function choose(choice: Choice): void {
    remember(choice);
    bar.remove();
    if (choice === "granted") activate();
  }

  actions.appendChild(button("Accept", () => choose("granted")));
  actions.appendChild(button("Reject", () => choose("denied")));

  bar.appendChild(text);
  bar.appendChild(actions);
  document.body.appendChild(bar);
}

function init(): void {
  // Withdrawing consent has to be as easy as giving it: any element the
  // theme or a page marks up re-opens the bar.
  document.querySelectorAll("[data-cherry-consent-reopen]").forEach((element) => {
    element.addEventListener("click", (event) => {
      event.preventDefault();
      window.cherryConsent?.reset();
    });
  });

  if (stored() === null) ask();
}

window.cherryConsent = {
  choice: stored,
  reset(): void {
    try {
      localStorage.removeItem(KEY);
    } catch {
      // Nothing stored to clear; the bar still returns below.
    }
    ask();
  },
};

if (stored() === "granted") activate();

if (document.readyState === "loading") {
  document.addEventListener("DOMContentLoaded", init);
} else {
  init();
}

export {};
