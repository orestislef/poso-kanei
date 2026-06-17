# API Schema Reference — `api.posokanei.gov.gr`

> Source of truth for every field the app reads. Probed live 2026-06-17.
> The API is a **Greek grocery price-comparison service** ("πόσο κάνει" = "how much does it cost").
> No auth observed. JSON over HTTPS. No `/docs` or `/openapi.json` (both 404).

---

## Base URL

```
https://api.posokanei.gov.gr
```

Health check: `GET /` → `{"status":"ok"}`

---

## 1. Category tree

```
GET /meta/categories/tree?include_counts=true&include_hidden=false
```

### Query params
| param | type | meaning |
|---|---|---|
| `include_counts` | bool | include `product_count` / `total_product_count` |
| `include_hidden` | bool | include categories flagged `hidden: true` |

### Top-level response
```jsonc
{
  "total_categories": 2695,   // all nodes, all depths
  "root_count": 24,           // depth-0 categories
  "tree": [ Category, ... ]   // forest of roots
}
```

### `Category` node (recursive)
```jsonc
{
  "category_id": "string",          // ⚠️ MIXED id formats: uuid, 32-hex, AND 32-char base62 — treat as opaque string, never parse
  "name": "string",                 // Greek
  "name_en": "string",              // English — ⚠️ sometimes equals Greek (untranslated), e.g. "Σκύλος"
  "depth": 0,                       // 0 = root; observed up to 3
  "hidden": false,
  "image_url": "string | null",     // null ⇒ no image → needs placeholder
  "vat_rates": { "GR": 24, ... } | null,   // ⚠️ OWN overrides only; null = inherits from ancestor
  "effective_vat_rates": {                  // ALWAYS present, fully resolved per country
    "GR": { "rate": 24.0, "source": "Standard rate", "source_id": null, "inherited": true },
    "DE": { "rate": 7.0,  "source": "Snacks", "source_id": "<cat_id>", "inherited": false },
    ...
  },
  "children": [ Category, ... ],    // [] for leaf
  "total_product_count": 235,       // self + all descendants
  "product_count": 0                // products directly in THIS node (roots often 0)
}
```

### Field gotchas
- **`rate` mixes int and float** (`24` vs `24.0`, `20` vs `20.0`) → parse as number, format yourself.
- **VAT country set is not fixed**: roots show ~9 countries (BE BG CY DE FR GR IT PT RO); `vat_rates` overrides may add ES. Iterate keys, never hardcode.
- `inherited: true` + `source: "Standard rate"` = country default, no category-specific rule.
- `product_count: 0` on a branch with `total_product_count > 0` is normal → roots/branches are navigational, leaves hold products.
- Tree is big (2695 nodes). One fetch, cache hard.

---

## 2. Products in a category

```
GET /products?category_id=<id>&page=<n>&page_size=<n>
```

### Query params — TESTED status (⚠️ read carefully, many are ignored)
| param | status | notes |
|---|---|---|
| `category` | ✓ WORKS | **THIS is the category filter, NOT `category_id`.** `?category=<id>` → 90 cat-food. |
| `category_id` / `category_ids` | ✗ IGNORED | silently returns full global catalog (~8571). Do NOT use. |
| `q` | ✓ WORKS | free-text search, `?q=activia` → 10. **Fuzzy/accent-loose**: `q=γάτα` (cat) also matched `γάλα` (milk). No `/search` route — this is search. |
| `retailer` | ✓ WORKS | `?retailer=lidl` → 1513. slug from `/meta/retailers`. |
| `has_discount` | ✓ WORKS | `?has_discount=true` → 2105 (only-on-offer). NOT `discount=`/`on_discount=` (those ignored). |
| `private_label` | ✓ WORKS | `?private_label=true` → 2012. |
| `page` | ✓ | 1-based |
| `page_size` | ✓ | default 20 (`limit` also accepted) |
| `brand` | ✗ IGNORED | returned global. Filter client-side on `brand`. |
| `country` | ✗ IGNORED | returned full set. Filter client-side on `available_countries`. |
| `min_price`/`max_price` | ✗ IGNORED | returned global. Filter client-side. |
| `sort` / `sort_by` / `order` | ✗ IGNORED | results NOT ordered. **No server sort — sort client-side.** |

### Filter composition (tested — DON'T assume AND)
- `category` + `q` → **AND ✓** (`category=catfood&q=friskies` → 8). Good: search within a category.
- `category` + `has_discount` → **BROKEN** — returns global discount set (2105), ignores category. Don't combine; fetch category then filter `is_discount` client-side.
- `category` + `country` → country ignored, category honored (90).
- Safe pattern: pick ONE server filter (`category` OR `q` OR `retailer` OR `has_discount` OR `private_label`), optionally `category`+`q`, then refine the page client-side.

