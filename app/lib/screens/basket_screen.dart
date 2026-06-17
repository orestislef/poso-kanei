import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/images.dart';
import '../i18n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/core.dart';
import '../widgets/domain.dart';
import 'nav.dart';
import 'shared.dart';

/// Basket: line items (each from a chosen store) + a "what to buy where" plan.
class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  String money(double v) => '€${v.toStringAsFixed(2)}';

  String _storeName(String? slug) =>
      slug == null ? '—' : (kRetailers[slug]?.name ?? slug);

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final t = context.t;
    final items = app.basket;

    if (items.isEmpty) {
      return PageScaffold(
        child: PkEmptyView(
          big: true,
          icon: Icons.shopping_basket_outlined,
          title: t.basketEmptyTitle,
          message: t.basketEmptyBody,
          action: PkButton(
            label: t.startList,
            iconLeft: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
            onPressed: () => PkNavScope.of(context).goTab(PkTab.home),
          ),
        ),
      );
    }

    final content = _content(context, app, items);
    final summary = _summary(context, app, items);

    return PageScaffold(
      child: pkIsDesktop(context)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                const SizedBox(width: 28),
                SizedBox(width: PkLayout.railBasket, child: summary),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [content, const SizedBox(height: 24), summary],
            ),
    );
  }

  // ── Line items ────────────────────────────────────────────────────────────
  Widget _content(BuildContext context, PkAppState app, List<BasketItem> items) {
    final pk = context.pk;
    final t = context.t;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(t.yourBasket,
                style: PkText.display(size: 30, weight: FontWeight.w800, color: pk.textPrimary)),
            const SizedBox(width: 10),
            Text(t.productCount(items.length),
                style: PkText.mono(size: 14, color: pk.textMuted)),
          ],
        ),
        const SizedBox(height: 16),
        PkCard(
          padding: EdgeInsets.zero,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var i = 0; i < items.length; i++)
                _lineItem(context, app, items[i], last: i == items.length - 1),
            ],
          ),
        ),
      ],
    );
  }

  Widget _lineItem(BuildContext context, PkAppState app, BasketItem it, {required bool last}) {
    final pk = context.pk;
    final t = context.t;
    final p = it.product;
    final slug = it.effectiveStore;
    final pack = pkPackLabel(p);

    final brand = p.brand;
    final metaParts = <String>[
      if (brand != null && brand.isNotEmpty) brand,
      ?pack,
    ];

    final imageUrl = p.hasImage ? PkImages.display(p.imageUrl) : null;
    final Widget thumb = (imageUrl != null && imageUrl.isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: imageUrl,
            fit: BoxFit.contain,
            placeholder: (_, _) => Icon(Icons.shopping_basket_outlined, size: 20, color: pk.textMuted),
            errorWidget: (_, _, _) => Icon(Icons.shopping_basket_outlined, size: 20, color: pk.textMuted),
          )
        : Icon(Icons.shopping_basket_outlined, size: 20, color: pk.textMuted);

    final cheaper = it.hasCheaperElsewhere ? it.cheapestPrice : null;

    return InkWell(
      onTap: () => PkNavScope.of(context).openProduct(p),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          border: last ? null : Border(bottom: BorderSide(color: pk.borderSubtle)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  width: 48,
                  child: Center(
                    child: Container(
                      width: 44,
                      height: 44,
                      alignment: Alignment.center,
                      padding: const EdgeInsets.all(5),
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                        color: pk.surfaceSunken,
                        borderRadius: BorderRadius.circular(PkRadius.md),
                      ),
                      child: thumb,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.name,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: PkText.label(size: 15, weight: FontWeight.w600, color: pk.textPrimary),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 6,
                        runSpacing: 4,
                        children: [
                          Text(
                            metaParts.isEmpty ? t.cheapestAt : '${metaParts.join(' · ')} · ${t.cheapestAt}',
                            style: PkText.mono(size: 12, color: pk.textMuted),
                          ),
                          if (slug != null)
                            StoreChip(slug: slug, size: PkStoreChipSize.sm, showName: true),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                PriceDisplay(
                  amount: it.price,
                  unitPrice: p.priceStats?.minUnitPrice,
                  unit: p.unit ?? 'kg',
                  size: PkPriceSize.sm,
                ),
                const SizedBox(width: 8),
                _RemoveButton(onTap: () => app.removeFromBasket(p.id)),
              ],
            ),
            if (cheaper != null) ...[
              const SizedBox(height: 8),
              GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: () => app.setStore(p, cheaper.retailer),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                  margin: const EdgeInsets.only(left: 48),
                  decoration: BoxDecoration(
                    color: pk.saveSoft,
                    borderRadius: BorderRadius.circular(PkRadius.sm),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.savings_outlined, size: 14, color: pk.saveText),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          t.cheaperAt(_storeName(cheaper.retailer), money(cheaper.price)),
                          style: PkText.mono(size: 12, weight: FontWeight.w600, color: pk.saveText),
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 13, color: pk.saveText),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // ── Summary / "what to buy where" ───────────────────────────────────────────
  Widget _summary(BuildContext context, PkAppState app, List<BasketItem> items) {
    final pk = context.pk;
    final t = context.t;

    final yourTotal = items.fold<double>(0, (s, it) => s + it.price);
    final cheapestTotal = items.fold<double>(
        0, (s, it) => s + (it.cheapestPrice?.price ?? it.product.minPrice ?? 0));
    final avgTotal = items.fold<double>(
        0, (s, it) => s + (it.product.priceStats?.avgPrice ?? it.product.minPrice ?? 0));
    final savingVsAvg = avgTotal - yourTotal;
    final potentialExtra = yourTotal - cheapestTotal;

    // Group by the store each item will be bought from.
    final groups = <String?, List<BasketItem>>{};
    for (final it in items) {
      groups.putIfAbsent(it.effectiveStore, () => []).add(it);
    }
    final entries = groups.entries.toList();

    return PkCard(
      radius: PkRadius.xl,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(t.optimizerTag, style: PkText.eyebrow(size: 12, color: pk.dealText)),
          const SizedBox(height: 14),
          Text(t.optimizerTitle,
              style: PkText.display(size: 20, weight: FontWeight.w800, color: pk.textPrimary)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: pk.borderSubtle),
                bottom: BorderSide(color: pk.borderSubtle),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(t.yourTotalLabel, style: PkText.mono(size: 11, color: pk.textMuted)),
                    const SizedBox(height: 6),
                    PriceDisplay(amount: yourTotal, size: PkPriceSize.lg, tone: PkPriceTone.save),
                  ],
                ),
                const SizedBox(width: 12),
                if (savingVsAvg > 0.01)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(t.vsAvg(money(avgTotal)), style: PkText.mono(size: 12, color: pk.textMuted)),
                      const SizedBox(height: 6),
                      Text(t.youSave(money(savingVsAvg)),
                          style: PkText.display(size: 18, weight: FontWeight.w800, color: pk.saveText)),
                    ],
                  ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.map_outlined, size: 15, color: pk.textSecondary),
              const SizedBox(width: 6),
              Text(t.whatToBuyWhere,
                  style: PkText.label(size: 14, weight: FontWeight.w700, color: pk.textPrimary)),
              const Spacer(),
              Text(t.stops(entries.length), style: PkText.mono(size: 12, color: pk.textMuted)),
            ],
          ),
          const SizedBox(height: 12),
          for (var gi = 0; gi < entries.length; gi++)
            _storeGroup(context, entries[gi].key, entries[gi].value,
                last: gi == entries.length - 1),
          if (potentialExtra > 0.01) ...[
            const SizedBox(height: 12),
            PkButton(
              block: true,
              variant: PkButtonVariant.secondary,
              label: '${t.allCheapest} · −${money(potentialExtra)}',
              iconLeft: const Icon(Icons.bolt, size: 18),
              onPressed: () {
                for (final it in items) {
                  app.setStore(it.product, null); // null → cheapest
                }
              },
            ),
          ],
          const SizedBox(height: 12),
          PkButton(
            block: true,
            size: PkButtonSize.lg,
            label: t.copyList,
            iconRight: const Icon(Icons.copy_all_outlined, size: 18, color: Colors.white),
            onPressed: () => _copyList(context, items),
          ),
        ],
      ),
    );
  }

  Widget _storeGroup(BuildContext context, String? slug, List<BasketItem> items, {required bool last}) {
    final pk = context.pk;
    final t = context.t;
    final subtotal = items.fold<double>(0, (s, it) => s + it.price);
    return Container(
      margin: EdgeInsets.only(bottom: last ? 0 : 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: pk.borderSubtle),
        borderRadius: BorderRadius.circular(PkRadius.md),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: slug == null
                    ? Text(t.pickStore, style: PkText.label(size: 13, weight: FontWeight.w700, color: pk.textMuted))
                    : StoreChip(slug: slug, size: PkStoreChipSize.sm),
              ),
              const SizedBox(width: 8),
              Text('${t.productCount(items.length)} · €${subtotal.toStringAsFixed(2)}',
                  style: PkText.mono(size: 11, color: pk.textMuted)),
            ],
          ),
          const SizedBox(height: 8),
          for (final it in items)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      it.product.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: PkText.body(size: 13, color: pk.textSecondary),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(money(it.price), style: PkText.mono(size: 13, color: pk.textPrimary)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  // ── Shareable list ──────────────────────────────────────────────────────────
  String _buildListText(BuildContext context, List<BasketItem> items) {
    final t = context.t;
    final groups = <String?, List<BasketItem>>{};
    for (final it in items) {
      groups.putIfAbsent(it.effectiveStore, () => []).add(it);
    }
    final yourTotal = items.fold<double>(0, (s, it) => s + it.price);
    final avgTotal = items.fold<double>(
        0, (s, it) => s + (it.product.priceStats?.avgPrice ?? it.product.minPrice ?? 0));

    final b = StringBuffer()
      ..writeln(t.listTitle)
      ..writeln();
    groups.forEach((slug, groupItems) {
      b.writeln('🏬 ${_storeName(slug)} (${t.productCount(groupItems.length)})');
      for (final it in groupItems) {
        b.writeln('   • ${it.product.name} — ${money(it.price)}');
      }
      b.writeln();
    });
    b
      ..writeln(t.listTotal(money(yourTotal)))
      ..writeln(t.listSaving(money(avgTotal - yourTotal)))
      ..writeln(t.stops(groups.length))
      ..writeln()
      ..write('posokanei · orestislef.gr/posokanei');
    return b.toString();
  }

  Future<void> _copyList(BuildContext context, List<BasketItem> items) async {
    final text = _buildListText(context, items);
    final messenger = ScaffoldMessenger.of(context);
    final msg = context.t.listCopied;
    await Clipboard.setData(ClipboardData(text: text));
    messenger.showSnackBar(
      SnackBar(behavior: SnackBarBehavior.floating, content: Text(msg)),
    );
  }
}

/// 32×32 remove button: shows a danger-soft hover background.
class _RemoveButton extends StatefulWidget {
  final VoidCallback onTap;
  const _RemoveButton({required this.onTap});

  @override
  State<_RemoveButton> createState() => _RemoveButtonState();
}

class _RemoveButtonState extends State<_RemoveButton> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: Container(
          width: 32,
          height: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: _hovered ? pk.dangerSoft : Colors.transparent,
            borderRadius: BorderRadius.circular(PkRadius.sm),
          ),
          child: Icon(Icons.close, size: 16, color: _hovered ? pk.danger : pk.textMuted),
        ),
      ),
    );
  }
}
