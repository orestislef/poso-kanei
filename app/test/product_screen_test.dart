import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poso_kanei/api/models.dart';
import 'package:poso_kanei/state/app_state.dart';
import 'package:poso_kanei/screens/nav.dart';
import 'package:poso_kanei/screens/product_screen.dart';
import 'package:poso_kanei/theme/app_theme.dart';

class _FakeNav implements PkNav {
  @override
  void goTab(PkTab tab) {}
  @override
  void openCategory({String? categoryId, String? categoryName, String? query, String? retailer, String? retailerName, bool dealsOnly = false}) {}
  @override
  void openProduct(Product product, {String? heroTag}) {}
  @override
  void openProductById(String id) {}
  @override
  void back() {}
}

void main() {
  testWidgets('product screen renders without throwing', (tester) async {
    tester.view.physicalSize = const Size(1400, 2400);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final p = Product.fromJson({
      'id': 'p1',
      'name': 'Γάλα φρέσκο πλήρες',
      'brand': 'ΦΑΓΕ',
      'unit': 'L',
      'unit_quantity': 1,
      'has_image': false,
      'category_ids': ['dairy'],
      'price_stats': {
        'min_price': 1.29,
        'max_price': 1.69,
        'avg_price': 1.49,
        'min_unit_price': 1.29,
        'retailer_count': 2,
      },
      'retailer_prices': [
        {'retailer': 'lidl', 'price': 1.29, 'price_normalized': 1.29, 'is_discount': true, 'discount_percentage': 15, 'last_updated': '2026-06-10'},
        {'retailer': 'sklavenitis', 'price': 1.69, 'price_normalized': 1.69, 'is_discount': false},
      ],
    });

    final state = PkAppState();
    await tester.pumpWidget(MaterialApp(
      theme: PkTheme.light,
      home: AppScope(
        state: state,
        child: PkNavScope(
          nav: _FakeNav(),
          child: Scaffold(body: ProductScreen(product: p, heroTag: 't')),
        ),
      ),
    ));
    await tester.pump(const Duration(milliseconds: 50));

    final err = tester.takeException();
    expect(err, isNull, reason: 'ProductScreen threw: $err');
  });
}