### Pagination wrapper
```jsonc
{
  "total": 8571,
  "page": 1,
  "page_size": 20,
  "total_pages": 429,
  "has_next": true,
  "has_prev": false,
  "query_time_ms": 52.25,
  "products": [ Product, ... ]   // array key
}
```

### `Product`
```jsonc
{
  "id": "string",
  "name": "string",                 // ⚠️ may have leading space — trim
  "brand": "string",
  "images": [],                     // usually empty; use image_url instead
  "category": "string",             // leaf display name
  "category_ids": ["string", ...],  // ⚠️ product belongs to MULTIPLE categories
  "subcategory": "string",
  "description": "string",          // Greek marketing copy; may have typos
  "image_url": "string",            // versioned ?v=
  "has_image": true,
  "updated_at": "2026-06-16T23:19:17.446000",  // ISO, microseconds, NO tz
  "image_version": "string",
  "unit": "kg",                     // normalization unit: kg | L | piece...
  "unit_quantity": 0.4,             // pack size in `unit`
  "private_label": false,
  "price_stats": {
    "min_price": 2.49,
    "max_price": 3.16,
    "avg_price": 2.92,
    "retailer_count": 3,            // ⚠️ can disagree with retailer_prices.length
    "min_unit_price": 6.23,         // cheapest price-per-unit (€/kg) → the real comparison number
    "last_computed": null
  },
  "retailers": ["sklavenitis", "galaxias"],   // ⚠️ slug list; may differ from retailer_prices set
  "retailer_prices": [
    {
      "retailer": "sklavenitis",            // slug
      "retailer_display_name": "Σκλαβενίτης",// show this
      "retailer_name": "",                  // often empty
      "price": 2.49,
      "price_normalized": 6.23,             // €/unit at this retailer
      "is_discount": false,
      "discount_percentage": null,          // number when is_discount
      "last_updated": "2026-06-16T00:00:00",// ⚠️ STALE prices common (weeks old)
      "country": "GR"
    }
  ],
  "available_countries": ["GR"],
  "is_international": false
}
```

### Field gotchas
- **Stale prices**: `last_updated` per retailer can be weeks old → show "as of <date>", grey out old ones.
- **`retailers` vs `retailer_prices` vs `retailer_count` can disagree** → trust `retailer_prices` for display, derive counts from it.
- **Cheapest-by-unit ≠ cheapest-by-price** → bigger pack often wins on `price_normalized`. Surface both.
- `unit` varies (kg / L / piece) → format €/unit per product.
- Product lives in many categories (`category_ids`) → dedupe if aggregating across categories.
- `name` leading whitespace → always trim.

---

## 2b. Single product by id ✓

```
GET /products/<id>
```
- Returns ONE `Product` object (not wrapped, not paginated).
- Same fields as list `Product`, PLUS:
  - **`history`** key (was `null` in test) → server-side price history hook exists but empty/unpopulated. Watch this — may fill later.
  - `retailer_prices[].retailer_name` is **populated here** (per-retailer product title) vs empty `""` in list view.
- Use for product detail screen (richer than list payload).

---

## 2c. Price history time-series ✓ (BIG — no need to build our own)

```
GET /products/<id>/history
```
```jsonc
{
  "keyvoto_id": "keyvoto_product-<id>",
  "product_name": "string",
  "unit": "kg",
  "unit_quantity": 0.4,
  "price_type": "price",
  "retailers": ["sklavenitis", "masoutis"],   // retailers WITH history (subset)
  "daily_prices": {
    "sklavenitis": [
      { "date": "2026-05-18", "price": 3.1, "country": "GR" },
      { "date": "2026-05-22", "price": 2.49, "country": "GR" },  // gaps where unchanged/unscraped
      ...
    ],
    "masoutis": [ ... ]
  },
  "date_range": { "start": "2026-05-18", "end": "2026-06-17" },
  "available_countries": ["GR"],
  "has_price_history_timeseries": true   // false ⇒ no series → hide sparkline
}
```
- **Daily price points per retailer** → sparklines, "lowest in N days", drop detection — all NATIVE. We do NOT need to snapshot ourselves.
- Dates are sparse (only changed/scraped days) → interpolate flat between points for charts.
- `has_price_history_timeseries: false` possible → guard before rendering trend.
- Window observed ~30 days. Check `date_range` for actual span.

---

## 2d. Retailers directory ✓

```
GET /meta/retailers
```
```jsonc
{
  "count": 20,
  "retailers": [
    { "id": "lidl", "name": "Lidl", "country": "GR",
      "logo_url": "/images/retailer/lidl",     // ⚠️ RELATIVE → prefix base URL
      "website": "https://www.lidl-hellas.gr" }, ...
  ]
}
```
- 20 retailers across GR, CY, IT, BE, DE, PT, RO, FR, BG. (stats says 22 exist — directory lists 20.)
- `logo_url` relative + can be `null`; `website` can be `null`.
- Use for: store filter chips, logos, "open store site", per-country grouping.
- GR chains: sklavenitis, ab_vasilopoulos, masoutis, mymarket, galaxias, kritikos, market_in, synka, halkiadakis, lidl.

