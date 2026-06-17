import 'package:flutter/material.dart';

import 'shared.dart';

/// Retailer directory. (Implemented in the screens pass.)
class StoresScreen extends StatelessWidget {
  const StoresScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PageScaffold(
      child: PkEmptyView(message: 'Καταστήματα — έρχεται…'),
    );
  }
}
