import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Inline "as of {date}" stamp with a clock glyph. Goes amber/bold once the
/// data is older than [staleDays].
class FreshnessBadge extends StatelessWidget {
  final DateTime? date;
  final int staleDays;

  const FreshnessBadge({
    super.key,
    this.date,
    this.staleDays = 7,
  });

  static const List<String> _months = [
    'Ιαν', 'Φεβ', 'Μαρ', 'Απρ', 'Μαΐ', 'Ιουν',
    'Ιουλ', 'Αυγ', 'Σεπ', 'Οκτ', 'Νοε', 'Δεκ',
  ];

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final date = this.date;

    String label;
    bool stale = false;

    if (date == null) {
      label = 'άγνωστη ημ/νία';
    } else {
      final now = DateTime.now();
      final ageDays = now.difference(date).inDays;
      stale = ageDays > staleDays;
      label = '${date.day} ${_months[date.month - 1]}';
    }

    final color = stale ? pk.warningText : pk.textMuted;
    final weight = stale ? FontWeight.w600 : FontWeight.w500;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(Icons.schedule, size: 12, color: color),
        const SizedBox(width: 5),
        Text(
          label,
          style: PkText.mono(size: 11, weight: weight, color: color),
        ),
      ],
    );
  }
}
