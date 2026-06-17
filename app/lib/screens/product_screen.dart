import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../api/images.dart';
import '../api/models.dart';
import '../i18n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/core.dart';
import '../widgets/domain.dart';
import 'nav.dart';
import 'shared.dart';

/// Product detail: retailer table, spread bar, history sparkline, alternatives.
class ProductScreen extends StatefulWidget {
  final Product? product;
  final String? productId;
  final String? heroTag;
  const ProductScreen({super.key, this.product, this.productId, this.heroTag});

  @override
  State<ProductScreen> createState() => _ProductScreenState();
}

class _ProductScreenState extends State<ProductScreen> {
  bool _init = false;

  // The product currently rendered. Seeded by the passed-in product (if any),
  // then upgraded to the richer fetched version when it arrives.
  Product? _product;
  Object? _error; // only set when there is no product to show at all

  PriceHistory? _history;
  List<Product> _alternatives = const [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;

    _product = widget.product;

    final id = widget.product?.id ?? widget.productId;
    if (id == null || id.isEmpty) {
      _error = 'no-id';
      return;
    }
    _load(id);
  }

  Future<void> _load(String id) async {
    final api = AppScope.read(context).api;

    // 1) Primary product — richer version. Tolerate failure when we already
    //    have a passed-in product; otherwise surface an error.
    try {
      final full = await api.fetchProduct(id);
      if (!mounted) return;
      setState(() {
        _product = full;
        _error = null;
      });
    } catch (e) {
      if (!mounted) return;
      if (_product == null) {
        setState(() => _error = e);
        return; // no point fetching the rest without a product
      }
      // keep the passed-in product as a fallback
    }

    final p = _product;
    if (p == null) return;

    // 2) History — tolerate failure (just no sparkline).
    try {
      final history = await api.fetchHistory(id);
      if (!mounted) return;
      setState(() => _history = history);
    } catch (_) {
      // no sparkline
    }

    // 3) Alternatives — tolerate failure.
    try {
      final category = p.categoryIds.isNotEmpty ? p.categoryIds.first : null;
      final page = await api.fetchProducts(category: category, pageSize: 8);
      if (!mounted) return;
      setState(() => _alternatives = page.items);
    } catch (_) {
      // no alternatives
    }
  }

  void _retry() {
    final id = widget.product?.id ?? widget.productId;
    if (id == null || id.isEmpty) return;
    setState(() => _error = null);
    _load(id);
  }

  @override
  Widget build(BuildContext context) {
    final product = _product;

    // Hard error with nothing to show.
    if (product == null && _error != null) {
      return PageScaffold(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _BackButton(),
            PkErrorView(
              message: context.t.productNotFound,
              onRetry: widget.productId != null ? _retry : null,
            ),
          ],
        ),
      );
    }

    // Loading (productId path, no passed product yet).
    if (product == null) {
      return const PageScaffold(child: _ProductSkeleton());
    }

    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _BackButton(),
          _DetailTop(
            product: product,
            heroTag: widget.heroTag,
            onMutated: () => setState(() {}),
          ),
          const SizedBox(height: 24),
          _TwoCol(product: product, history: _history),
          _Alternatives(current: product, candidates: _alternatives),
        ],
      ),
    );
  }
}

// ── Back button ─────────────────────────────────────────────────────────────
class _BackButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: InkWell(
        onTap: () => PkNavScope.of(context).back(),
        borderRadius: BorderRadius.circular(PkRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.chevron_left, size: 16, color: pk.textSecondary),
              const SizedBox(width: 2),
              Text(context.t.back,
                  style: PkText.label(
                      size: PkFont.sm, weight: FontWeight.w600, color: pk.textSecondary)),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Detail top: media + info ─────────────────────────────────────────────────
class _DetailTop extends StatelessWidget {
  final Product product;
  final String? heroTag;
  final VoidCallback onMutated;
  const _DetailTop({required this.product, required this.heroTag, required this.onMutated});

  @override
  Widget build(BuildContext context) {
    final media = _Media(product: product, heroTag: heroTag);
    final info = _Info(product: product, onAction: onMutated);

    if (pkIsDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(flex: 9, child: media),
          const SizedBox(width: 36),
          Expanded(flex: 11, child: info),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        media,
        const SizedBox(height: 24),
        info,
      ],
    );
  }
}

class _Media extends StatelessWidget {
  final Product product;
  final String? heroTag;
  const _Media({required this.product, required this.heroTag});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final tag = heroTag ?? 'product-${product.id}';
    final url = PkImages.display(product.imageUrl);

