# πόσο κάνει — App Flow & Feature Spec

> Hand-off doc for design. Describes WHAT the app does, the user journeys, and every
> feasible feature derived from the live API. Pairs with `api-schema.md` (the data contract).
> Goal: unique, smart, professional grocery **price-intelligence** app for the Greek market.

---

## 0. One-liner

> **"Don't ask what it costs. Ask where it's cheapest."**
> A price-comparison + smart-basket app over `api.posokanei.gov.gr`: scan 8,500+ grocery
> products across every major Greek supermarket, compare by real **price-per-kg/L**, build a
> basket and let the app pick the cheapest store(s) — with discount alerts and EU VAT awareness.

---

## 1. Why it's unique (vs a plain catalog browser)

The API hands us three things most price apps fake or lack — we build the product *around* them:

1. **`price_normalized` (€/unit) per retailer** → we rank by true cost, not sticker price.
   Most apps show "€2.49 vs €3.16". We show "€6.23/kg vs €7.90/kg — and the 1kg pack is cheaper per gram than the 400g."
2. **Multi-retailer prices on one product** → a real **basket optimizer**: cheapest single store, or split-basket "buy these 4 at Lidl, these 3 at Σκλαβενίτης, save €8.40".
3. **`effective_vat_rates` per EU country** → an **export/cross-border price view** nobody else surfaces, for `is_international` products.

That trio = the moat. Everything below hangs off it.

---

## 2. Data → feature map (what each field unlocks)

| API field | Feature it powers |
|---|---|
| `price_stats.min/max/avg` | "Save up to X%" badge, price spread bar |
| `price_stats.min_unit_price` | **Unit-price ranking** (the headline comparison) |
| `retailer_prices[]` | Per-store comparison table, store logos, basket split |
| `is_discount` / `discount_percentage` | **Deals tab**, discount alerts, "on offer now" filter |
| `last_updated` | Freshness badge, "stale price" greying, trust signal |
| `unit` / `unit_quantity` | €/kg normalization, pack-size compare |
| `private_label` | "Own-brand alternative is X% cheaper" suggestion |
| `effective_vat_rates` | Cross-border price view, VAT breakdown |
| category `total_product_count` | Browse weighting, "popular categories" |
| `category_ids` (multi) | "Also found in…", cross-category dedupe |
| `brand` | Brand filter (client-side), "cheaper brand alternatives" |
| `image_version` | Aggressive image caching |
| `/history` `daily_prices` | **Price sparkline, "lowest in N days", "price dropped" detection, basket-inflation trend** |
| `/meta/retailers` | Store directory, logos, "open store site", per-country grouping, store filter chips |
| `/meta/stats` | Home dashboard counters (8,783 products · 22 stores · 2,702 deals) |

What the API GIVES that most apps lack (all probed ✓):
- **Native daily price history** — `GET /products/<id>/history` → per-retailer daily points. Sparklines + "lowest in N days" + drop detection FREE. No snapshotting needed.
- **Fuzzy search** — `GET /products?q=<term>` (accent-loose; `γάτα` also hit `γάλα` → expect noisy matches, rank client-side).
- **Single product** — `GET /products/<id>` (richer than list).
- **Retailer directory** — `GET /meta/retailers` → 20 stores w/ logos + websites + country.
- **Global stats** — `GET /meta/stats` → product/store/discount counters for home.
- **Server filters that WORK**: `category=<id>` (⚠️ NOT `category_id`), `retailer=<slug>`, `has_discount=true`, `private_label=true`, `q=`.

What the API does **NOT** give → handle ourselves:
- **No server sort, no brand/country/price-range filter, no multi-filter AND** (`category`+`has_discount` breaks). → fetch by one filter (or `category`+`q`), then **sort & refine client-side** on the page.
- **User data** (favorites, basket, alerts, target prices) — none. → our own light backend / local store.
- **Alert polling** — push when price crosses threshold → server-side cron re-poll (history endpoint makes the diff trivial).

---

## 3. Information architecture

```
Home  ─┬─ Search (global, q= fuzzy)
       ├─ Browse (category tree, 24 roots → depth 3)
       ├─ Deals (has_discount + real-drop detection)
       ├─ Stores (retailer directory → per-store browse)
       ├─ Basket / List  ── Optimizer result
       └─ Profile (favorites, alerts, default stores, language)

Product detail  ← reachable from any list (+ price-history sparkline)
Category detail (product grid + client-side filters/sort)
Store view (one retailer's prices, retailer=<slug>)
Compare view (2–3 products side by side)
```

---

## 4. Core user journeys (flows)

