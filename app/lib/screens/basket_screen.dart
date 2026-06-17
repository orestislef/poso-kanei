import 'package:flutter/material.dart';

import 'shared.dart';

/// Basket + smart optimizer (single store / cheapest split / 2-stop).
/// (Implemented in the screens pass.)
class BasketScreen extends StatelessWidget {
  const BasketScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      child: PkEmptyView(message: 'Καλάθι — έρχεται…'),
    );
  }
}
