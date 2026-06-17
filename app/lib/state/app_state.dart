import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../i18n/lang.dart';

/// One line in the basket: a product plus the store the user chose to buy it
/// from. [store] == null means "let the optimizer pick the cheapest".
class BasketItem {
  final Product product;
  String? store;
  BasketItem(this.product, {this.store});

  /// The effective retailer slug: the chosen store, else the cheapest.
  String? get effectiveStore => store ?? _cheapest;

  String? get _cheapest {
    final sorted = product.sortedByPrice;
    if (sorted.isNotEmpty) return sorted.first.retailer;
    return product.retailerPrices.isNotEmpty ? product.retailerPrices.first.retailer : null;
  }

  RetailerPrice? get chosenPrice {
    final slug = effectiveStore;
    if (slug == null) return null;
    for (final rp in product.retailerPrices) {
      if (rp.retailer == slug) return rp;
    }
    return null;
  }

  /// The cheapest retailer price (for "you could save" hints).
  RetailerPrice? get cheapestPrice {
    final sorted = product.sortedByPrice;
    return sorted.isNotEmpty ? sorted.first : null;
  }

  /// True when the chosen store is not the cheapest available one.
  bool get hasCheaperElsewhere {
    final chosen = chosenPrice;
    final cheap = cheapestPrice;
    if (chosen == null || cheap == null) return false;
    return cheap.retailer != chosen.retailer && cheap.price < chosen.price - 0.0001;
  }

  double get price => chosenPrice?.price ?? product.minPrice ?? 0;
}

/// App-wide state: language, theme, basket, and the shared [ApiClient].
class PkAppState extends ChangeNotifier {
  final ApiClient api = ApiClient();

  // ── Language ──────────────────────────────────────────────────────────────
  Lang _lang = Lang.el;
  Lang get lang => _lang;
  void setLang(Lang l) {
    if (_lang == l) return;
    _lang = l;
    notifyListeners();
  }

  // ── Theme ───────────────────────────────────────────────────────────────
  bool _dark = false;
  bool get dark => _dark;
  ThemeMode get themeMode => _dark ? ThemeMode.dark : ThemeMode.light;
  void toggleTheme() {
    _dark = !_dark;
    notifyListeners();
  }

  // ── Basket ──────────────────────────────────────────────────────────────
  final List<BasketItem> _basket = [];
  List<BasketItem> get basket => List.unmodifiable(_basket);
  int get basketCount => _basket.length;

  bool inBasket(String id) => _basket.any((b) => b.product.id == id);

  BasketItem? itemFor(String id) {
    for (final b in _basket) {
      if (b.product.id == id) return b;
    }
    return null;
  }

  /// Add a product (optionally from a specific [store]). If it's already in the
  /// basket, just update the chosen store.
  void addToBasket(Product p, {String? store}) {
    final existing = itemFor(p.id);
    if (existing != null) {
      if (store != null) existing.store = store;
    } else {
      _basket.add(BasketItem(p, store: store));
    }
    notifyListeners();
  }

  /// Set (or clear) the chosen store for a basket item, adding it if needed.
  void setStore(Product p, String? store) {
    final item = itemFor(p.id);
    if (item == null) {
      _basket.add(BasketItem(p, store: store));
    } else {
      item.store = store;
    }
    notifyListeners();
  }

  void removeFromBasket(String id) {
    _basket.removeWhere((b) => b.product.id == id);
    notifyListeners();
  }

  void toggleBasket(Product p, {String? store}) =>
      inBasket(p.id) ? removeFromBasket(p.id) : addToBasket(p, store: store);

  @override
  void dispose() {
    api.close();
    super.dispose();
  }
}

/// Exposes [PkAppState] to the tree and rebuilds dependents on change.
class AppScope extends InheritedNotifier<PkAppState> {
  const AppScope({super.key, required PkAppState state, required super.child})
      : super(notifier: state);

  static PkAppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }

  /// Read without subscribing to rebuilds.
  static PkAppState read(BuildContext context) {
    final scope = context.getInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope not found in widget tree');
    return scope!.notifier!;
  }
}
