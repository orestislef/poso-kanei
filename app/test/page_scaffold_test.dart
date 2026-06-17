import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:poso_kanei/screens/shared.dart';
import 'package:poso_kanei/theme/app_theme.dart';

void main() {
  testWidgets('PageScaffold centers content on a wide viewport', (tester) async {
    tester.view.physicalSize = const Size(2000, 1200);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.resetPhysicalSize);

    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      theme: PkTheme.light,
      home: Scaffold(
        body: PageScaffold(
          showFooter: false,
          child: SizedBox(key: key, height: 100, child: const Text('x')),
        ),
      ),
    ));
    await tester.pump();

    final box = tester.getRect(find.byKey(key));
    final leftGap = box.left;
    final rightGap = 2000 - box.right;
    // ignore: avoid_print
    print('CENTERTEST left=$leftGap right=$rightGap width=${box.width}');
    expect((leftGap - rightGap).abs() < 2.0, isTrue,
        reason: 'not centered: left=$leftGap right=$rightGap');
  });
}