    final Widget image = (product.hasImage && url != null && url.isNotEmpty)
        ? CachedNetworkImage(
            imageUrl: url,
            fit: BoxFit.contain,
            placeholder: (context, _) => const PkSkeleton(),
            errorWidget: (context, _, e) =>
                Icon(Icons.shopping_basket_outlined, size: 110, color: pk.borderStrong),
          )
        : Icon(Icons.shopping_basket_outlined, size: 110, color: pk.borderStrong);

    final discount = product.bestDiscount;

    return AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: pk.surfaceRaised,
          border: Border.all(color: pk.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(PkRadius.xxl),
          boxShadow: pk.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          children: [
            Center(
              child: Hero(
                tag: tag,
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: image,
                ),
              ),
            ),
            if (discount != null)
              Positioned(
                left: 16,
                top: 16,
                child: DealBadge(percentage: discount, pulse: true),
              ),
          ],
        ),
      ),
    );
  }
}

class _Info extends StatelessWidget {
  final Product product;
  final VoidCallback onAction;
  const _Info({required this.product, required this.onAction});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
    final app = AppScope.of(context);
    final pack = pkPackLabel(product);
    final brand = product.brand;
    final brandPack = StringBuffer();
    if (brand != null && brand.isNotEmpty) brandPack.write(brand);
    if (pack != null) {
      if (brandPack.isNotEmpty) brandPack.write(' · ');
      brandPack.write(pack);
    }

    final inBasket = app.inBasket(product.id);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (brandPack.isNotEmpty)
          Text(
            brandPack.toString().toUpperCase(),
            style: PkText.mono(size: 12, color: pk.textMuted, tracking: 0.04),
          ),
        if (brandPack.isNotEmpty) const SizedBox(height: 6),
        Text(
          product.name,
          style: PkText.display(size: 32, weight: FontWeight.w800, height: 1.12, color: pk.textPrimary),
        ),
        const SizedBox(height: 22),
        _HeadCards(product: product),
        const SizedBox(height: 22),
        Align(
          alignment: Alignment.centerLeft,
          child: PkButton(
            size: PkButtonSize.lg,
            label: inBasket ? t.inBasket : t.addToBasket,
            iconLeft: Icon(inBasket ? Icons.check : Icons.add, size: 18, color: Colors.white),
            onPressed: () {
              app.toggleBasket(product);
              onAction();
            },
          ),
        ),
        if (product.priceStats != null && product.storeCount > 1) ...[
          const SizedBox(height: 22),
          _SpreadCard(product: product),
        ],
      ],
    );
  }
}

class _HeadCards extends StatelessWidget {
  final Product product;
  const _HeadCards({required this.product});

  @override
  Widget build(BuildContext context) {
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: _head1(context)),
          const SizedBox(width: 16),
          Expanded(child: _head2(context)),
        ],
      ),
    );
  }

  Widget _shell(BuildContext context, List<Widget> children) {
    final pk = context.pk;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: pk.surface,
        borderRadius: BorderRadius.circular(PkRadius.lg),
        border: Border.all(color: pk.borderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: children,
      ),
    );
  }

  Widget _label(BuildContext context, String text) {
    final pk = context.pk;
    return Text(
      text.toUpperCase(),
      style: PkText.mono(size: 11, color: pk.textMuted, tracking: 0.04),
    );
  }

  Widget _head1(BuildContext context) {
    final sorted = product.sortedByPrice;
    final cheapest = sorted.isNotEmpty ? sorted.first : null;
    return _shell(context, [
      _label(context, context.t.cheapestPrice),
      const SizedBox(height: 8),
      PriceDisplay(
        amount: product.minPrice ?? 0,
        unit: product.unit ?? 'kg',
        size: PkPriceSize.lg,
        tone: PkPriceTone.save,
      ),
      if (cheapest != null) ...[
        const SizedBox(height: 8),
        StoreChip(
          slug: cheapest.retailer,
          name: cheapest.retailerDisplayName,
          size: PkStoreChipSize.sm,
        ),
      ],
    ]);
  }

  Widget _head2(BuildContext context) {
    final pk = context.pk;
    final unit = product.unit ?? 'kg';
    final mup = product.minUnitPrice;
    return _shell(context, [
      _label(context, context.t.bestPerUnit(unit)),
      const SizedBox(height: 8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.baseline,
        textBaseline: TextBaseline.alphabetic,
        mainAxisSize: MainAxisSize.min,
        children: [
          Flexible(
            child: Text(
              '€${(mup ?? 0).toStringAsFixed(2)}',
              style: PkText.display(size: 36, weight: FontWeight.w800, color: pk.saveText),
            ),
          ),
          const SizedBox(width: 4),
          Text(
            '/$unit',
            style: PkText.mono(size: 13, color: pk.textMuted),
          ),
        ],
      ),
      const SizedBox(height: 8),
      PkBadge(tone: PkBadgeTone.save, label: context.t.realComparison),
    ]);
  }
}

