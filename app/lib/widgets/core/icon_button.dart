import 'package:flutter/material.dart';

import '../../theme/tokens.dart';

enum PkIconButtonSize { sm, md, lg }

/// Square, icon-only tappable. Hover tint, press scale, and three accent
/// states ([solid], [active], [dealActive]).
class PkIconButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final PkIconButtonSize size;
  final bool solid;
  final bool active;
  final bool dealActive;
  final String? semanticLabel;

  const PkIconButton({
    super.key,
    required this.child,
    this.onPressed,
    this.size = PkIconButtonSize.md,
    this.solid = false,
    this.active = false,
    this.dealActive = false,
    this.semanticLabel,
  });

  @override
  State<PkIconButton> createState() => _PkIconButtonState();
}

class _PkIconButtonState extends State<PkIconButton> {
  bool _hovered = false;
  bool _pressed = false;

  double get _side => switch (widget.size) {
        PkIconButtonSize.sm => 32,
        PkIconButtonSize.md => 40,
        PkIconButtonSize.lg => 48,
      };

  double get _iconSize => switch (widget.size) {
        PkIconButtonSize.sm => 16,
        PkIconButtonSize.md => 20,
        PkIconButtonSize.lg => 24,
      };

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final enabled = widget.onPressed != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Color bg;
    Color fg;
    Color? border;

    if (widget.dealActive) {
      bg = pk.dealSoft;
      fg = pk.deal;
      border = null;
    } else if (widget.active) {
      bg = pk.primarySoft;
      fg = pk.primary;
      border = null;
    } else if (widget.solid) {
      bg = pk.surfaceRaised;
      fg = pk.textSecondary;
      border = pk.borderDefault;
    } else {
      bg = Colors.transparent;
      fg = pk.textSecondary;
      border = null;
    }

    // Hover applies to the neutral / default treatment only.
    if (enabled && _hovered && !widget.active && !widget.dealActive) {
      bg = pk.surfaceSunken;
      fg = pk.textPrimary;
    }

    final box = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : PkDur.fast,
      curve: PkCurve.standard,
      width: _side,
      height: _side,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(PkRadius.md),
        border: border != null ? Border.all(color: border, width: 1) : null,
      ),
      child: IconTheme.merge(
        data: IconThemeData(color: fg, size: _iconSize),
        child: widget.child,
      ),
    );

    final scaled = AnimatedScale(
      scale: enabled && _pressed ? 0.92 : 1.0,
      duration: reduceMotion ? Duration.zero : PkDur.fast,
      curve: PkCurve.standard,
      child: box,
    );

    Widget result = MouseRegion(
      cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: enabled ? (_) => setState(() => _hovered = true) : null,
      onExit: enabled ? (_) => setState(() => _hovered = false) : null,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapDown: enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: enabled ? (_) => setState(() => _pressed = false) : null,
        onTapCancel: enabled ? () => setState(() => _pressed = false) : null,
        onTap: widget.onPressed,
        child: Opacity(opacity: enabled ? 1.0 : 0.5, child: scaled),
      ),
    );

    if (widget.semanticLabel != null) {
      result = Semantics(
        button: true,
        label: widget.semanticLabel,
        child: result,
      );
    }

    return result;
  }
}
