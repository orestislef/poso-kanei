import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/models.dart';

/// App-wide state: theme, basket, favorites, and the shared [ApiClient].
class PkAppState extends ChangeNotifier {
  final ApiClient api = ApiClient();

  bool _dark = false;
  bool get dark => _dark;
  ThemeMode get themeMode => _dark ? ThemeMode.dark : ThemeMode.light;
  void toggleTheme() {
    _dark = !_dark;
    notifyListeners();
  }

  final List<Product> _basket = [];
  List<Product> get basket => List.unmodifiable(_basket);
  int get basketCount => _basket.length;
  bool inBasket(String id) => _basket.any((p) => p.id == id);
  void addToBasket(Product p) {
    if (!inBasket(p.id)) {
      _basket.add(p);
      notifyListeners();
    }
  }

  void removeFromBasket(String id) {
    _basket.removeWhere((p) => p.id == id);
    notifyListeners();
  }

  void toggleBasket(Product p) =>
      inBasket(p.id) ? removeFromBasket(p.id) : addToBasket(p);

  final Set<String> _favs = {};
  bool isFav(String id) => _favs.contains(id);
  void toggleFav(String id) {
    _favs.contains(id) ? _favs.remove(id) : _favs.add(id);
    notifyListeners();
  }

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