class _SpreadCard extends StatelessWidget {
  final Product product;
  const _SpreadCard({required this.product});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final stats = product.priceStats!;
    final min = product.minPrice ?? stats.avgPrice ?? 0;
    final avg = stats.avgPrice ?? min;
    final max = stats.maxPrice ?? min;
    return PkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            context.t.spreadIn(product.storeCount),
            style: PkText.display(size: 16, weight: FontWeight.w700, color: pk.textPrimary),
          ),
          const SizedBox(height: 18),
          PriceSpreadBar(min: min, avg: avg, max: max),
        ],
      ),
    );
  }
}

// ── Two-column: where to buy + history ───────────────────────────────────────
class _TwoCol extends StatelessWidget {
  final Product product;
  final PriceHistory? history;
  const _TwoCol({required this.product, required this.history});

  @override
  Widget build(BuildContext context) {
    final card1 = _WhereToBuy(product: product);
    final card2 = _HistoryCard(product: product, history: history);

    if (pkIsDesktop(context)) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(child: card1),
          const SizedBox(width: 20),
          Expanded(child: card2),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        card1,
        const SizedBox(height: 20),
        card2,
      ],
    );
  }
}

class _WhereToBuy extends StatelessWidget {
  final Product product;
  const _WhereToBuy({required this.product});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
    final app = AppScope.of(context);
    final rows = product.sortedByPrice;
    final unit = product.unit ?? 'kg';
    final item = app.itemFor(product.id);
    // Default the selection to the cheapest store until the user picks another.
    final selectedSlug = item?.effectiveStore ?? (rows.isNotEmpty ? rows.first.retailer : null);
    return PkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(t.whereToBuy,
                    style: PkText.display(size: 16, weight: FontWeight.w700, color: pk.textPrimary)),
              ),
              if (rows.length > 1)
                Text(t.tapToChoose, style: PkText.mono(size: 11, color: pk.textMuted)),
            ],
          ),
          const SizedBox(height: 14),
          if (rows.isEmpty)
            Text(t.noPrices, style: PkText.body(size: PkFont.sm, color: pk.textMuted))
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                for (var i = 0; i < rows.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  _RetailerRow(
                    rp: rows[i],
                    cheapest: i == 0,
                    selected: rows[i].retailer == selectedSlug,
                    unit: unit,
                    onTap: () => app.setStore(product, rows[i].retailer),
                  ),
                ],
              ],
            ),
        ],
      ),
    );
  }
}

