<div align="center">

# πόσο κάνει

**Μην ρωτάς πόσο κάνει. Ρώτα πού είναι φθηνότερο.**
**Don't ask what it costs. Ask where it's cheapest.**

Σύγκριση τιμών σούπερ μάρκετ για όλη την Ελλάδα — με πραγματική τιμή ανά κιλό, έξυπνο καλάθι και ιστορικό τιμών.
A grocery price-intelligence app for the Greek market — true price-per-kilo, a smart basket optimizer, and native price history.

[![License: MIT](https://img.shields.io/badge/License-MIT-1f6b4a.svg)](LICENSE)
![Flutter](https://img.shields.io/badge/Flutter-3.44-027DFD.svg)
![Platforms](https://img.shields.io/badge/platforms-web%20·%20android%20·%20ios-555.svg)

🔗 **Live demo / Δοκιμαστικό:** **[orestislef.gr/posokanei](https://orestislef.gr/posokanei/)**

</div>

> ℹ️ Built on the public price API `api.posokanei.gov.gr`. It is an independent
> client, not affiliated with the data provider; prices are whatever the public
> API returns. / Ανεξάρτητη εφαρμογή πάνω στο δημόσιο API — όχι επίσημος πελάτης.

---

## 🇬🇷 Ελληνικά

### Τι είναι

Το **πόσο κάνει** παίρνει τις τιμές των ελληνικών σούπερ μάρκετ από το δημόσιο API
`api.posokanei.gov.gr` και τις μετατρέπει σε αποφάσεις. Δεν δείχνει απλώς τιμές — σου λέει
**πού να ψωνίσεις για να ξοδέψεις λιγότερα.**

### Τι το κάνει διαφορετικό

- **🏷️ Πραγματική τιμή ανά μονάδα (€/kg, €/L).** Κατατάσσει κάθε σούπερ μάρκετ με βάση το
  πραγματικό κόστος, όχι την τιμή της ετικέτας. Συχνά η μεγάλη συσκευασία που φαίνεται ακριβότερη
  βγαίνει φθηνότερη ανά κιλό.
- **🧺 Έξυπνο καλάθι.** Διαλέγεις από ποιο μαγαζί παίρνεις κάθε προϊόν, το καλάθι ομαδοποιεί «τι
  παίρνεις από πού», προτείνει το φθηνότερο και αντιγράφεις τη λίστα για κοινοποίηση.
- **📉 Ιστορικό τιμών.** Δείχνει το χαμηλότερο των τελευταίων 30 ημερών — έτσι μια «προσφορά» που
  δεν ήταν ποτέ πραγματικά φθηνότερη ξεσκεπάζεται.
- **🔎 Αναζήτηση & κατηγορίες.** Δέντρο κατηγοριών, ασαφής αναζήτηση, κατάλογος 20+ καταστημάτων.
- **🔗 Δίγλωσσο με μοιραζόμενα URL.** Πλήρη Ελληνικά/Αγγλικά με τη γλώσσα στο URL (`/el`, `/en`)·
  κατηγορίες, αναζήτηση, μαγαζιά και προϊόντα έχουν σταθερό, κοινοποιήσιμο σύνδεσμο.

### Χαρακτηριστικά

Αρχική με ζωντανούς μετρητές · Περιήγηση/αναζήτηση · Καρτέλα προϊόντος (πίνακας καταστημάτων,
μπάρα διασποράς τιμής, sparkline ιστορικού) · Καλάθι & βελτιστοποιητής · Προσφορές · Κατάστημα ·
Πλήρες σκούρο θέμα · Δίγλωσσο (Ελληνικά/Αγγλικά).

---

## 🇬🇧 English

### What it is

**πόσο κάνει** ("how much does it cost") sits on top of the public price API
`api.posokanei.gov.gr` and turns raw supermarket prices into decisions. It doesn't just show
prices — it tells you **where to shop to spend less.**

### What makes it different

- **🏷️ True unit price (€/kg, €/L).** Ranks every supermarket by real cost, not sticker price.
  The bigger pack that looks dearer is often the cheapest per kilo.
- **🧺 Smart basket.** Pick which store you buy each item from; the basket groups "what to buy
  where", flags a cheaper store per item, one-tap optimizes to the cheapest, and copies a clean
  shareable list.
- **📉 Native price history.** Shows the 30-day low, so a "discount" that was never actually lower
  gets called out.
- **🔎 Search & categories.** A category tree, fuzzy search, a 20+ store directory.
- **🔗 Bilingual, shareable URLs.** Full Greek/English with the language in the URL (`/el`, `/en`);
  categories, search, stores and products each have a stable, shareable link.

### Surfaces

Home with live counters · Browse / search grid · Product detail (retailer table, price-spread bar,
history sparkline) · Basket & optimizer · Deals · Stores directory · Full dark theme · Bilingual.

---

## 🚀 Getting started

```bash
cd app
flutter pub get

# Web
flutter run -d chrome

# Android / iOS (with a device or emulator running)
flutter run
```

Builds:

```bash
flutter build web        # static site → build/web
flutter build apk        # Android
flutter build ipa        # iOS
```

## 🧱 Tech

- **Flutter** — single codebase for web, Android and iOS.
- **Material 3** theming with a custom design system (warm Mediterranean palette, full dark theme).
- **go_router** clean-path URLs (path strategy, no `#`) with a language prefix and a 404 page.
- Type: **Archivo** (display & prices, tabular figures), **Commissioner** (body, Greek-native),
  **Spline Sans Mono** (technical labels) — all cover the full Greek glyph set.
- Networking via `http`; images cached with `cached_network_image`; edge-to-edge with safe areas.

## 🔌 API

Read-only public endpoints used (`https://api.posokanei.gov.gr`):

| Endpoint | Purpose |
|---|---|
| `GET /meta/categories/tree` | Category tree |
| `GET /meta/retailers` | Store directory (logos, websites) |
| `GET /meta/stats` | Live catalog counters |
| `GET /products?category=&q=&retailer=&has_discount=` | Product listing / search / filters |
| `GET /products/{id}` | Single product |
| `GET /products/{id}/history` | Daily price time-series |
| `GET /images/{category\|product\|retailer}/{id}` | Images & logos |

## 📁 Structure

```
app/
  lib/
    theme/      design tokens & Material theme
    widgets/    core + domain components (ProductCard, PriceDisplay, Sparkline, …)
    api/        models + API client
    screens/    splash, onboarding, home, browse, product, basket, stores, deals
    state/      app-wide state (basket, favorites, theme)
```

## 🗺️ Roadmap

- [x] Real per-unit (€/kg, €/L) ranking across stores
- [x] Per-product store selection + "what to buy where" basket
- [x] Native 30-day price history
- [x] Full Greek/English with language in the URL + shareable deep links
- [ ] Saved & reusable weekly lists
- [ ] Price-drop notifications
- [ ] EU VAT / cross-border price view
- [ ] Barcode scan → product match

## 📄 License

Released under the [MIT License](LICENSE).
