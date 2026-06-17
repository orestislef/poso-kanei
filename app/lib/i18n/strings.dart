import 'package:flutter/widgets.dart';

import '../state/app_state.dart';
import 'lang.dart';

export 'lang.dart';

/// All user-facing copy, Greek + English side by side. One instance per active
/// [Lang]; access via `context.t`.
class T {
  final Lang lang;
  const T(this.lang);

  bool get isEl => lang == Lang.el;
  String _(String el, String en) => lang == Lang.el ? el : en;

  // ── Brand / shared ────────────────────────────────────────────────────────
  String get brand => 'πόσο κάνει';
  String get tagline =>
      _('Μην ρωτάς πόσο κάνει. Ρώτα πού είναι φθηνότερο.',
        "Don't ask what it costs. Ask where it's cheapest.");
  String get back => _('Πίσω', 'Back');
  String get retry => _('Δοκίμασε ξανά', 'Try again');
  String get footer =>
      _('© 2026 πόσο κάνει · δεδομένα από api.posokanei.gov.gr',
        '© 2026 πόσο κάνει · data from api.posokanei.gov.gr');

  // ── Splash ──────────────────────────────────────────────────────────────
  String get checkingStores => _('έλεγχος καταστημάτων…', 'checking stores…');

  // ── Header / nav ──────────────────────────────────────────────────────────
  String get navHome => _('Αρχική', 'Home');
  String get navDeals => _('Προσφορές', 'Deals');
  String get navStores => _('Καταστήματα', 'Stores');
  String get navBasket => _('Καλάθι', 'Basket');
  String get searchHint =>
      _('Αναζήτησε 8.500+ προϊόντα — γάλα, ελαιόλαδο, καφέ…',
        'Search 8,500+ products — milk, olive oil, coffee…');
  String get searchShort => _('Αναζήτηση', 'Search');
  String get toggleTheme => _('Εναλλαγή θέματος', 'Toggle theme');
  String get toggleLang => _('Switch to English', 'Αλλαγή σε Ελληνικά');

  // ── Onboarding ────────────────────────────────────────────────────────────
  String get obSkip => _('Παράλειψη', 'Skip');
  String get obNext => _('Επόμενο', 'Next');
  String get obStart => _('Ξεκίνα να γλιτώνεις', 'Start saving');

  String get ob1Tag => _('ΣΥΓΚΡΙΣΗ', 'COMPARE');
  String get ob1Title => _('Η πραγματική τιμή, ανά κιλό', 'The real price, per kilo');
  String get ob1Body => _(
      'Κατατάσσουμε κάθε σούπερ μάρκετ με βάση το πραγματικό €/kg και €/L — έτσι η μεγάλη συσκευασία που φαίνεται ακριβότερη βγαίνει συχνά φθηνότερη. Οι τιμές της ετικέτας ξεγελούν· οι τιμές ανά μονάδα όχι.',
      'We rank every supermarket by real €/kg and €/L — so the big pack that looks dearer is often the cheapest. Sticker prices mislead; unit prices don\'t.');
  String get ob2Tag => _('ΒΕΛΤΙΣΤΟΠΟΙΗΣΗ', 'OPTIMIZE');
  String get ob2Title => _('Ένα καλάθι, τα φθηνότερα μαγαζιά', 'One basket, the cheapest stores');
  String get ob2Body => _(
      'Φτιάξε την εβδομαδιαία λίστα σου και το πόσο κάνει τη μοιράζει: όλα σε μία αλυσίδα, ή ένα έξυπνο πλάνο 2 στάσεων που σε γλιτώνει τα περισσότερα.',
      'Build your weekly list and πόσο κάνει splits it: everything at one chain, or a smart 2-stop plan that saves the most.');
  String get ob3Tag => _('ΠΑΡΑΚΟΛΟΥΘΗΣΗ', 'TRACK');
  String get ob3Title => _('Αληθινές προσφορές, όχι ψεύτικες', 'Real deals, not fake ones');
  String get ob3Body => _(
      'Το ιστορικό τιμών δείχνει το χαμηλότερο 30 ημερών — έτσι μια «έκπτωση» που δεν ήταν ποτέ πραγματικά φθηνότερη ξεσκεπάζεται με μια ματιά.',
      'Price history shows the 30-day low — so a "discount" that was never actually cheaper is exposed at a glance.');

  // onboarding demo cards
  String get demoUnitNote => _('το 1kg είναι φθηνότερο ανά γραμμάριο', 'the 1kg is cheaper per gram');
  String get demoPlan2 => _('Πλάνο 2 στάσεων', '2-stop plan');
  String demoSave(String amt) => _('γλιτώνεις $amt', 'save $amt');
  String demoItems(int n) => _('$n προϊόντα', '$n items');
  String get demoHistNote => _('χαμηλότερο σε 30 ημέρες · €2.39', '30-day low · €2.39');

