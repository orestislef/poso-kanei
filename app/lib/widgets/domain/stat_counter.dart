import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

enum PkStatTone { normal, deal }

/// A big animated count-up number with a small uppercase label beneath, used
/// in stat strips ("12,480 products tracked").
class StatCounter extends StatefulWidget {
  final int value;
  final String label;
  final PkStatTone tone;
  final Duration duration;

  const StatCounter({
    super.key,
    required this.value,
    required this.label,
    this.tone = PkStatTone.normal,
    this.duration = const Duration(milliseconds: 800),
  });

  @override
  State<StatCounter> createState() => _StatCounterState();
}

class _StatCounterState extends State<StatCounter> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  static final NumberFormat _fmt = NumberFormat.decimalPattern('en_US');

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion || widget.duration == Duration.zero) {
      _controller.value = 1.0;
    } else if (_controller.status == AnimationStatus.dismissed) {
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final valueColor = widget.tone == PkStatTone.deal ? pk.dealText : pk.textPrimary;

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            final t = _controller.value;
            final eased = 1 - ((1 - t) * (1 - t) * (1 - t));
            final current = (widget.value * eased).round();
            return Text(
              _fmt.format(current),
              style: PkText.price(
                size: PkFont.xl3,
                weight: FontWeight.w800,
                color: valueColor,
              ),
            );
          },
        ),
        const SizedBox(height: PkSpace.x1),
        Text(
          widget.label.toUpperCase(),
          style: PkText.mono(
            size: 11,
            weight: FontWeight.w500,
            tracking: 0.12,
            color: pk.textMuted,
          ),
        ),
      ],
    );
  }
}