class _RetailerRow extends StatelessWidget {
  final RetailerPrice rp;
  final bool cheapest;
  final bool selected;
  final String unit;
  final VoidCallback onTap;
  const _RetailerRow({
    required this.rp,
    required this.cheapest,
    required this.selected,
    required this.unit,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
    final badges = <Widget>[
      if (selected) PkBadge(tone: PkBadgeTone.neutral, label: t.selected),
      if (cheapest) PkBadge(tone: PkBadgeTone.save, label: t.cheapestBadge),
      if (rp.isDiscount) DealBadge(percentage: rp.discountPercentage, soft: true),
      FreshnessBadge(date: rp.lastUpdated),
    ];

    final Color borderColor = selected
        ? pk.primary
        : cheapest
            ? pk.save
            : pk.borderSubtle;
    final Color bg = selected
        ? pk.primarySoft
        : cheapest
            ? pk.saveSoft
            : pk.surface;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: AnimatedContainer(
          duration: PkDur.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(PkRadius.md),
            border: Border.all(color: borderColor, width: (selected || cheapest) ? 1.5 : 1),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                selected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                size: 18,
                color: selected ? pk.primary : pk.borderStrong,
              ),
              const SizedBox(width: 10),
              StoreChip(
                slug: rp.retailer,
                name: rp.retailerDisplayName,
                size: PkStoreChipSize.md,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: badges,
                ),
              ),
              const SizedBox(width: 12),
              PriceDisplay(
                amount: rp.price,
                unitPrice: rp.priceNormalized,
                unit: unit,
                size: PkPriceSize.sm,
                tone: cheapest ? PkPriceTone.save : PkPriceTone.normal,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  final Product product;
  final PriceHistory? history;
  const _HistoryCard({required this.product, required this.history});

  List<double> _series() {
    final h = history;
    if (h == null) return const [];
    final cheapest = h.cheapestSeries;
    if (cheapest.isNotEmpty) return cheapest;
    final sorted = product.sortedByPrice;
    if (sorted.isNotEmpty) {
      final s = h.seriesFor(sorted.first.retailer);
      if (s.isNotEmpty) return s;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final series = _series();
    final hasChart = series.length >= 2;

    double? low;
    if (series.isNotEmpty) {
      low = series.reduce((a, b) => a < b ? a : b);
    }

    final minPrice = product.minPrice;
    final atLow = hasChart && low != null && minPrice != null && minPrice <= low * 1.001;

    return PkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(context.t.priceHistory,
                    style: PkText.display(size: 16, weight: FontWeight.w700, color: pk.textPrimary)),
              ),
              if (hasChart && low != null)
                PkBadge(
                  tone: PkBadgeTone.save,
                  label: context.t.low30('€${low.toStringAsFixed(2)}'),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (hasChart)
            LayoutBuilder(
              builder: (context, c) => Sparkline(
                data: series,
                width: c.maxWidth,
                height: 120,
                showLow: true,
              ),
            )
          else
            Text(context.t.noHistory,
                style: PkText.body(size: PkFont.sm, color: pk.textMuted)),
          if (atLow) ...[
            const SizedBox(height: 14),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.auto_awesome, size: 14, color: pk.saveText),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    context.t.atLowNote,
                    style: PkText.mono(size: 12, color: pk.saveText, height: 1.4),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

// ── Alternatives ─────────────────────────────────────────────────────────────
class _Alternatives extends StatelessWidget {
  final Product current;
  final List<Product> candidates;
  const _Alternatives({required this.current, required this.candidates});

  @override
  Widget build(BuildContext context) {
    final list = candidates.where((p) => p.id != current.id).toList()
      ..sort((a, b) => (a.minUnitPrice ?? double.infinity)
          .compareTo(b.minUnitPrice ?? double.infinity));
    final picks = list.take(4).toList();
    if (picks.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 44),
        PkSectionHeader(title: context.t.alternatives),
        PkResponsiveGrid(
          columnsFor: PkResponsiveGrid.products,
          children: [
            for (var i = 0; i < picks.length; i++)
              PkReveal(index: i, child: pkProductCard(context, picks[i], heroPrefix: 'alt')),
          ],
        ),
      ],
    );
  }
}

// ── Loading skeleton mirroring the layout ────────────────────────────────────
class _ProductSkeleton extends StatelessWidget {
  const _ProductSkeleton();

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final desktop = pkIsDesktop(context);

    final media = AspectRatio(
      aspectRatio: 1,
      child: Container(
        decoration: BoxDecoration(
          color: pk.surfaceRaised,
          border: Border.all(color: pk.borderSubtle, width: 1),
          borderRadius: BorderRadius.circular(PkRadius.xxl),
          boxShadow: pk.shadowSm,
        ),
        clipBehavior: Clip.antiAlias,
        child: const PkSkeleton(),
      ),
    );

    final info = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        PkSkeleton(width: 120, height: 12, variant: PkSkeletonVariant.text),
        SizedBox(height: 12),
        PkSkeleton(height: 30, variant: PkSkeletonVariant.text),
        SizedBox(height: 8),
        PkSkeleton(width: 220, height: 30, variant: PkSkeletonVariant.text),
        SizedBox(height: 24),
        Row(
          children: [
            Expanded(child: PkSkeleton(height: 96, variant: PkSkeletonVariant.card)),
            SizedBox(width: 16),
            Expanded(child: PkSkeleton(height: 96, variant: PkSkeletonVariant.card)),
          ],
        ),
        SizedBox(height: 22),
        PkSkeleton(width: 320, height: 52),
      ],
    );

    final top = desktop
        ? Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 9, child: media),
              const SizedBox(width: 36),
              Expanded(flex: 11, child: info),
            ],
          )
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [media, const SizedBox(height: 24), info],
          );

    final cols = desktop
        ? const Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: PkSkeleton(height: 220, variant: PkSkeletonVariant.card)),
              SizedBox(width: 20),
              Expanded(child: PkSkeleton(height: 220, variant: PkSkeletonVariant.card)),
            ],
          )
        : const Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PkSkeleton(height: 220, variant: PkSkeletonVariant.card),
              SizedBox(height: 20),
              PkSkeleton(height: 220, variant: PkSkeletonVariant.card),
            ],
          );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _BackButton(),
        top,
        const SizedBox(height: 24),
        cols,
      ],
    );
  }
}