  // ── Home ──────────────────────────────────────────────────────────────────
  String get heroEyebrow => _('PRICE INTELLIGENCE · ΕΛΛΑΔΑ', 'PRICE INTELLIGENCE · GREECE');
  String get heroTitle1 => _('Μην ρωτάς πόσο κάνει.', "Don't ask how much it costs.");
  String get heroTitle2 => _('Ρώτα πού είναι φθηνότερο.', 'Ask where it\'s cheapest.');
  String get heroBody => _(
      'Σύγκρινε κάθε ελληνικό σούπερ μάρκετ με βάση την πραγματική τιμή ανά κιλό, φτιάξε καλάθι και άσε το πόσο κάνει να διαλέξει τα φθηνότερα μαγαζιά.',
      'Compare every Greek supermarket by true price-per-kilo, build a basket, and let πόσο κάνει pick the cheapest stores.');
  String get statProducts => _('προϊόντα', 'products');
  String get statStores => _('καταστήματα', 'stores');
  String get statOnDeal => _('σε προσφορά', 'on deal');
  String get secCategories => _('Περιήγηση κατηγοριών', 'Browse categories');
  String get secAllCategories => _('Όλες οι κατηγορίες', 'All categories');
  String get secDrops => _('Οι μεγαλύτερες πτώσεις σήμερα', "Today's biggest drops");
  String get secAllDeals => _('Όλες οι προσφορές', 'All deals');
  String secStoresCount(int n) =>
      _('Συγκρίνουμε $n μαγαζιά', 'We compare $n stores');
  String get secStoresGeneric => _('Συγκρίνουμε σούπερ μάρκετ', 'We compare supermarkets');
  String get noDropsToday => _(
      'Δεν υπάρχουν νέες πτώσεις σήμερα.', 'No new drops today.');

  // ── Category / browse ───────────────────────────────────────────────────
  String get railCategories => _('ΚΑΤΗΓΟΡΙΕΣ', 'CATEGORIES');
  String get allProducts => _('Όλα τα προϊόντα', 'All products');
  String get all => _('Όλα', 'All');
  String get searchProduct => _('Αναζήτησε προϊόν…', 'Search a product…');
  String resultsFor(String q) => _('Αποτελέσματα για «$q»', 'Results for "$q"');
  String storeLead(String name) => _('Κατάστημα: $name', 'Store: $name');
  String get deals => _('Προσφορές', 'Deals');
  String productCount(int n) =>
      _('$n ${n == 1 ? 'προϊόν' : 'προϊόντα'}', '$n ${n == 1 ? 'product' : 'products'}');
  String get sort => _('Ταξινόμηση', 'Sort');
  String get sortUnit => _('€/μον.', '€/unit');
  String get sortPrice => _('Τιμή', 'Price');
  String get sortDeal => _('Έκπτωση %', 'Discount %');
  String get onlyDeals => _('Μόνο σε προσφορά', 'Deals only');
  String get loadMore => _('Φόρτωσε περισσότερα', 'Load more');
  String get noMatch => _(
      'Καμία αντιστοίχιση. Δοκίμασε άλλον όρο — η αναζήτηση είναι «χαλαρή», οπότε γράψε ελεύθερα.',
      'No matches. Try another term — search is fuzzy, so type freely.');

  // ── Product detail ──────────────────────────────────────────────────────
  String get productNotFound => _('Δεν βρέθηκε το προϊόν.', 'Product not found.');
  String get cheapestPrice => _('Φθηνότερη τιμή', 'Cheapest price');
  String bestPerUnit(String unit) => _('Καλύτερο €/$unit', 'Best €/$unit');
  String get realComparison => _('πραγματική σύγκριση', 'real comparison');
  String spreadIn(int n) =>
      _('Διασπορά τιμής σε $n μαγαζιά', 'Price spread across $n stores');
  String get whereToBuy => _('Πού να αγοράσεις', 'Where to buy');
  String get noPrices => _('Δεν υπάρχουν διαθέσιμες τιμές.', 'No prices available.');
  String get cheapestBadge => _('φθηνότερο', 'cheapest');
  String get selected => _('επιλεγμένο', 'selected');
  String get tapToChoose => _('Διάλεξε μαγαζί', 'Tap to choose a store');
  String get priceHistory => _('Ιστορικό τιμών', 'Price history');
  String low30(String amt) => _('χαμηλότερο 30ημ. · $amt', '30-day low · $amt');
  String get noHistory => _('Δεν υπάρχει ακόμη ιστορικό τιμών.', 'No price history yet.');
  String get atLowNote => _(
      'Η σημερινή τιμή πιάνει το χαμηλότερο 30 ημερών — γνήσια προσφορά.',
      "Today's price matches the 30-day low — a genuine deal.");
  String get alternatives => _('Φθηνότερες εναλλακτικές', 'Cheaper alternatives');
  String get inBasket => _('Στο καλάθι σου', 'In your basket');
  String get addToBasket => _('Προσθήκη στο καλάθι', 'Add to basket');

