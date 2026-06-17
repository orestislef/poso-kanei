import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../i18n/strings.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';
import 'deal_badge.dart';
import 'price_display.dart';
import 'unit_price_tag.dart';

/// The primary product tile: square media with a deal overlay, then brand /
/// name / price / unit-price + store-count footer. Lifts on hover.
class ProductCard extends StatefulWidget {
  final String name;
  final String? brand;
  final String? packSize;
  final String? imageUrl;
  final String? emoji;
  final double price;
  final double unitPrice;
  final String unit;
  final int? storeCount;
  final num? discountPct;
  final VoidCallback? onTap;
  final String? heroTag;

  const ProductCard({
    super.key,
    required this.name,
    this.brand,
    this.packSize,
    this.imageUrl,
    this.emoji,
    required this.price,
    required this.unitPrice,
    this.unit = 'kg',
    this.storeCount,
    this.discountPct,
    this.onTap,
    this.heroTag,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
    final reduceMotion = MediaQuery.of(context).disableAnimations;

    Widget media;
    if (widget.imageUrl != null) {
      Widget image = CachedNetworkImage(
        imageUrl: widget.imageUrl!,
        fit: BoxFit.contain,
        placeholder: (context, url) => const SizedBox.shrink(),
        errorWidget: (context, url, error) =>
            Icon(Icons.shopping_basket_outlined, size: 46, color: pk.borderStrong),
      );
      image = Padding(padding: const EdgeInsets.all(PkSpace.x4), child: image);
      media = widget.heroTag != null ? Hero(tag: widget.heroTag!, child: image) : image;
    } else if (widget.emoji != null) {
      media = Text(widget.emoji!, style: const TextStyle(fontSize: 64));
    } else {
      media = Icon(Icons.shopping_basket_outlined, size: 46, color: pk.borderStrong);
    }

    final mediaBox = AspectRatio(
      aspectRatio: 1,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            color: pk.surfaceSunken,
            alignment: Alignment.center,
            child: media,
          ),
          if (widget.discountPct != null)
            Positioned(
              top: PkSpace.x2,
              left: PkSpace.x2,
              child: DealBadge(percentage: widget.discountPct),
            ),
        ],
      ),
    );

    final brand = widget.brand;
    final body = Padding(
      padding: const EdgeInsets.fromLTRB(PkSpace.x3, PkSpace.x3, PkSpace.x3, PkSpace.x4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (brand != null) ...[
            Text(
              widget.packSize != null ? '$brand · ${widget.packSize}' : brand,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: PkText.mono(
                size: 11,
                weight: FontWeight.w500,
                tracking: 0.04,
                color: pk.textMuted,
              ),
            ),
            const SizedBox(height: PkSpace.x1),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 13 * 1.3 * 2),
            child: Text(
              widget.name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: PkText.label(
                size: PkFont.sm,
                weight: FontWeight.w600,
                color: pk.textPrimary,
              ),
            ),
          ),
          const SizedBox(height: PkSpace.x2),
          PriceDisplay(amount: widget.price, size: PkPriceSize.md, showFrom: true),
          const SizedBox(height: PkSpace.x2),
          Row(
            children: [
              UnitPriceTag(
                value: widget.unitPrice,
                unit: widget.unit,
                best: true,
                showIcon: false,
              ),
              if (widget.storeCount != null) ...[
                const SizedBox(width: PkSpace.x2),
                Flexible(
                  child: Text(
                    '· ${t.storeCountLabel(widget.storeCount!)}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: PkText.mono(size: 11, color: pk.textSecondary),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

    final card = AnimatedContainer(
      duration: reduceMotion ? Duration.zero : PkDur.base,
      curve: PkCurve.standard,
      transform: Matrix4.translationValues(0, _hovered ? -2 : 0, 0),
      decoration: BoxDecoration(
        color: pk.surfaceRaised,
        borderRadius: BorderRadius.circular(PkRadius.card),
        border: Border.all(color: pk.borderSubtle, width: 1),
        boxShadow: _hovered ? pk.shadowMd : pk.shadowSm,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(PkRadius.card),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [mediaBox, body],
        ),
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
