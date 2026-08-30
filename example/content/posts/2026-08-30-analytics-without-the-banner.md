---
title: "Analytics without the banner"
description: Cherry's analytics key classifies providers by what they store on your visitor's device, not by what the vendor is called - so cookieless beacons ship no consent banner at all, and the one provider that needs a gate gets a gate that actually gates.
tags: [design, privacy, analytics]
---

Most cookie banners are lying to you. Not deliberately — they are just in the wrong place. The script has already loaded, the cookies are already set, and the bar that slides up from the bottom is asking permission for something that happened three hundred milliseconds ago.

Cherry now has an `analytics:` key. It took one decision to design, and that decision was not "which providers".

## Classify by storage, not by vendor

The EU's ePrivacy rules turn on a specific thing: **storing or accessing information on the visitor's terminal equipment**. Not analytics. Not tracking. Storage.

That distinction does real work, because the providers split cleanly along it:

| provider | stores | banner |
|---|---|---|
| `cloudflare` | nothing | none |
| `plausible` | nothing | none |
| `goatcounter` | nothing | none |
| `google` | `_ga` cookies | consent gate |

Cloudflare Web Analytics, Plausible and GoatCounter set no cookies, touch no storage, and don't fingerprint. Nothing is triggered, so Cherry shows **no banner at all** — not a collapsed one, not a remembered one. Zero bytes of consent code reach the page.

That is not a shortcut. Putting a cookie banner over a cookieless beacon asks for permission that isn't required, and every one of those trains people to dismiss the banners that matter. The most privacy-respecting thing a static site generator can do here is not ask.

So the registry records a consent class per provider, and there is nowhere to add a provider without one:

```elixir
@providers [
  cloudflare:  %{consent: :not_required, self_hostable: false, id: :always},
  goatcounter: %{consent: :not_required, self_hostable: true,  id: :unless_host},
  google:      %{consent: :required,     self_hostable: false, id: :always},
  plausible:   %{consent: :not_required, self_hostable: true,  id: :always}
]
```

## The gate that actually gates

GA4 sets cookies, so it needs consent. The usual implementation renders the vendor script on load and puts a bar on top of it — which collects the cookies it is asking about, before the question is answered.

Cherry doesn't emit the GA tag at all. What ships is a ~3 kB gate holding your measurement id as inert data:

```html
<script data-cherry-consent-id="G-4TQ8ZK1PXR">…no GA…</script>
```

Only on **Accept** does it construct the googletagmanager URL and append the script. Reject, or just leave, and nothing was ever there to store anything. Accept and reject are the same button at the same size, because regulators are explicit that refusing must be as easy as agreeing.

The choice goes in `localStorage` — which needs no consent of its own, since recording a consent decision is precisely the strictly-necessary exemption.

## One key, every theme

The beacon rides the framework-owned head, beside the SEO block and the font preloads. That is the same seam that makes those two impossible for a theme to forget, and it means analytics reaches all thirty official themes and the 404 page without a single template changing:

```elixir
analytics: [cloudflare: "b4c1f0e2a7d94c11"]
```

Plausible and GoatCounter can be self-hosted, so both take an origin override. The two providers with no self-hosted edition refuse the key rather than ignoring it:

```elixir
analytics: [plausible: [id: "example.com", host: "https://stats.example.com"]]
```

```text
cloudflare has no self-hosted edition, so host: does not apply — only goatcounter and plausible take it
```

Cherry is not becoming a consent management platform: no vendor lists, no granular purposes, no TCF strings. It will carry GA if you ask for it, but only behind a gate that gates. Everything else is one line and no banner.

The [analytics guide](/guides/analytics/) has the worked setup for all four.
