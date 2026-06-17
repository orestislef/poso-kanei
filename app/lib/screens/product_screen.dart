import 'package:flutter/material.dart';

import '../api/models.dart';
import 'shared.dart';

/// Product detail: retailer table, spread bar, history sparkline, alternatives.
/// (Implemented in the screens pass.)
class ProductScreen extends StatelessWidget {
  final Product? product;
  final String? productId;
  final String? heroTag;
  const ProductScreen({super.key, this.product, this.productId, this.heroTag});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      child: PkEmptyView(message: 'Προϊόν — έρχεται…'),
    );
  }
}
