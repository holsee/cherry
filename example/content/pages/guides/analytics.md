---
title: Adding analytics
description: One config key, four providers, and the rule that decides whether a consent banner ships at all. Cookieless beacons, self-hosted instances, and a GA gate that actually gates.
---
# Adding analytics

Cherry ships no analytics. Set one key and it ships exactly one beacon, into a head block every theme carries — so you never eject a layout to paste a script tag, and your theme keeps upgrading.

```elixir
# cherry.exs
[
  title: "My site",
  url: "https://example.com",
  analytics: [cloudflare: "b4c1f0e2a7d94c11"]
]
```

That is the whole setup. Build, and every page carries it:

```html
<script defer src="https://static.cloudflareinsights.com/beacon.min.js" data-cf-beacon='{"token":"b4c1f0e2a7d94c11"}'></script>
```

## The rule that decides everything

Cherry classifies providers by **what they put on your visitor's device**, not by what the vendor calls itself. That single fact decides whether a consent banner ships.

| provider | value | stores anything? | banner |
|---|---|---|---|
| `cloudflare` | beacon token | no | none |
| `plausible` | your domain | no | none |
| `goatcounter` | your site code | no | none |
| `google` | GA4 `G-…` id | `_ga` cookies | consent gate |

The first three set no cookies, touch no storage, and don't fingerprint. The EU's ePrivacy rules turn on *storing or accessing information on the visitor's device* — so for these three nothing is triggered, and **Cherry shows no banner at all**. Not a hidden one, not a dismissed one: zero bytes.

This is deliberate. A cookie banner over a cookieless beacon asks permission that isn't required, and it teaches people to click through the banners that are.

## Cloudflare, Plausible, GoatCounter

Each takes one value — where to find it:

- **Cloudflare** — the dashboard's Web Analytics section gives you a snippet containing `data-cf-beacon='{"token": "…"}'`. Copy the token out of it.
- **Plausible** — the domain exactly as you registered it, e.g. `example.com`. It becomes `data-domain`, which is how Plausible tells your sites apart.
- **GoatCounter** — your site code, the subdomain of your dashboard: `mysite.goatcounter.com` means `mysite`.

```elixir
analytics: [plausible: "example.com"]
analytics: [goatcounter: "mysite"]
```

### Running your own instance

Plausible and GoatCounter are both self-hostable, so both take a `host:` override naming the origin that serves them:

```elixir
analytics: [plausible: [id: "example.com", host: "https://stats.example.com"]]
analytics: [goatcounter: [host: "https://stats.example.com"]]
```

GoatCounter needs no `id:` beside a `host:` — a self-hosted instance *is* the site. Plausible always needs one, because `data-domain` is still how it separates sites on one instance.

`host:` is an origin, not a script URL, because the two providers build different things from it. Plausible moves only its script; a self-hosted GoatCounter serves both its script and its count endpoint, where the hosted one splits them:

```html
<!-- goatcounter: "mysite" -->
<script async data-goatcounter="https://mysite.goatcounter.com/count" src="https://gc.zgo.at/count.js"></script>

<!-- goatcounter: [host: "https://stats.example.com"] -->
<script async data-goatcounter="https://stats.example.com/count" src="https://stats.example.com/count.js"></script>
```

Cloudflare and GA have no self-hosted edition, so `host:` is **refused** for them rather than quietly ignored:

```text
cloudflare has no self-hosted edition, so host: does not apply — only goatcounter and plausible take it
```

## Google Analytics, and a gate that gates

GA4 sets cookies, so consent is required. Cherry's answer is not to render GA and put a bar over it — by then the cookies are already set, and the banner is decoration.

Instead, **the GA tag is never in the document**. What ships is a small gate holding your measurement id as data:

```elixir
analytics: [google: "G-4TQ8ZK1PXR"]
```

```html
<script data-cherry-consent-id="G-4TQ8ZK1PXR">…the gate, ~3 kB, no GA…</script>
```

A visitor who has made no choice sees a bar with two buttons. Only on **Accept** does the gate build the googletagmanager URL and append the script. A visitor who rejects, or who simply leaves, has had nothing stored — because there was nothing there to store it.

Accept and reject are the same button at the same size, on purpose: European regulators are explicit that refusing must be exactly as easy as agreeing, so an accept-only bar is not compliant.

The choice lives in `localStorage`. That needs no consent of its own — recording a consent decision is the one thing the rules exempt as strictly necessary.

### Withdrawing consent

Withdrawal has to be as easy as giving it. Anything on your page marked `data-cherry-consent-reopen` brings the bar back:

```html
<footer>
  <a href="#" data-cherry-consent-reopen>Cookie settings</a>
</footer>
```

Or from the console, and from your own scripts:

```js
window.cherryConsent.choice()  // "granted" | "denied" | null
window.cherryConsent.reset()   // forget the choice, ask again
```

The bar is built by the gate at runtime, so it is not in your HTML and no theme needs a line of markup for it.

## Styling it

The bar uses your theme's own tokens — `--color-surface`, `--color-fg`, `--color-border`, `--color-accent` — so it looks native in every theme, light and dark, without configuration.

Its CSS sits in a cascade layer below the theme, so a theme can restyle it by naming it, and `assets/custom.css` beats both:

```css
/* assets/custom.css */
.cherry-consent { font-size: 0.8rem; }
.cherry-consent button { border-radius: 0; }
```

## Reading it back

`analytics:` is structured config, so — like `nav:` — `cherry config` reads it but won't rewrite it. Edit `cherry.exs` for changes:

```text
$ cherry config analytics --json
{"key":"analytics","value":{"provider":"cloudflare","id":"b4c1f0e2","host":null,"consent_required":false}}
```

`consent_required` is the field worth watching: it tells you whether a gate ships with your beacon.

## What Cherry deliberately doesn't do

One provider, not a list. Two analytics scripts on one page is a mistake every time, so the config says so instead of merging them:

```text
expected one provider, got 2 — pick one
```

And Cherry is not a consent management platform. There is no vendor list, no granular purposes, no TCF string, and no Google Consent Mode signalling — Cherry hard-gates GA instead, which is stricter but coarser. A site that needs a real CMP should bring one and leave `analytics:` unset.
