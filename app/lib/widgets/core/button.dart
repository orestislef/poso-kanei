import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

enum PkButtonVariant { primary, secondary, ghost, deal, danger }

enum PkButtonSize { sm, md, lg }

/// Primary tappable action. Shows hover (web) + a press scale, honours
/// reduce-motion, and disables when [onPressed] is null.
class PkButton extends StatefulWidget {
  final String? label;
  final Widget? child;
  final PkButtonVariant variant;
  final PkButtonSize size;
  final bool block;
  final Widget? iconLeft;
  final Widget? iconRight;
  final VoidCallback? onPressed;

  const PkButton({
    super.key,
    this.label,
    this.child,
    this.variant = PkButtonVariant.primary,
    this.size = PkButtonSize.md,
    this.block = false,
    this.iconLeft,
    this.iconRight,
    this.onPressed,
  });

  @override
  State<PkButton> createState() => _PkButtonState();
}

class _PkButtonState extends State<PkButton> {
  bool _hovered = false;
  bool _pressed = false;

  double get _height => switch (widget.size) {
        PkButtonSize.sm => 34,
        PkButtonSize.md => 42,
        PkButtonSize.lg => 52,
      };

  double get _hPad => switch (widget.size) {
        PkButtonSize.sm => 12,
        PkButtonSize.md => 20,
        PkButtonSize.lg => 24,
      };

  double get _radius =>
      widget.size == PkButtonSize.lg ? PkRadius.lg : PkRadius.md;

  double get _fontSize => switch (widget.size) {
        PkButtonSize.sm => PkFont.sm,
        PkButtonSize.md => PkFont.base,
        PkButtonSize.lg => PkFont.md,
      };

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final enabled = widget.onPressed != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final ({Color bg, Color fg, Color hoverBg, Color activeBg, Color? border}) c =
        switch (widget.variant) {
      PkButtonVariant.primary => (
          bg: pk.primary,
          fg: pk.onPrimary,
          hoverBg: pk.primaryHover,
          activeBg: pk.primaryActive,
          border: null,
        ),
      PkButtonVariant.secondary => (
          bg: pk.surfaceRaised,
          fg: pk.textPrimary,
          hoverBg: pk.surfaceSunken,
          activeBg: pk.surfaceSunken,
          border: pk.borderDefault,
        ),
      PkButtonVariant.ghost => (
          bg: Colors.transparent,
          fg: pk.textPrimary,
          hoverBg: pk.surfaceSunken,
          activeBg: pk.surfaceSunken,
          border: null,
        ),
      PkButtonVariant.deal => (
          bg: pk.deal,
          fg: Colors.white,
          hoverBg: pk.dealHover,
          activeBg: pk.dealHover,
          border: null,
        ),
      PkButtonVariant.danger => (
          bg: pk.danger,
          fg: pk.onDanger,
          hoverBg: pk.dangerHover,
          activeBg: pk.dangerHover,
          border: null,
        ),
    };

    Color bg = c.bg;
    if (enabled && _pressed) {
      bg = c.activeBg;
    } else if (enabled && _hovered) {
      bg = c.hoverBg;
    }

    final label = widget.child ??
        Text(
          widget.label ?? '',
          style: PkText.label(
            size: _fontSize,
            weight: FontWeight.w600,
            color: c.fg,
          ),
        );

    final row = Row(
      mainAxisSize: widget.block ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.iconLeft != null) ...[
          IconTheme.merge(
            data: IconThemeData(color: c.fg, size: _fontSize + 3),
            child: widget.iconLeft!,
          ),
          const SizedBox(width: PkSpace.x2),
        ],
        Flexible(child: label),
        if (widget.iconRight != null) ...[
          const SizedBox(width: PkSpace.x2),
          IconTheme.merge(
            data: IconThemeData(color: c.fg, size: _fontSize + 3),
            child: widget.iconRight!,
          ),
        ],
      ],
    );

    final container = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : PkDur.fast,
      curve: PkCurve.standard,
      height: _height,
      width: widget.block ? double.infinity : null,
      padding: EdgeInsets.symmetric(horizontal: _hPad),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(_radius),
        border: c.border != null
            ? Border.all(color: c.border!, width: 1)
            : null,
      ),
      child: DefaultTextStyle.merge(
        style: TextStyle(color: c.fg),
        child: row,
      ),
    );

    final scaled = AnimatedScale(
      scale: enabled && _pressed ? 0.97 : 1.0,
      duration: reduceMotion ? Duration.zero : PkDur.fast,
      curve: PkCurve.standard,
      child: container,
    );

    return Opacity(
      opacity: enabled ? 1.0 : 0.5,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
        onExit: enabled ? (_) => setState(() => _hovered = false) : null,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
          onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
          onTapCancel:
              enabled ? () => setState(() => _pressed = false) : null,
          onTap: widget.onPressed,
          child: scaled,
        ),
      ),
    );
  }
}