  // ── Basket ────────────────────────────────────────────────────────────────
  String get yourBasket => _('Το καλάθι σου', 'Your basket');
  String get basketEmptyTitle => _('Το καλάθι σου είναι άδειο', 'Your basket is empty');
  String get basketEmptyBody => _(
      'Πρόσθεσε προϊόντα και βρίσκουμε τον φθηνότερο τρόπο να τα αγοράσεις όλα.',
      'Add products and we find the cheapest way to buy them all.');
  String get startList => _('Ξεκίνα μια λίστα', 'Start a list');
  String get optimizerTag => _('ΕΞΥΠΝΟΣ ΒΕΛΤΙΣΤΟΠΟΙΗΤΗΣ', 'SMART OPTIMIZER');
  String get optimizerTitle => _('Ο φθηνότερος τρόπος να το αγοράσεις', 'The cheapest way to buy it');
  String get stratSingle => _('1 μαγαζί', '1 store');
  String get stratSplit => _('Διαμοιρασμός', 'Split');
  String get stratBalanced => _('2 στάσεις', '2 stops');
  String get basketTotal => _('ΣΥΝΟΛΟ ΚΑΛΑΘΙΟΥ', 'BASKET TOTAL');
  String vsAvg(String amt) => _('vs $amt μ.ό.', 'vs $amt avg');
  String youSave(String amt) => _('γλιτώνεις $amt', 'you save $amt');
  String get stratSingleNote => _(
      'Αγόρασε τα πάντα σε μία αλυσίδα — λιγότερες στάσεις, ελαφρώς υψηλότερο σύνολο.',
      'Buy everything at one chain — fewer stops, slightly higher total.');
  String get stratBalancedNote => _(
      'Με όριο 2 μαγαζιά: σχεδόν όλη η εξοικονόμηση του split, με τις μισές στάσεις.',
      'Capped at 2 stores: almost all the split savings, with half the stops.');
  String get copyList => _('Αντιγραφή λίστας', 'Copy list');
  String get whatToBuyWhere => _('Τι θα πάρεις από πού', 'What to buy, where');
  String get allCheapest => _('Όλα στο φθηνότερο', 'All at cheapest');
  String get yourTotalLabel => _('ΤΟ ΣΥΝΟΛΟ ΣΟΥ', 'YOUR TOTAL');
  String cheaperAt(String store, String amt) =>
      _('φθηνότερο στο $store ($amt)', 'cheaper at $store ($amt)');
  String get pickStore => _('Διάλεξε μαγαζί', 'Pick a store');
  String get listCopied => _(
      'Η λίστα αγορών αντιγράφηκε — επικόλλησέ την όπου θες.',
      'Shopping list copied — paste it anywhere.');
  String get cheapestAt => _('φθηνότερο σε', 'cheapest at');
  String stops(int n) => _('$n ${n == 1 ? 'στάση' : 'στάσεις'}', '$n ${n == 1 ? 'stop' : 'stops'}');
  String get listTitle => _('🛒 Λίστα αγορών — πόσο κάνει', '🛒 Shopping list — πόσο κάνει');
  String listTotal(String amt) =>
      _('Σύνολο (φθηνότερος διαμοιρασμός): $amt', 'Total (cheapest split): $amt');
  String listSaving(String amt) =>
      _('Εκτίμηση εξοικονόμησης vs μέσος όρος: $amt', 'Estimated saving vs average: $amt');

  // ── Stores ──────────────────────────────────────────────────────────────
  String get storesTitle => _('Καταστήματα που συγκρίνουμε', 'Stores we compare');
  String get storesSubtitle => _(
      'Αλυσίδες σε Ελλάδα και ΕΕ, ανανεώνονται συνεχώς.',
      'Chains across Greece and the EU, updated continuously.');
  String storesCount(int n) => _('$n καταστήματα', '$n stores');
  String get noStores => _('Δεν βρέθηκαν καταστήματα.', 'No stores found.');
  String get browseStore => _('Περιήγηση καταστήματος', 'Browse store');

  // ── Freshness ─────────────────────────────────────────────────────────────
  String get dateUnknown => _('άγνωστη ημ/νία', 'date unknown');
  List<String> get months => isEl
      ? const ['Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαΐ', 'Ιουν', 'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ']
      : const ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

  // ── Price display ─────────────────────────────────────────────────────────
  String get from => _('ΑΠΟ', 'FROM');
  String get spreadCheapest => _('φθηνότερη', 'cheapest');
  String get spreadAvg => _('μέση', 'average');
  String get spreadHighest => _('υψηλότερη', 'highest');

  // ── Product card ──────────────────────────────────────────────────────────
  String storeCountLabel(int n) =>
      _('$n ${n == 1 ? 'μαγαζί' : 'μαγαζιά'}', '$n ${n == 1 ? 'store' : 'stores'}');

  // ── Not found ─────────────────────────────────────────────────────────────
  String get notFoundTitle => _('Η σελίδα δεν βρέθηκε', 'Page not found');
  String get notFoundBody => _(
      'Ο σύνδεσμος ίσως είναι λάθος ή το προϊόν/κατηγορία δεν υπάρχει πια.',
      'The link may be wrong, or the product/category no longer exists.');
  String get goHome => _('Πήγαινε στην αρχική', 'Go to home');
}

/// `context.t` → the active [T] for the current language.
extension PkTextI18n on BuildContext {
  T get t => T(AppScope.of(this).lang);
}