---

## 2e. Global stats ✓ (home dashboard)

```
GET /meta/stats
```
```jsonc
{
  "total_products": 8783,
  "active_products": 8778,
  "retailers": [ "masoutis", ... ],   // 22 slugs (incl. carrefourspain, skroutz not in /meta/retailers)
  "retailer_count": 22,
  "products_on_discount": 2702,
  "timestamp": "2026-06-17T12:00:18.927530"
}
```
- Home counters: "8,783 products · 22 stores · 2,702 on offer today".
- `products_on_discount` (2702) vs `has_discount=true` total (2105) differ → 2105 is the active/queryable subset.

---

## 2f. Flat category list ✓ (alternative to tree)

```
GET /meta/categories
```
```jsonc
{
  "count": 313,
  "categories": [
    { "category_id": "...",
      "category_name": "Χαρτικά",   // ⚠️ key is category_name here, NOT name (tree uses name)
      "name_en": "Cleaning Papers/Tissues/Towels",
      "depth": 1,
      "parent_id": "648a987abf254feb8cf62a10ea1eb117",  // ⚠️ tree has NO parent_id; this has it
      "image_url": "...",
      "product_count": 204 }, ...
  ]
}
```
- 313 entries (vs 2695 in tree) → this is a curated/sellable subset, flat with `parent_id`.
- Use when you need quick parent lookup / breadcrumb without walking the tree, or a flat searchable category index.
- ⚠️ Different field names than tree (`category_name` vs `name`) — map carefully.

---

## 3. Images

```
GET /images/category/<category_id>?v=<ver>
GET /images/product/<product_id>?v=<image_version>
GET /images/retailer/<retailer_id>            ✓ PNG store logo (~10KB), no version param
```
- `?v=` is a cache-buster. Safe to cache aggressively keyed by version.
- Category `image_url` can be `null` → placeholder required.
- Retailer `logo_url` from `/meta/retailers` is relative (`/images/retailer/lidl`) → prefix base URL; can be `null`.

---

## Retailer slugs → use `/meta/retailers` (full 20) for the live list
GR: `sklavenitis` Σκλαβενίτης · `ab_vasilopoulos` ΑΒ Βασιλόπουλος · `masoutis` Μασούτης · `mymarket` My Market · `galaxias` Γαλαξίας · `kritikos` Κρητικός · `market_in` Market In · `synka` ΣΥΝ.ΚΑ · `halkiadakis` Χαλκιαδάκης · `lidl` Lidl
EU: `alphamega`(CY) · `auchan`(FR) · `carrefour_it`(IT) · `conad`(IT) · `colruyt`(BE) · `delhaize`(BE) · `continente`(PT) · `freshful`(RO) · `ebag`(BG) · `edeka24`(DE) · (stats adds `carrefourspain`, `skroutz`)

> Always prefer `retailer_display_name` from the product payload; use this map / `/meta/retailers` for logos, websites, colors, country grouping.

---

## Endpoint status (fully probed 2026-06-17)
| endpoint | status |
|---|---|
| `GET /` | ✓ `{"status":"ok"}` |
| `GET /meta/categories/tree` | ✓ hierarchical tree (2695 nodes) |
| `GET /meta/categories` | ✓ flat list (313, has `parent_id`, key `category_name`) |
| `GET /meta/retailers` | ✓ 20 retailers (logo, website, country) |
| `GET /meta/stats` | ✓ totals + discount count + 22 retailer slugs |
| `GET /products?category=<id>` | ✓ products in category (NOT `category_id`) |
| `GET /products?q=<term>` | ✓ fuzzy free-text search |
| `GET /products?retailer=<slug>` | ✓ |
| `GET /products?has_discount=true` | ✓ |
| `GET /products?private_label=true` | ✓ |
| `GET /products/<id>` | ✓ single product |
| `GET /products/<id>/history` | ✓ **daily price time-series** |
| `GET /images/{category\|product\|retailer}/<id>` | ✓ |
| `GET /products?category_id=` `category_ids=` `brand=` `country=` `min_price=` `max_price=` `sort=` `sort_by=` `discount=` `on_discount=` | ✗ IGNORED (silent global return / no sort) |
| `GET /search`, `/products/search`, `/categories/<id>/products`, `/meta/categories/<id>/products` | ✗ 404 |
| `GET /meta`, `/retailers`, `/brands`, `/stats`, `/health`, `/deals`, `/docs`, `/openapi.json` | ✗ 404 |

**Price history is NATIVE** via `/products/<id>/history` — we do NOT need to build our own snapshot store for trends. (Own store still useful only for user data: favorites, baskets, alert thresholds.)

Still unprobed (low priority): single-category detail route, brand directory, multi-category AND, write/POST endpoints (assume read-only public API).
