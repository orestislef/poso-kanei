import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

enum PkSkeletonVariant { rect, text, circle, card }

/// Loading placeholder with a left-to-right shimmer sweep. Falls back to a
/// static fill when the platform requests reduced motion.
class PkSkeleton extends StatefulWidget {
  final double? width;
  final double? height;
  final PkSkeletonVariant variant;
  final double? radius;

  const PkSkeleton({
    super.key,
    this.width,
    this.height,
    this.variant = PkSkeletonVariant.rect,
    this.radius,
  });

  @override
  State<PkSkeleton> createState() => _PkSkeletonState();
}

class _PkSkeletonState extends State<PkSkeleton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  double get _resolvedRadius {
    if (widget.radius != null) return widget.radius!;
    return switch (widget.variant) {
      PkSkeletonVariant.rect => PkRadius.sm,
      PkSkeletonVariant.text => PkRadius.xs,
      PkSkeletonVariant.circle => PkRadius.pill,
      PkSkeletonVariant.card => PkRadius.card,
    };
  }

  double? get _resolvedHeight {
    if (widget.height != null) return widget.height;
    if (widget.variant == PkSkeletonVariant.text) return 12;
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isCircle = widget.variant == PkSkeletonVariant.circle;

    final BorderRadius? borderRadius =
        isCircle ? null : BorderRadius.circular(_resolvedRadius);

    if (reduceMotion) {
      return Container(
        width: widget.width,
        height: _resolvedHeight,
        decoration: BoxDecoration(
          color: pk.skeletonBase,
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: borderRadius,
        ),
      );
    }

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        final t = _controller.value;
        // Sweep the sheen band across the full width (left → right).
        final begin = Alignment(-3.0 + t * 4.0, 0);
        final end = Alignment(begin.x + 2.0, 0);
        return Container(
          width: widget.width,
          height: _resolvedHeight,
          decoration: BoxDecoration(
            shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
            borderRadius: borderRadius,
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [
                pk.skeletonBase,
                pk.skeletonSheen,
                pk.skeletonBase,
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
        );
      },
    );
  }
}
