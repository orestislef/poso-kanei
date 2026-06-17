import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

enum PkInputSize { md, lg }

/// Text input with label / hint / error rows, leading & trailing icons, and a
/// focus glow. Pass either a [controller] or a [value]/[onChanged] pair.
class PkInput extends StatefulWidget {
  final TextEditingController? controller;
  final String? value;
  final ValueChanged<String>? onChanged;
  final String? placeholder;
  final String? label;
  final String? hint;
  final String? error;
  final PkInputSize size;
  final Widget? iconLeft;
  final Widget? iconRight;
  final VoidCallback? onTap;
  final ValueChanged<String>? onSubmitted;
  final bool autofocus;
  final bool readOnly;

  const PkInput({
    super.key,
    this.controller,
    this.value,
    this.onChanged,
    this.placeholder,
    this.label,
    this.hint,
    this.error,
    this.size = PkInputSize.md,
    this.iconLeft,
    this.iconRight,
    this.onTap,
    this.onSubmitted,
    this.autofocus = false,
    this.readOnly = false,
  });

  @override
  State<PkInput> createState() => _PkInputState();
}

class _PkInputState extends State<PkInput> {
  TextEditingController? _internalController;
  late final FocusNode _focusNode;
  bool _focused = false;

  TextEditingController get _controller =>
      widget.controller ?? _internalController!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internalController = TextEditingController(text: widget.value ?? '');
    }
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(covariant PkInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Keep the internal controller synced to an externally supplied [value].
    if (widget.controller == null &&
        widget.value != null &&
        widget.value != _internalController!.text) {
      final v = widget.value!;
      _internalController!.value = _internalController!.value.copyWith(
        text: v,
        selection: TextSelection.collapsed(offset: v.length),
        composing: TextRange.empty,
      );
    }
  }

  void _onFocusChange() {
    if (_focused != _focusNode.hasFocus) {
      setState(() => _focused = _focusNode.hasFocus);
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChange);
    _focusNode.dispose();
    _internalController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    final isLg = widget.size == PkInputSize.lg;
    final hasError = widget.error != null;

    final fontSize = isLg ? PkFont.md : PkFont.base;
    final height = isLg ? 52.0 : 44.0;
    final hPad = isLg ? PkSpace.x4 : PkSpace.x3;
    final radius = isLg ? PkRadius.lg : PkRadius.md;

    Color borderColor;
    if (hasError) {
      borderColor = pk.danger;
    } else if (_focused) {
      borderColor = pk.primary;
    } else {
      borderColor = pk.borderDefault;
    }

    final field = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : PkDur.fast,
      curve: PkCurve.standard,
      height: height,
      padding: EdgeInsets.symmetric(horizontal: hPad),
      decoration: BoxDecoration(
        color: pk.surfaceRaised,
        borderRadius: BorderRadius.circular(radius),
        border: Border.all(color: borderColor, width: 1),
        boxShadow: _focused && !hasError
            ? [
                BoxShadow(
                  color: pk.primary.withValues(alpha: 0.30),
                  blurRadius: 0,
                  spreadRadius: 3,
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          if (widget.iconLeft != null) ...[
            IconTheme.merge(
              data: IconThemeData(color: pk.textMuted, size: fontSize + 3),
              child: widget.iconLeft!,
            ),
            const SizedBox(width: PkSpace.x2),
          ],
          Expanded(
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              autofocus: widget.autofocus,
              readOnly: widget.readOnly,
              onTap: widget.onTap,
              onChanged: widget.onChanged,
              onSubmitted: widget.onSubmitted,
              cursorColor: pk.primary,
              style: PkText.body(size: fontSize, color: pk.textPrimary),
              decoration: InputDecoration.collapsed(
                hintText: widget.placeholder,
                hintStyle: PkText.body(size: fontSize, color: pk.textMuted),
              ).copyWith(
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
          if (widget.iconRight != null) ...[
            const SizedBox(width: PkSpace.x2),
            IconTheme.merge(
              data: IconThemeData(color: pk.textMuted, size: fontSize + 3),
              child: widget.iconRight!,
            ),
          ],
        ],
      ),
    );

    final messageText = widget.error ?? widget.hint;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label != null) ...[
          Text(
            widget.label!,
            style: PkText.label(
              size: PkFont.sm,
              weight: FontWeight.w600,
              color: pk.textPrimary,
            ),
          ),
          const SizedBox(height: PkSpace.x1_5),
        ],
        field,
        if (messageText != null) ...[
          const SizedBox(height: PkSpace.x1_5),
          Text(
            messageText,
            style: PkText.body(
              size: PkFont.xs,
              color: hasError ? pk.danger : pk.textMuted,
            ),
          ),
        ],
      ],
    );
  }
}