### Flow A — "How much does X cost?" (the core loop)
```
Search "activia"  ──►  results ranked by €/unit
        │
        ▼
Product detail
  ├─ headline: cheapest price + cheapest €/unit (may be different stores → show both)
  ├─ retailer table: store(logo) | price | €/unit | discount | "as of <date>"
  ├─ price-spread bar (min ──avg── max)
  ├─ price-history sparkline (/history) + "lowest in 30d" + real-deal check
  ├─ [Add to basket]  [Set price alert]  [♡ favorite]
  └─ "Cheaper alternatives": same subcategory, lower €/unit (incl. private_label)
```

### Flow B — Smart basket optimizer (the killer feature)
```
Build list (search/scan/browse) → N products
        │
        ▼
Optimize ──► three answers:
  1. CHEAPEST SINGLE STORE   — total if you buy everything at one chain (per store, sorted)
  2. CHEAPEST SPLIT          — per-item cheapest, grouped by store ("3 stops, save €X")
  3. BALANCED                — split capped at 2 stores (configurable), best total under that limit
        │
        ▼
Result card: total, savings vs avg, per-store sub-lists, items with stale/missing prices flagged
```
Rules:
- Only compare retailers the product actually has (`retailer_prices`).
- Item with one retailer → forced into that store's bucket.
- Stale price (`last_updated` > N days) → warn, optionally exclude.
- Show "you can't get item Z at any of your selected stores" gaps.

