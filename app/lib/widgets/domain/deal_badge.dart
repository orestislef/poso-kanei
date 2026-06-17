import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Discount pill: a down-chevron plus a percentage (e.g. `−18%`). Supports a
/// solid (default), soft, and "real price drop" treatment, plus an optional
/// gentle pulse loop.
class DealBadge extends StatefulWidget {
  final num? percentage;
  final bool soft;
  final bool pulse;
  final bool realDrop;
  final String? label;

  const DealBadge({
    super.key,
    this.percentage,
    this.soft = false,
    this.pulse = false,
    this.realDrop = false,
    this.label,
  });

  @override
  State<DealBadge> createState() => _DealBadgeState();
}

class _DealBadgeState extends State<DealBadge> with SingleTickerProviderStateMixin {
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (widget.pulse) {
      _controller = AnimationController(
        vsync: this,
        duration: const Duration(milliseconds: 1600),
      );
    }
  }

  void _syncPulse() {
    final controller = _controller;
    if (controller == null) return;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (widget.pulse && !reduceMotion) {
      if (!controller.isAnimating) controller.repeat(reverse: true);
    } else {
      if (controller.isAnimating) controller.stop();
      controller.value = 0;
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String get _text {
    if (widget.label != null) return widget.label!;
    final pct = widget.percentage ?? 0;
    return '−${pct.round().abs()}%';
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;

    // Hide a meaningless "−0%": a rounded-to-zero discount is not a deal.
    if (widget.label == null &&
        (widget.percentage == null || widget.percentage!.round().abs() == 0)) {
      return const SizedBox.shrink();
    }
    _syncPulse();

    final ({Color bg, Color fg, Color? border}) c;
    if (widget.realDrop) {
      c = (bg: pk.save, fg: Colors.white, border: null);
    } else if (widget.soft) {
      c = (bg: pk.dealSoft, fg: pk.dealText, border: pk.dealSoftBorder);
    } else {
      c = (bg: pk.deal, fg: Colors.white, border: null);
    }

    final pill = Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: c.bg,
        borderRadius: BorderRadius.circular(PkRadius.pill),
        border: c.border != null ? Border.all(color: c.border!, width: 1) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.keyboard_arrow_down, size: 13, color: c.fg),
          const SizedBox(width: PkSpace.x1),
          Text(
            _text,
            style: PkText.mono(size: 12, weight: FontWeight.w600, color: c.fg),
          ),
        ],
      ),
    );

    final controller = _controller;
    if (controller == null) return pill;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final scale = 1.0 + 0.06 * controller.value;
        return Transform.scale(scale: scale, child: child);
      },
      child: pill,
    );
  }
}
