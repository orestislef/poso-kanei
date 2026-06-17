import 'package:flutter/material.dart';

import 'shared.dart';

/// Category browse / search results grid. (Implemented in the screens pass.)
class CategoryScreen extends StatelessWidget {
  final String? categoryId;
  final String? categoryName;
  final String? query;
  final String? retailer;
  final String? retailerName;
  final bool dealsOnly;
  const CategoryScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.query,
    this.retailer,
    this.retailerName,
    this.dealsOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      child: PkEmptyView(message: 'Κατηγορίες — έρχεται…'),
    );
  }
}
