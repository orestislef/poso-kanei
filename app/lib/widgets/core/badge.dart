import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

enum PkBadgeTone { neutral, save, deal, stale, info, solidDeal, solidSave }

/// Small uppercase mono pill used for savings, deals, freshness, etc.
class PkBadge extends StatelessWidget {
  final String label;
  final PkBadgeTone tone;
  final bool large;
  final Widget? icon;

  const PkBadge({
    super.key,
    required this.label,
    this.tone = PkBadgeTone.neutral,
    this.large = false,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;

    final ({Color bg, Color fg, Color border}) c = switch (tone) {
      PkBadgeTone.neutral => (
          bg: pk.surfaceSunken,
          fg: pk.textSecondary,
          border: Colors.transparent,
        ),
      PkBadgeTone.save => (
          bg: pk.saveSoft,
          fg: pk.saveText,
          border: Colors.transparent,
        ),
      PkBadgeTone.deal => (
          bg: pk.dealSoft,
          fg: pk.dealText,
          border: pk.dealSoftBorder,
        ),
      PkBadgeTone.stale => (
          bg: pk.warningSoft,
          fg: pk.warningText,
          border: Colors.transparent,
        ),
      PkBadgeTone.info => (
          bg: pk.infoSoft,
          fg: pk.infoText,
          border: Colors.transparent,
        ),
      PkBadgeTone.solidDeal => (
          bg: pk.deal,
          fg: Colors.white,
          border: Colors.transparent,
        ),
      PkBadgeTone.solidSave => (
          bg: pk.save,
          fg: Colors.white,
          border: Colors.transparent,
        ),
    };

    final fontSize = large ? PkFont.xs : PkFont.xs2;

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: large ? PkSpace.x2_5 : PkSpace.x2,
        vertical: large ? 5 : PkSpace.x1,
      ),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(PkRadius.pill),
        border: Border.all(color: c.border, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: c.fg, size: fontSize + 1),
              child: icon!,
            ),
            const SizedBox(width: PkSpace.x1),
          ],
          Text(
            label.toUpperCase(),
            style: PkText.mono(
              size: fontSize,
              weight: FontWeight.w600,
              tracking: 0.02,
              color: c.fg,
            ),
          ),
        ],
      ),
    );
  }
}
