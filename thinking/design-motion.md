# πόσο κάνει — Motion, Skeletons & Cross-Platform Spec

> Companion to `flow.md` + `api-schema.md`. Defines the *feel*: animations, skeleton
> placeholders, Hero transitions, and how one product ships to **Web + Android + iOS**.
> Written so design can mock states and motion directly.

---

## 1. Platform strategy — one codebase, three targets

**Recommendation: Flutter.** (User already runs Flutter apps → Iq-Rider, pavel_rider, DriverAppFlutter.)
- Single Dart codebase → **Android, iOS, and Web** from one source.
- Built-in `Hero` widget = the hero-tag transitions requested.
- First-class animation stack (`AnimatedSwitcher`, `Hero`, implicit + explicit animations, Rive/Lottie).
- Shimmer skeletons via `shimmer` pkg or custom `ShaderMask`.

```
            ┌──────────────────────────┐
            │   Shared Flutter codebase │
            │  (widgets, state, API)    │
            └─────────┬─────────────────┘
        ┌─────────────┼──────────────┐
     Android         iOS            Web (PWA)
   material feel   cupertino feel   responsive, SEO-aware shell
```

### Platform-adaptive rules
| concern | Android | iOS | Web |
|---|---|---|---|
| nav | bottom nav bar | bottom tab bar (cupertino) | top nav + sidebar on wide |
| back gesture | system back | edge-swipe | browser back + breadcrumbs |
| scroll physics | clamping | bouncing | clamping + visible scrollbar |
| typography | Roboto/Greek-safe | SF/Greek-safe | web font, preloaded |
| install | Play Store | App Store | PWA install + add-to-home |

### Web-specific (the "good site" part)
- **Responsive breakpoints**: phone <600 · tablet 600–1024 · desktop >1024.
  - Phone: single column, bottom nav.
  - Desktop: persistent left category rail + multi-column product grid + sticky basket panel.
- **SEO/shareable**: clean deep-link routes (`/product/<id>`, `/category/<id>`), meta tags, product preview cards for sharing.
- **Perf**: deferred/lazy routes, image lazy-load by `image_version`, CanvasKit vs HTML renderer decision (CanvasKit = crisper, heavier; HTML = lighter, better text/SEO — likely HTML for a content site).
- **No hover on touch** → hover affordances (price tooltips) are desktop-only enhancements, never required.

---

## 2. Hero transitions (hero tags)

`Hero(tag: ...)` shared-element transitions. **Tags must be globally unique per in-flight transition.**

| from → to | hero element | tag scheme |
|---|---|---|
| product card → product detail | product image | `hero-product-img-<productId>` |
| product card → product detail | price chip | `hero-product-price-<productId>` |
| category card → category grid | category image | `hero-cat-img-<categoryId>` |
| basket item → optimizer result | item thumb | `hero-basket-<productId>` |
| deal card → product detail | deal badge | `hero-deal-badge-<productId>` |

Rules:
- Tag includes the entity id so a grid of cards never collides.
- If the same product appears twice on screen (e.g. "alternatives" row), suffix context: `hero-product-img-<id>-alt` to avoid duplicate-tag crash.
- Hero flight uses a custom `flightShuttleBuilder` for the image so the rounded corners morph smoothly card→hero.
- Keep hero element identical both sides (same aspect ratio) or it warps.

---

## 3. Skeleton placeholders (per screen)

Shimmer skeletons on **every** async surface — never a spinner on first paint. Skeleton shape **mirrors final layout** (same boxes, same sizes) so there's no reflow jump.

| screen | skeleton |
|---|---|
| Home | category-card grid: rounded squares + 2 text bars; deals row: horizontal shimmer cards |
| Search results / category grid | repeated product-card skeletons: image box + name bar + price bar + store-count bar (render ~8–12) |
| Product detail | big image box → title bars → retailer table = N shimmer rows → spread-bar shimmer → sparkline placeholder (flat shimmer line) |
| Stores directory | logo-tile shimmer grid |
| Home | + stats-counter shimmer pills, store-logo strip shimmer |
| Basket optimizer | 3 strategy-card skeletons while computing |
| Deals | deal-card skeletons sorted layout |

