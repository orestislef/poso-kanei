import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/images.dart';
import '../api/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/core.dart';
import '../widgets/domain.dart';
import 'nav.dart';
import 'shared.dart';

/// Basket + smart optimizer (single store / cheapest split / 2-stop).
class BasketScreen extends StatefulWidget {
  const BasketScreen({super.key});

  @override
  State<BasketScreen> createState() => _BasketScreenState();
}

class _BasketScreenState extends State<BasketScreen> {
  String strategy = 'split';

  String money(double v) => '€${v.toStringAsFixed(2)}';

  /// Cheapest retailer slug for a product (guards empty price lists).
  String? _cheapestSlug(Product p) {
    final sorted = p.sortedByPrice;
    if (sorted.isNotEmpty) return sorted.first.retailer;
    if (p.retailerPrices.isNotEmpty) return p.retailerPrices.first.retailer;
    return null;
  }

  /// Cheapest price for a product (the price paid in a split strategy).
  double _cheapestPrice(Product p) {
    final sorted = p.sortedByPrice;
    if (sorted.isNotEmpty) return sorted.first.price;
    return p.minPrice ?? 0;
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final items = app.basket;

    if (items.isEmpty) {
      return PageScaffold(
        child: PkEmptyView(
          big: true,
          icon: Icons.shopping_basket_outlined,
          title: 'Το καλάθι σου είναι άδειο',
          message:
              'Πρόσθεσε προϊόντα και βρίσκουμε τον φθηνότερο τρόπο να τα αγοράσεις όλα.',
          action: PkButton(
            label: 'Ξεκίνα μια λίστα',
            iconLeft: const Icon(Icons.arrow_forward, size: 18, color: Colors.white),
            onPressed: () => PkNavScope.of(context).goTab(PkTab.home),
          ),
        ),
      );
    }

    final content = _content(context, app, items);
    final optimizer = _optimizer(context, items);

    return PageScaffold(
      child: pkIsDesktop(context)
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: content),
                const SizedBox(width: 28),
                SizedBox(width: PkLayout.railBasket, child: optimizer),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                content,
                const SizedBox(height: 24),
                optimizer,
              ],
            ),
    );
  }

  // ── Content (line items) ───────────────────────────────────────────────────
  Widget _content(BuildContext context, PkAppState app, List<Product> items) {
    final pk = context.pk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              'Το καλάθι σου',
              style: PkText.display(size: 30, weight: FontWeight.w800, color: pk.textPrimary),
            ),
            const SizedBox(width: 10),
            Text(
              '${items.length} ${_plural(items.length)}',
              style: PkText.mono(size: 14, color: pk.textMuted),
            ),
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

  Widget _lineItem(BuildContext context, PkAppState app, Product p, {required bool last}) {
    final pk = context.pk;
    final slug = _cheapestSlug(p);
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

    return InkWell(
      onTap: () => PkNavScope.of(context).openProduct(p),
      child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
      decoration: BoxDecoration(
        border: last ? null : Border(bottom: BorderSide(color: pk.borderSubtle)),
      ),
      child: Row(
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
                      metaParts.isEmpty
                          ? 'φθηνότερο σε'
                          : '${metaParts.join(' · ')} · φθηνότερο σε',
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
            amount: p.minPrice ?? 0,
            unitPrice: p.priceStats?.minUnitPrice,
            unit: p.unit ?? 'kg',
            size: PkPriceSize.sm,
          ),
          const SizedBox(width: 8),
          _RemoveButton(onTap: () => app.removeFromBasket(p.id)),
        ],
      ),
      ),
    );
  }

  // ── Optimizer panel ─────────────────────────────────────────────────────────
  Widget _optimizer(BuildContext context, List<Product> items) {
    final pk = context.pk;

    final single = items.fold<double>(
        0, (s, p) => s + (p.priceStats?.avgPrice ?? p.minPrice ?? 0));
    final split = items.fold<double>(0, (s, p) => s + (p.minPrice ?? 0));
    final balanced = split + 0.60;
    final saving = single - split;

    final total = strategy == 'single'
        ? single
        : strategy == 'split'
            ? split
            : balanced;

    return PkCard(
      radius: PkRadius.xl,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('ΕΞΥΠΝΟΣ ΒΕΛΤΙΣΤΟΠΟΙΗΤΗΣ',
              style: PkText.eyebrow(size: 12, color: pk.dealText)),
          const SizedBox(height: 14),
          Text(
            'Ο φθηνότερος τρόπος να το αγοράσεις',
            style: PkText.display(size: 20, weight: FontWeight.w800, color: pk.textPrimary),
          ),
          const SizedBox(height: 14),
          PkSegmentedControl<String>(
            block: true,
            options: const [
              PkSegment('single', '1 μαγαζί'),
              PkSegment('split', 'Διαμοιρασμός'),
              PkSegment('balanced', '2 στάσεις'),
            ],
            value: strategy,
            onChanged: (v) => setState(() => strategy = v),
          ),
          const SizedBox(height: 14),
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
                    Text('ΣΥΝΟΛΟ ΚΑΛΑΘΙΟΥ',
                        style: PkText.mono(size: 11, color: pk.textMuted)),
                    const SizedBox(height: 6),
                    PriceDisplay(amount: total, size: PkPriceSize.lg, tone: PkPriceTone.save),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text('vs ${money(single)} μ.ό.',
                        style: PkText.mono(size: 12, color: pk.textMuted)),
                    const SizedBox(height: 6),
                    Text(
                      'γλιτώνεις ${money(saving)}',
                      style: PkText.display(size: 18, weight: FontWeight.w800, color: pk.saveText),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          if (strategy == 'split') ..._splitDetail(context, items),
          if (strategy == 'single')
            Text(
              'Αγόρασε τα πάντα σε μία αλυσίδα — λιγότερες στάσεις, ελαφρώς υψηλότερο σύνολο.',
              style: PkText.body(size: 13, color: pk.textSecondary),
            ),
          if (strategy == 'balanced')
            Text(
              'Με όριο 2 μαγαζιά: σχεδόν όλη η εξοικονόμηση του split, με τις μισές στάσεις.',
              style: PkText.body(size: 13, color: pk.textSecondary),
            ),
          const SizedBox(height: 18),
          PkButton(
            block: true,
            size: PkButtonSize.lg,
            label: 'Αντιγραφή λίστας',
            iconRight: const Icon(Icons.copy_all_outlined, size: 18, color: Colors.white),
            onPressed: () => _copyList(context, items),
          ),
        ],
      ),
    );
  }

  /// Build a clean, shareable shopping list grouped by cheapest store.
  String _buildListText(List<Product> items) {
    final groups = <String, List<Product>>{};
    for (final p in items) {
      final slug = _cheapestSlug(p) ?? '—';
      groups.putIfAbsent(slug, () => []).add(p);
    }

    final single = items.fold<double>(
        0, (s, p) => s + (p.priceStats?.avgPrice ?? p.minPrice ?? 0));
    final split = items.fold<double>(0, (s, p) => s + (p.minPrice ?? 0));

    final b = StringBuffer()
      ..writeln('🛒 Λίστα αγορών — πόσο κάνει')
      ..writeln();
    groups.forEach((slug, groupItems) {
      final name = kRetailers[slug]?.name ?? slug;
      b.writeln('🏬 $name (${groupItems.length} ${_plural(groupItems.length)})');
      for (final p in groupItems) {
        b.writeln('   • ${p.name} — ${money(_cheapestPrice(p))}');
      }
      b.writeln();
    });
    b
      ..writeln('Σύνολο (φθηνότερος διαμοιρασμός): ${money(split)}')
      ..writeln('Εκτίμηση εξοικονόμησης vs μέσος όρος: ${money(single - split)}')
      ..writeln('${groups.length} ${groups.length == 1 ? 'στάση' : 'στάσεις'}')
      ..writeln()
      ..write('posokanei · orestislef.gr/posokanei');
    return b.toString();
  }

  Future<void> _copyList(BuildContext context, List<Product> items) async {
    await Clipboard.setData(ClipboardData(text: _buildListText(items)));
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        behavior: SnackBarBehavior.floating,
        content: Text('Η λίστα αγορών αντιγράφηκε — επικόλλησέ την όπου θες.'),
      ),
    );
  }

  List<Widget> _splitDetail(BuildContext context, List<Product> items) {
    final pk = context.pk;

    // Group items by cheapest retailer slug, preserving insertion order.
    final groups = <String, List<Product>>{};
    for (final p in items) {
      final slug = _cheapestSlug(p) ?? '—';
      groups.putIfAbsent(slug, () => []).add(p);
    }

    final widgets = <Widget>[];
    final entries = groups.entries.toList();
    for (var gi = 0; gi < entries.length; gi++) {
      final slug = entries[gi].key;
      final groupItems = entries[gi].value;
      widgets.add(
        Container(
          margin: EdgeInsets.only(bottom: gi == entries.length - 1 ? 0 : 10),
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
                  Flexible(child: StoreChip(slug: slug, size: PkStoreChipSize.sm)),
                  const SizedBox(width: 8),
                  Text(
                    '${groupItems.length} ${_plural(groupItems.length)}',
                    style: PkText.mono(size: 11, color: pk.textMuted),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              for (final p in groupItems)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          (p.brand != null && p.brand!.isNotEmpty) ? p.brand! : p.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: PkText.body(size: 13, color: pk.textSecondary),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        money(_cheapestPrice(p)),
                        style: PkText.mono(size: 13, color: pk.textPrimary),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      );
    }

    widgets.add(
      Padding(
        padding: const EdgeInsets.only(top: 6),
        child: Row(
          children: [
            Icon(Icons.map_outlined, size: 14, color: pk.textSecondary),
            const SizedBox(width: 6),
            Text(
              '${entries.length} ${entries.length == 1 ? 'στάση' : 'στάσεις'}',
              style: PkText.mono(size: 12, color: pk.textSecondary),
            ),
          ],
        ),
      ),
    );

    return widgets;
  }

  String _plural(int n) => n == 1 ? 'προϊόν' : 'προϊόντα';
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
          child: Icon(
            Icons.close,
            size: 16,
            color: _hovered ? pk.danger : pk.textMuted,
          ),
        ),
      ),
    );
  }
}
