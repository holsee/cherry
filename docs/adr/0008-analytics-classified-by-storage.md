# ADR 0008: Analytics is classified by what it stores, not by vendor

**Status:** Accepted — 2026-08-30

## Context
Sites want visitor numbers, and Cherry had no answer, so every site was rolling its
own `<script>` into an ejected layout — the one rung of the ladder that forfeits
theme upgrades, for a feature that has nothing to do with theming.

The obvious shape ("add an analytics key, show a cookie banner") gets the law
backwards. The ePrivacy Directive's Article 5(3) turns on *storing or accessing
information on the visitor's terminal equipment* — not on whether the vendor is
called analytics. Cloudflare Web Analytics, Plausible and GoatCounter store nothing
and do not fingerprint, so they need no consent; GA4 sets `_ga` cookies, so it does.
A banner shown for the first group is consent theatre: it asks for permission that is
not required, and it teaches people to click through the banners that are.

The second half is worse in practice. A banner only means anything if the tag has not
already fired. Most implementations render the vendor script on page load and put a
bar over it, which collects the cookies it is asking permission for before the
question is answered.

## Decision
`analytics:` takes exactly one provider, and every provider carries a consent class.

- **Cookieless** (`cloudflare`, `plausible`, `goatcounter`) — the beacon renders
  directly into the framework-owned head. No banner ships. No consent code ships.
- **Consent-required** (`google`) — the vendor tag is never emitted. What ships is a
  gate that holds the measurement id as data and injects GA only after an explicit
  accept, so a page view taken before the choice stores nothing.

The gate ships as one inline island rather than a theme asset, because it must reach
all 30 themes and the 404 without any of them cooperating — the same reason the SEO
head and the font preloads are framework-owned. Accept and reject are the same button
at the same size (EDPB/CNIL: refusing must be as easy as agreeing), the choice lives
in `localStorage` under the strictly-necessary exemption, and withdrawal is a
documented one-liner.

One provider, not a list: two analytics scripts on a page is a mistake every time, so
config validation says so rather than merging them.

The registry records self-hostability beside the consent class, so `host:` is accepted
for Plausible and GoatCounter and refused for Cloudflare and GA — a vendor with no
self-hosted edition should say so, not ignore the key. The value is an origin rather
than a script URL, because the two providers differ in what they build from it:
Plausible needs one script path, while hosted GoatCounter splits its count endpoint
from a shared CDN script and a self-hosted instance serves both.

## Consequences
Adding a provider is a row in the registry plus a `tag/1` clause, and its consent
class decides whether the gate ships with it — the classification cannot be forgotten
because there is nowhere to put a provider without one.

Cherry takes a position: it will carry GA if a site asks for it, but only behind a
gate that actually gates. Cherry does not become a consent management platform —
there is no vendor list, no granular purposes, no TCF string. Sites needing that
bring their own CMP and leave `analytics:` unset.

Consent copy is English-only for now; a site needing another language ejects nothing
and instead sets `analytics:` unset and hand-rolls, until a `consent_text:` key earns
its place.
