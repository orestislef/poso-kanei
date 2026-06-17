import 'package:flutter/widgets.dart';

import '../api/models.dart';

/// The four persistent destinations in the header / bottom nav.
enum PkTab { home, deals, stores, basket }

/// Navigation contract every screen calls into. Implemented by the root shell.
abstract class PkNav {
  void goTab(PkTab tab);
  void openCategory({
    String? categoryId,
    String? categoryName,
    String? query,
    String? retailer,
    String? retailerName,
    bool dealsOnly = false,
  });
  void openProduct(Product product, {String? heroTag});
  void openProductById(String id);
  void back();
}

/// Provides the active [PkNav] to descendants.
class PkNavScope extends InheritedWidget {
  final PkNav nav;
  const PkNavScope({super.key, required this.nav, required super.child});

  static PkNav of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<PkNavScope>()!.nav;

  @override
  bool updateShouldNotify(PkNavScope oldWidget) => oldWidget.nav != nav;
}
