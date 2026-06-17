import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// One choice within a [PkSegmentedControl].
class PkSegment<T> {
  final T value;
  final String label;
  final Widget? icon;
  const PkSegment(this.value, this.label, {this.icon});
}

/// Inset pill-track segmented control. The active option floats on a raised
/// surface with the brand color.
class PkSegmentedControl<T> extends StatelessWidget {
  final List<PkSegment<T>> options;
  final T value;
  final ValueChanged<T> onChanged;
  final bool block;

  const PkSegmentedControl({
    super.key,
    required this.options,
    required this.value,
    required this.onChanged,
    this.block = false,
  });

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;

    final children = <Widget>[];
    for (var i = 0; i < options.length; i++) {
      if (i > 0) children.add(const SizedBox(width: PkSpace.x1 / 2));
      final option = _PkSegmentButton<T>(
        segment: options[i],
        active: options[i].value == value,
        onTap: () => onChanged(options[i].value),
      );
      children.add(block ? Expanded(child: option) : option);
    }

    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        color: pk.surfaceSunken,
        borderRadius: BorderRadius.circular(PkRadius.md),
        border: Border.all(color: pk.borderSubtle, width: 1),
      ),
      child: Row(
        mainAxisSize: block ? MainAxisSize.max : MainAxisSize.min,
        children: children,
      ),
    );
  }
}

class _PkSegmentButton<T> extends StatelessWidget {
  final PkSegment<T> segment;
  final bool active;
  final VoidCallback onTap;

  const _PkSegmentButton({
    required this.segment,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final fg = active ? pk.primary : pk.textSecondary;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: reduceMotion ? Duration.zero : PkDur.fast,
          curve: PkCurve.standard,
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 7,
          ),
          decoration: BoxDecoration(
            color: active ? pk.surfaceRaised : Colors.transparent,
            borderRadius: BorderRadius.circular(PkRadius.sm),
            boxShadow: active ? pk.shadowXs : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (segment.icon != null) ...[
                IconTheme.merge(
                  data: IconThemeData(color: fg, size: PkFont.md),
                  child: segment.icon!,
                ),
                const SizedBox(width: PkSpace.x1_5),
              ],
              Text(
                segment.label,
                style: PkText.label(
                  size: PkFont.sm,
                  weight: FontWeight.w600,
                  color: fg,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