### Flow C — Browse the tree
```
24 roots (cards w/ image_url + total_product_count)
   └─ depth 1 → depth 2 → depth 3
        └─ leaf → product grid
Filters on grid: brand · price range · €/unit · on-offer · retailer · private_label
Sort: €/unit ↑ (default) · price ↑ · discount % ↓ · name
```
- Branches with `product_count: 0` but `total_product_count > 0` → navigational only, drill in.
- Lazy-load children; cache whole tree once (it's static-ish).

### Flow D — Deals
```
Deals tab = all products where any retailer_prices[].is_discount = true
  sort by discount_percentage ↓
  filter by category / store / min %
  "biggest drops" hero row
```

### Flow E — Price alerts (needs our backend)
```
On product: "Alert me when ≤ €X" or "when any store discounts"
We re-poll periodically, snapshot prices, notify on threshold cross.
Doubles as our price-history source.
```

### Flow F — Cross-border / VAT view (niche, unique)
```
Product flagged is_international → "Buy abroad?" panel
  show effective_vat_rates per country, net price, VAT-adjusted compare
Category VAT badge from effective_vat_rates (reduced-rate items highlighted)
```

---

## 5. Full feature list (grouped, "everything possible")

**Compare & price intelligence**
- Unit-price (€/kg, €/L) ranking as the default sort everywhere.
- Per-store comparison table with discount + freshness.
- Price-spread visual (min/avg/max).
- "Best value pack" — across pack sizes of same product line, lowest €/unit.
- Private-label cheaper-alternative suggestions.
- Cheapest-store-for-this-item badge.

**Basket / list**
- Multi-store basket optimizer (single / split / capped-split).
- Reusable lists (weekly shop), quantities, check-off mode.
- "Basket inflation" — track your basket's total over time (our snapshots).
- Share basket (read-only link).

**Discovery**
- Global search (ranked by relevance + €/unit).
- Category tree browse, lazy + cached.
- Deals tab, biggest-drops.
- Filters: brand, price, €/unit, on-offer, retailer, private-label, country.
- Favorites / watchlist.

**Price history** (NATIVE via `/products/<id>/history`)
- Price sparkline per retailer on product detail.
- "Lowest in N days" / "today vs 30-day low" badge.
- Auto "price dropped"/"is this a real deal?" — compare current vs history (a fake discount = was never lower).
- Basket-inflation chart — sum your list's history over time.

**Alerts** (our backend — polling + push)
- Target-price + any-discount alerts → push.
- "Price dropped since you favorited" feed (diff via history endpoint).

**Stores**
- Retailer directory (`/meta/retailers`): logos, country, link to store site.
- Per-store browse (`retailer=<slug>`), "what's cheapest at my store".
- Filter basket/results by my preferred chains.

**Cross-border / VAT**
- EU VAT breakdown per category/product.
- International product price-abroad comparison.

**Polish / pro**
- Greek + English (use `name`/`name_en`, fall back when `name_en` == `name`).
- Offline cache of tree + last-seen products.
- Store logos/colors keyed by retailer slug.
- Empty/placeholder images where `image_url` null.
- Freshness/trust badges everywhere prices appear.
- Accessibility: large-text mode (grocery audience skews older).

**Smart / "wow" layer**
- Barcode/photo scan → match to product (needs search/match endpoint; client match as fallback).
- "Cook this" → recipe ingredient list → auto-basket → optimized cost.
- Budget mode: cap €, app builds cheapest valid basket meeting the list.
- Weekly "your usual basket is €X this week (▲/▼ vs last)" digest.

---

## 6. Screen inventory (for design)

| Screen | Key elements |
|---|---|
| **Home** | search bar, stats counters (`/meta/stats`), root-category cards, "today's biggest drops" row, store strip (`/meta/retailers` logos), basket FAB |
| **Search results** | ranked list, sort/filter sheet, €/unit prominent |
| **Category grid** | product cards (image, name, brand, €/unit, store count, deal badge), filter/sort bar |
| **Product detail** | hero, dual headline (cheapest € + cheapest €/unit), retailer table, spread bar, alternatives, actions |
| **Basket / list** | line items w/ qty, running total, "Optimize" CTA |
| **Optimizer result** | 3 strategy cards, per-store breakdown, savings, gaps/stale flags |
| **Deals** | sorted deal cards, store/category filters, "real drop" badge from history |
| **Stores directory** | `/meta/retailers` grid: logo, name, country, link to site, "browse this store" |
| **Store view** | one retailer's products + prices (`retailer=<slug>`) |
| **Price history** | sparkline per retailer (`/history`), 30-day low marker, current-vs-low |
| **Compare** | 2–3 products side-by-side matrix |
| **Profile** | favorites, alerts, default stores, language, country |

### Product card — the atomic unit (design carefully)
```
┌───────────────────────────────┐
│  [img]   ACTIVIA Επιδόρπιο …   │
│          ACTIVIA · 400g        │
│          from €2.49  ·  €6.23/kg│  ← € and €/unit both
│          3 stores · ▼ -21% deal │
└───────────────────────────────┘
```

---

## 7. Technical architecture (proposed)

```
Client (mobile-first PWA or Flutter — user already does Flutter)
   │  reads
   ▼
Our thin backend  ──►  api.posokanei.gov.gr   (proxy + cache + CORS + rate-limit shield)
   │
   ├─ Cache layer (tree/retailers/stats: long TTL; product pages: short TTL)
   ├─ User store (favorites, baskets, alert thresholds)   ← only data the API lacks
   └─ Alert worker (cron re-poll /history → diff → push)
   (price history itself = native /products/<id>/history, no snapshotting)
```
Why a (thin) backend — now OPTIONAL for MVP since history + search are native:
- Power **alerts** (server-side cron polling + push) — the one thing the client can't do alone.
- Store **user data**: favorites, baskets, alert thresholds.
- Shield the public gov API, add caching, fix CORS for web.
- NOT needed for: price history (native `/history`), search (native `q=`), single product (native).
- → MVP can ship client-direct; add backend when you add accounts/alerts.

**State / caching client-side**
- Category tree: fetch once, persist, version-check occasionally.
- Product lists: paginated, cache per category page.
- Images: cache by `image_version` / `?v=`.

**Performance notes**
- Tree is 2695 nodes in one payload → fetch once, render lazily.
- Products paginate (`page` / `page_size`, ~429 pages for big categories) → infinite scroll.
- `query_time_ms` in payload → can surface as debug/health.

---

## 8. Edge cases the design must handle (pulled from real data)

- `image_url: null` → placeholder.
- `name_en == name` (untranslated) → fall back to Greek, don't show duplicate.
- `name` leading space → trim.
- Stale `last_updated` (weeks old) → "as of" label + grey, exclude from optimizer optionally.
- `retailers` / `retailer_prices` / `retailer_count` mismatch → trust `retailer_prices`.
- VAT `rate` int-vs-float (`24` vs `24.0`) → format consistently.
- Variable country sets in `effective_vat_rates` → iterate, never hardcode.
- Product in multiple `category_ids` → dedupe when aggregating.
- `product_count: 0` navigational branches → drill, don't show "empty".
- Mixed `category_id` formats → opaque strings only.

---

## 9. Build phases (suggested MVP → full)

1. **MVP**: tree browse → product grid → product detail with retailer table + €/unit ranking. Read-only, client cache, no backend.
2. **Basket**: local basket + single-store + split optimizer.
3. **Backend**: proxy + snapshots → price history sparklines.
4. **Accounts**: favorites, alerts, push.
5. **Smart layer**: search index, deals tab, cross-border VAT, recipe/budget modes.

---

## 10. Open questions — RESOLVED + remaining

Resolved by probing (2026-06-17):
- ✓ Search exists: `/products?q=` (fuzzy). Single product: `/products/<id>`. Price history: `/products/<id>/history` (native daily series). Retailers + stats endpoints exist.
- ✓ Product category filter param is `category=` not `category_id`. Sort/brand/country/price filters are client-side.

Remaining for design decisions:
- Platform: **Flutter** (one codebase → web+android+ios; user already runs Flutter). Confirm.
- Brand identity: `*.gov.gr` → clean/trustworthy, but it's a consumer savings app → "official-friendly". Pick exact lane.
- Localization: Greek-first, English secondary (`name`/`name_en`, fall back when equal).
- Search UX: q is fuzzy/noisy → need client-side relevance ranking + "did you mean" handling.
- Deals strategy: use `has_discount=true` OR detect real drops via `/history` (a discount that was never lower = not a real deal — worth surfacing).
