import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../theme/app_theme.dart';
import '../theme/tokens.dart';

/// The price-tag mark (favicon / lockup symbol).
class BrandMark extends StatelessWidget {
  final double size;
  const BrandMark({super.key, this.size = 40});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.asset(
      'assets/mark.svg',
      width: size,
      height: size,
      semanticsLabel: 'πόσο κάνει',
    );
  }
}

/// Wordmark lockup: mark + "πόσο κάνει" set in Archivo extrabold.
class Logo extends StatelessWidget {
  final double size;
  final bool light;
  final bool showMark;
  final bool showWord;
  const Logo({
    super.key,
    this.size = 28,
    this.light = false,
    this.showMark = true,
    this.showWord = true,
  });

  @override
  Widget build(BuildContext context) {
    final color = light ? const Color(0xFFF5F1E6) : context.pk.textPrimary;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showMark) ...[
          BrandMark(size: size * 1.5),
          SizedBox(width: size * 0.42),
        ],
        if (showWord)
          Text(
            'πόσο κάνει',
            style: PkText.display(size: size, weight: FontWeight.w800, color: color, tracking: -0.03),
          ),
      ],
    );
  }
}
