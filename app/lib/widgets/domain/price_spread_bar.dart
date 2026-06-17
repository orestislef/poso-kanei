import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// A min→avg→max price-spread visual: a save→amber→deal gradient track with an
/// animated average marker, plus three labelled values beneath.
class PriceSpreadBar extends StatefulWidget {
  final double min;
  final double avg;
  final double max;

  const PriceSpreadBar({
    super.key,
    required this.min,
    required this.avg,
    required this.max,
  });

  @override
  State<PriceSpreadBar> createState() => _PriceSpreadBarState();
}

class _PriceSpreadBarState extends State<PriceSpreadBar> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: PkDur.slower);
    _anim = CurvedAnimation(parent: _controller, curve: PkCurve.out);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    if (reduceMotion) {
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

  double get _avgPct {
    final range = widget.max - widget.min;
    if (range <= 0) return 0;
    final pct = (widget.avg - widget.min) / range * 100;
    return pct.clamp(0, 100);
  }

  static String _fmt(double v) {
    if (v.isNaN || v.isInfinite) return '—';
    return '€${v.toStringAsFixed(2)}';
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final pct = _avgPct / 100;

    const markerWidth = 2.5;
    const markerHeight = 14.0;
    const trackHeight = 8.0;

    final track = SizedBox(
      height: markerHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          return AnimatedBuilder(
            animation: _anim,
            builder: (context, child) {
              final targetX = pct * width;
              final markerX = targetX * _anim.value;
              final clampedLeft =
                  (markerX - markerWidth / 2).clamp(0.0, width - markerWidth);
              return Stack(
                children: [
                  Align(
                    alignment: Alignment.center,
                    child: Container(
                      height: trackHeight,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(PkRadius.pill),
                        gradient: LinearGradient(
                          colors: [pk.save, pk.spreadMid, pk.deal],
                          stops: const [0.0, 0.55, 1.0],
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: clampedLeft,
                    top: 0,
                    child: Container(
                      width: markerWidth,
                      height: markerHeight,
                      decoration: BoxDecoration(
                        color: pk.textPrimary,
                        borderRadius: BorderRadius.circular(PkRadius.pill),
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    Widget label(String value, String key, Color valueColor, CrossAxisAlignment align) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: align,
        children: [
          Text(
            value,
            style: PkText.heading(size: 13, weight: FontWeight.w700, color: valueColor),
          ),
          const SizedBox(height: 2),
          Text(
            key.toUpperCase(),
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

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        track,
        const SizedBox(height: PkSpace.x2),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            label(_fmt(widget.min), 'cheapest', pk.saveText, CrossAxisAlignment.start),
            label(_fmt(widget.avg), 'average', pk.textPrimary, CrossAxisAlignment.center),
            label(_fmt(widget.max), 'highest', pk.textPrimary, CrossAxisAlignment.end),
          ],
        ),
      ],
    );
  }
}
