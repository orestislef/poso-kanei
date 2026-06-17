import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

/// Raised surface container. When [onTap] is provided it becomes an InkWell
/// with a matching ripple clip.
class PkCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final double radius;
  final VoidCallback? onTap;

  const PkCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.radius = 16,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final borderRadius = BorderRadius.circular(radius);

    final decoration = BoxDecoration(
      color: pk.surfaceRaised,
      borderRadius: borderRadius,
      border: Border.all(color: pk.borderSubtle, width: 1),
      boxShadow: pk.shadowSm,
    );

    if (onTap == null) {
      return Container(
        margin: margin,
        padding: padding,
        decoration: decoration,
        child: child,
      );
    }

    return Container(
      margin: margin,
      decoration: decoration,
      child: Material(
        type: MaterialType.transparency,
        borderRadius: borderRadius,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          borderRadius: borderRadius,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
