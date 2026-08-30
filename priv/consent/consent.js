"use strict";(()=>{var r="cherry-consent",m="This site would use Google Analytics cookies to count visits. Nothing is stored unless you agree.",h=document.currentScript,o=h?.dataset.cherryConsentId??"";function c(){try{let e=localStorage.getItem(r);return e==="granted"||e==="denied"?e:null}catch{return null}}function y(e){try{localStorage.setItem(r,e)}catch{}}function l(){if(!o||document.getElementById("cherry-ga"))return;let e=document.createElement("script");e.id="cherry-ga",e.async=!0,e.src="https://www.googletagmanager.com/gtag/js?id="+encodeURIComponent(o),document.head.appendChild(e),window.dataLayer=window.dataLayer||[];function t(...n){window.dataLayer.push(arguments)}t("js",new Date),t("config",o)}var g=`
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
`;function p(){if(document.getElementById("cherry-consent-style"))return;let e=document.createElement("style");e.id="cherry-consent-style",e.textContent=g,document.head.insertBefore(e,document.head.firstChild)}function a(e,t){let n=document.createElement("button");return n.type="button",n.textContent=e,n.addEventListener("click",t),n}function u(){if(document.querySelector(".cherry-consent"))return;p();let e=document.createElement("div");e.className="cherry-consent",e.setAttribute("role","dialog"),e.setAttribute("aria-label","Cookie consent");let t=document.createElement("p");t.className="cherry-consent-text",t.textContent=m;let n=document.createElement("div");n.className="cherry-consent-actions";function i(d){y(d),e.remove(),d==="granted"&&l()}n.appendChild(a("Accept",()=>i("granted"))),n.appendChild(a("Reject",()=>i("denied"))),e.appendChild(t),e.appendChild(n),document.body.appendChild(e)}function s(){document.querySelectorAll("[data-cherry-consent-reopen]").forEach(e=>{e.addEventListener("click",t=>{t.preventDefault(),window.cherryConsent?.reset()})}),c()===null&&u()}window.cherryConsent={choice:c,reset(){try{localStorage.removeItem(r)}catch{}u()}};c()==="granted"&&l();document.readyState==="loading"?document.addEventListener("DOMContentLoaded",s):s();})();
