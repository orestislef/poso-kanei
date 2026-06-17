import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poso_kanei/router.dart';
import 'package:poso_kanei/screens/root_shell.dart';
import 'package:poso_kanei/state/app_state.dart';
import 'package:poso_kanei/theme/app_theme.dart';

void main() {
  testWidgets('router boots into the shell without throwing', (tester) async {
    tester.view.physicalSize = const Size(1200, 2000);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final state = PkAppState();
    await tester.pumpWidget(AppScope(
      state: state,
      child: MaterialApp.router(
        theme: PkTheme.light,
        routerConfig: buildRouter(),
      ),
    ));
    // Don't settle (skeleton shimmers animate forever); a couple of frames is enough.
    await tester.pump(const Duration(milliseconds: 100));

    expect(tester.takeException(), isNull);
    expect(find.byType(RootShell), findsOneWidget);
  });
}