Behavior:
- Shimmer = subtle left→right gradient sweep, ~1.2s loop, low contrast.
- **Stagger reveal**: when data lands, skeleton → real content via short `AnimatedSwitcher` fade (150–200ms), items stagger 30–50ms down the list.
- Images: skeleton box persists *under* the image until `image` frame loads (don't pop). `image_url: null` → placeholder glyph, never shimmer forever.
- Min skeleton display ~300ms even on cache hit → avoids flash/flicker.

---

## 4. Animation catalog (micro-interactions)

| moment | animation | timing/curve |
|---|---|---|
| page push | hero flight + cross-fade of surroundings | 300ms, `easeInOutCubic` |
| list/grid first paint | staggered fade+slide-up | 250ms, 40ms stagger |
| price reveal | **count-up** number tween (0 → €X.XX) | 400ms, `easeOut` |
| savings on optimizer | total + "save €X" counts up, savings chip pops + subtle confetti pulse | 500ms |
| add to basket | item flies (small thumb) into basket FAB, FAB badge bumps | 350ms, `easeInBack` |
| price-spread bar | min/avg/max segments grow from left on load | 400ms |
| price-history sparkline | line draws left→right (path trim), low-point dot pops | 600ms, `easeInOut` |
| stats counters (home) | count-up from 0 on view | 800ms, `easeOut` |
| discount badge | gentle pulse/scale loop to draw eye (respect reduce-motion) | 1.5s loop |
| favorite ♡ | scale-bounce + fill color | 250ms, `elasticOut` |
| pull-to-refresh | custom branded indicator (price-tag swing) | — |
| tab switch | cross-fade content, nav icon micro-bounce | 200ms |
| filter sheet | bottom-sheet slide + scrim fade | 250ms |
| error/empty | illustration fade-in, not abrupt | 200ms |

Global motion rules:
- Respect OS **reduce-motion** → drop pulses/count-ups to instant, keep functional fades.
- One "delight" per screen max — don't animate everything at once.
- 60fps budget: animate transform/opacity, avoid layout-thrash; offload images.
- Lottie/Rive only for empty-states + onboarding (keep web bundle lean).

---

## 5. Component states (design must mock ALL four)

Every data widget: **loading (skeleton) · loaded · empty · error**.
- **Empty** examples: search no-match, category has 0 in-stock, basket empty, no deals today → friendly illustration + CTA.
- **Error**: API/network fail → retry button, keep last cached data visible if any ("showing cached, tap to refresh").
- **Stale**: price `last_updated` old → amber "as of <date>" chip (from `flow.md` edge cases).
- **Partial**: optimizer with gaps → show what it could compute + flag missing.

---

## 6. Design tokens (starting point — design refines)

- **Identity**: `*.gov.gr` → clean, trustworthy, official-but-friendly. Not loud.
- Color: one strong accent for "cheapest/save" (green-ish = good price), one for deals (warm/red), neutral surfaces. Per-retailer brand colors only on store chips/logos.
- Radius: consistent rounded cards (12–16) so hero corner-morph reads well.
- Type scale: price = largest/boldest on card (it's the product), €/unit = secondary.
- Dark mode: full support (one design system, two themes).
- Greek + English typography → font must cover full Greek glyph set at all weights.

---

## 7. Performance & motion gotchas across platforms

- **Web**: hero transitions can jank if images aren't preloaded → preload detail image on card tap-start. CanvasKit warmup delay → show app-shell skeleton during first load.
- **iOS**: bouncing scroll + sticky headers → test hero into a scrolled-up detail.
- **Android**: lower-end devices → cap simultaneous shimmer count, disable confetti.
- **All**: 429-page categories → infinite scroll with skeleton footer, never load all.
- Cache tree (2695 nodes) + images by version so repeat navigation animates instantly with no refetch flicker.

---

## 8. What design should deliver next

1. Product card (the atom) — all 4 states + dark mode.
2. Product detail — hero target layout + retailer table + spread bar.
3. Optimizer result — 3 strategy cards + savings reveal.
4. Skeleton sheets matching 1–3.
5. Motion specs (curves/durations) confirmed or adjusted from §4.
6. Responsive web layouts (phone / desktop with side rail + sticky basket).
