import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../i18n/strings.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/core.dart';

/// Professional 404 for unknown paths / missing products & categories.
class NotFoundScreen extends StatelessWidget {
  const NotFoundScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
    return Scaffold(
      backgroundColor: pk.canvas,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Padding(
              padding: const EdgeInsets.all(28),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const BrandMark(size: 64),
                  const SizedBox(height: 24),
                  Text('404',
                      style: PkText.display(size: 64, weight: FontWeight.w800, color: pk.primary)),
                  const SizedBox(height: 8),
                  Text(
                    t.notFoundTitle,
                    textAlign: TextAlign.center,
                    style: PkText.display(size: 24, weight: FontWeight.w800, color: pk.textPrimary),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    t.notFoundBody,
                    textAlign: TextAlign.center,
                    style: PkText.body(size: 15, color: pk.textSecondary, height: 1.5),
                  ),
                  const SizedBox(height: 28),
                  PkButton(
                    size: PkButtonSize.lg,
                    label: t.goHome,
                    iconLeft: const Icon(Icons.home_outlined, size: 18, color: Colors.white),
                    onPressed: () => context.go('/${t.lang.code}'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
