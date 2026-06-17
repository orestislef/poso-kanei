import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

enum PkPriceSize { sm, md, lg, xl }

enum PkPriceTone { normal, save, deal }

/// The headline price for a product, with an optional `from` eyebrow and a
/// secondary per-unit price. Numbers are tabular (via [PkText.price]) so they
/// line up across cards.
class PriceDisplay extends StatelessWidget {
  final double amount;
  final double? unitPrice;
  final String unit;
  final bool showFrom;
  final PkPriceSize size;
  final PkPriceTone tone;

  const PriceDisplay({
    super.key,
    required this.amount,
    this.unitPrice,
    this.unit = 'kg',
    this.showFrom = false,
    this.size = PkPriceSize.md,
    this.tone = PkPriceTone.normal,
  });

  double get _amountSize => switch (size) {
        PkPriceSize.sm => 18,
        PkPriceSize.md => 28,
        PkPriceSize.lg => 48,
        PkPriceSize.xl => 60,
      };

  double get _unitSize => switch (size) {
        PkPriceSize.sm => 11,
        PkPriceSize.md => 12,
        PkPriceSize.lg => 13,
        PkPriceSize.xl => 15,
      };

  static String _fmt(double? v) {
    if (v == null || v.isNaN || v.isInfinite) return '—';
    return v.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;

    final amountColor = switch (tone) {
      PkPriceTone.normal => pk.textPrimary,
      PkPriceTone.save => pk.saveText,
      PkPriceTone.deal => pk.dealText,
    };

    final amountText = _fmt(amount);
    final isPlaceholder = amountText == '—';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (showFrom) ...[
          Text(
            'FROM',
            style: PkText.mono(
              size: 11,
              weight: FontWeight.w500,
              tracking: 0.12,
              color: pk.textMuted,
            ),
          ),
          const SizedBox(height: 2),
        ],
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              '€',
              style: PkText.price(
                size: _amountSize,
                weight: FontWeight.w700,
                color: amountColor,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              isPlaceholder ? '—' : amountText,
              style: PkText.price(size: _amountSize, color: amountColor),
            ),
          ],
        ),
        if (unitPrice != null) ...[
          const SizedBox(height: 2),
          Text(
            '€${_fmt(unitPrice)}/$unit',
            style: PkText.mono(size: _unitSize, color: pk.textSecondary),
          ),
        ],
      ],
    );
  }
}
