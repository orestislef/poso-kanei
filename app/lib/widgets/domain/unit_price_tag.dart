import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Inline pill showing a normalised per-unit price (e.g. `€2.40/kg`). When
/// [best] is true it highlights as the cheapest unit price in a comparison.
class UnitPriceTag extends StatelessWidget {
  final double value;
  final String unit;
  final bool best;
  final bool showIcon;

  const UnitPriceTag({
    super.key,
    required this.value,
    this.unit = 'kg',
    this.best = false,
    this.showIcon = true,
  });

  static String _fmt(double v) {
    if (v.isNaN || v.isInfinite) return '—';
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;

    final bg = best ? pk.saveSoft : pk.surfaceSunken;
    final fg = best ? pk.saveText : pk.textSecondary;
    final weight = best ? FontWeight.w600 : FontWeight.w500;

    final formatted = _fmt(value);
    final label = formatted == '—' ? '—' : '€$formatted/$unit';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: PkSpace.x2, vertical: PkSpace.x1),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PkRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(Icons.scale, size: 13, color: fg),
            const SizedBox(width: PkSpace.x1),
          ],
          Text(
            label,
            style: PkText.mono(size: 12, weight: weight, color: fg),
          ),
        ],
      ),
    );
  }
}
