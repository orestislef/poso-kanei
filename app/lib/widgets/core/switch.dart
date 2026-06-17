import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// On/off toggle with a springy thumb and an optional trailing [label].
class PkSwitch extends StatelessWidget {
  final String? label;
  final bool value;
  final ValueChanged<bool>? onChanged;

  const PkSwitch({
    super.key,
    this.label,
    required this.value,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final enabled = onChanged != null;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    final track = SizedBox(
      width: 42,
      height: 24,
      child: AnimatedContainer(
        duration: reduceMotion ? Duration.zero : PkDur.base,
        curve: PkCurve.spring,
        decoration: BoxDecoration(
          color: value ? pk.primary : pk.borderStrong,
          borderRadius: BorderRadius.circular(PkRadius.pill),
        ),
        child: Stack(
          children: [
            AnimatedPositioned(
              duration: reduceMotion ? Duration.zero : PkDur.base,
              curve: PkCurve.spring,
              top: 2,
              left: value ? 20 : 2,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: pk.shadowSm,
                ),
              ),
            ),
          ],
        ),
      ),
    );

    return Semantics(
      toggled: value,
      enabled: enabled,
      child: MouseRegion(
        cursor: enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: enabled ? () => onChanged!(!value) : null,
          child: Opacity(
            opacity: enabled ? 1.0 : 0.5,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                track,
                if (label != null) ...[
                  const SizedBox(width: PkSpace.x2_5),
                  Text(
                    label!,
                    style: PkText.body(
                      size: PkFont.base,
                      color: pk.textPrimary,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
