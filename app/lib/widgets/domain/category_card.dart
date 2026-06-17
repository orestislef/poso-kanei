import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// A tappable category tile: a 4:3 media box (image / emoji / placeholder),
/// the category name, and an optional product count. Lifts on hover.
class CategoryCard extends StatefulWidget {
  final String name;
  final int? count;
  final String? imageUrl;
  final String? emoji;
  final VoidCallback? onTap;

  const CategoryCard({
    super.key,
    required this.name,
    this.count,
    this.imageUrl,
    this.emoji,
    this.onTap,
  });

  @override
  State<CategoryCard> createState() => _CategoryCardState();
}

class _CategoryCardState extends State<CategoryCard> {
  bool _hovered = false;
  static final NumberFormat _fmt = NumberFormat.decimalPattern('en_US');

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget media;
    if (widget.imageUrl != null) {
      media = CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        placeholder: (context, url) => const SizedBox.shrink(),
        errorWidget: (context, url, error) =>
            Icon(Icons.shopping_basket_outlined, size: 40, color: pk.borderStrong),
      );
    } else if (widget.emoji != null) {
      media = Text(widget.emoji!, style: const TextStyle(fontSize: 40));
    } else {
      media = Icon(Icons.shopping_basket_outlined, size: 40, color: pk.borderStrong);
    }

    final card = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : PkDur.base,
      curve: PkCurve.standard,
      transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
      padding: const EdgeInsets.all(PkSpace.x3),
      decoration: BoxDecoration(
        color: pk.surfaceRaised,
        borderRadius: BorderRadius.circular(PkRadius.card),
        border: Border.all(color: pk.borderSubtle, width: 1),
        boxShadow: _hovered ? pk.shadowMd : pk.shadowXs,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 4 / 3,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(PkRadius.md),
              child: Container(
                color: pk.surfaceSunken,
                alignment: Alignment.center,
                child: media,
              ),
            ),
          ),
          const SizedBox(height: PkSpace.x2),
          Text(
            widget.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: PkText.heading(
              size: PkFont.base,
              weight: FontWeight.w700,
              color: pk.textPrimary,
            ),
          ),
          if (widget.count != null) ...[
            const SizedBox(height: PkSpace.x2),
            Text(
              '${_fmt.format(widget.count)} products',
              style: PkText.mono(size: 11, color: pk.textMuted),
            ),
          ],
        ],
      ),
    );

    return MouseRegion(
      cursor: widget.onTap != null ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: card,
      ),
    );
  }
}
