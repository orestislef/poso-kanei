import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../api/models.dart';
import '../i18n/strings.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/core.dart';
import 'nav.dart';
import 'shared.dart';

/// Category browse / search results grid with a desktop category rail, sort +
/// deals filtering (applied client-side), and incremental "load more" paging.
class CategoryScreen extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;
  final String? query;
  final String? retailer;
  final String? retailerName;
  final bool dealsOnly;
  const CategoryScreen({
    super.key,
    this.categoryId,
    this.categoryName,
    this.query,
    this.retailer,
    this.retailerName,
    this.dealsOnly = false,
  });

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  static const int _pageSize = 24;

  bool _init = false;
  late ApiClient _api;

  // First page (drives the main grid skeleton / error state).
  Future<Paginated<Product>>? _firstPage;
  Future<List<Category>>? _tree;

  // Accumulated products across all loaded pages.
  final List<Product> _items = [];
  int _page = 1;
  bool _hasNext = false;
  bool _loadingMore = false;

  String _sort = 'unit'; // unit | price | deal
  late bool _onlyDeals;

  final _searchCtrl = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _onlyDeals = widget.dealsOnly;
    _searchCtrl.text = widget.query ?? '';
    _api = AppScope.read(context).api;
    _tree = _api.fetchCategoryTree();
    _firstPage = _loadFirstPage();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<Paginated<Product>> _fetch(int page) {
    if (widget.retailer != null) {
      return _api.fetchProducts(retailer: widget.retailer, page: page, pageSize: _pageSize);
    }
    if (widget.categoryId != null) {
      // Server does not AND category + has_discount, so deals are filtered
      // client-side. Do NOT pass hasDiscount alongside a category.
      return _api.fetchProducts(category: widget.categoryId, query: widget.query, page: page, pageSize: _pageSize);
    }
    if (widget.dealsOnly) {
      return _api.fetchProducts(hasDiscount: true, query: widget.query, page: page, pageSize: _pageSize);
    }
    return _api.fetchProducts(query: widget.query, page: page, pageSize: _pageSize);
  }

  Future<Paginated<Product>> _loadFirstPage() async {
    final res = await _fetch(1);
    _items
      ..clear()
      ..addAll(res.items);
    _page = res.page;
    _hasNext = res.hasNext;
    return res;
  }

  void _retry() {
    setState(() {
      _items.clear();
      _page = 1;
      _hasNext = false;
      _firstPage = _loadFirstPage();
    });
  }

  Future<void> _loadMore() async {
    if (_loadingMore || !_hasNext) return;
    setState(() => _loadingMore = true);
    try {
      final res = await _fetch(_page + 1);
      if (!mounted) return;
      setState(() {
        _items.addAll(res.items);
        _page = res.page;
        _hasNext = res.hasNext;
      });
    } catch (_) {
      // Keep already-loaded items; just stop the spinner.
    } finally {
      if (mounted) setState(() => _loadingMore = false);
    }
  }

  // -- Client-side filter + sort ----------------------------------------------

  List<Product> get _visible {
    var list = _items;
    if (_onlyDeals) {
      list = list
          .where((p) => p.bestDiscount != null || p.retailerPrices.any((r) => r.isDiscount))
          .toList();
    } else {
      list = List<Product>.from(list);
    }
    const inf = double.infinity;
    switch (_sort) {
      case 'price':
        list.sort((a, b) => (a.minPrice ?? inf).compareTo(b.minPrice ?? inf));
        break;
      case 'deal':
        list.sort((a, b) => (b.bestDiscount ?? 0).compareTo(a.bestDiscount ?? 0));
        break;
      case 'unit':
      default:
        list.sort((a, b) => (a.minUnitPrice ?? a.minPrice ?? inf).compareTo(b.minUnitPrice ?? b.minPrice ?? inf));
    }
    return list;
  }

  // -- Build ------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final desktop = pkIsDesktop(context);
    if (!desktop) return PageScaffold(child: _content(context));

    // Desktop: the rail and filter bar stay put; only the product grid scrolls.
    final hpad = pkPageHPad(context);
    return SafeArea(
      top: false,
      bottom: false,
      child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: PkLayout.container2xl),
        child: Padding(
          padding: EdgeInsets.fromLTRB(hpad, PkSpace.x7, hpad, 0),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: PkLayout.railCategory,
                child: SingleChildScrollView(child: _rail(context)),
              ),
              const SizedBox(width: PkSpace.x8),
              Expanded(child: _desktopContent(context)),
            ],
          ),
        ),
      ),
      ),
    );
  }

  /// Desktop content: breadcrumb + sort/filter bar pinned, grid scrolls below.
  Widget _desktopContent(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _breadcrumb(context),
        const SizedBox(height: PkSpace.x4),
        _filterBar(context),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: PkSpace.x16),
            child: _grid(context),
          ),
        ),
      ],
    );
  }

  // -- Left rail (desktop) ----------------------------------------------------

  Widget _rail(BuildContext context) {
    final pk = context.pk;
    final allActive = widget.categoryId == null &&
        widget.query == null &&
        widget.retailer == null &&
        !widget.dealsOnly;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(10, 4, 10, PkSpace.x3),
          child: Text(
            context.t.railCategories,
            style: PkText.mono(size: PkFont.xs2, color: pk.textMuted, tracking: 1.2),
          ),
        ),
        _railItem(context, label: context.t.allProducts, active: allActive, onTap: () => PkNavScope.of(context).openCategory()),
        const SizedBox(height: PkSpace.x1 / 2 + 1),
        FutureBuilder<List<Category>>(
          future: _tree,
          builder: (context, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return Column(
                children: List.generate(
                  8,
                  (_) => const Padding(
                    padding: EdgeInsets.symmetric(vertical: 6, horizontal: 10),
                    child: PkSkeleton(height: 16, variant: PkSkeletonVariant.text),
                  ),
                ),
              );
            }
            if (snap.hasError || !snap.hasData) return const SizedBox.shrink();
            final roots = snap.data!.where((c) => !c.hidden).toList();
            final nav = PkNavScope.of(context);
            return Column(
              children: [
                for (final c in roots)
                  _railItem(
                    context,
                    label: c.name,
                    count: c.totalProductCount,
                    active: widget.categoryId == c.categoryId,
                    onTap: () => nav.openCategory(categoryId: c.categoryId, categoryName: c.name),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _railItem(
    BuildContext context, {
    required String label,
    int? count,
    required bool active,
    required VoidCallback onTap,
  }) {
    return _RailItem(label: label, count: count, active: active, onTap: onTap);
  }

  // -- Content ----------------------------------------------------------------

  Widget _content(BuildContext context) {
    final phone = pkIsPhone(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (phone) ...[
          PkInput(
            controller: _searchCtrl,
            placeholder: context.t.searchProduct,
            iconLeft: Icon(Icons.search, size: 18, color: context.pk.textMuted),
            onSubmitted: (v) {
              final q = v.trim();
              if (q.isNotEmpty) PkNavScope.of(context).openCategory(query: q);
            },
          ),
          const SizedBox(height: PkSpace.x4),
          _chipRow(context),
          const SizedBox(height: PkSpace.x4),
        ],
        _breadcrumb(context),
        const SizedBox(height: PkSpace.x4),
        _filterBar(context),
        _grid(context),
      ],
    );
  }

  Widget _breadcrumb(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
    String lead;
    if (widget.query != null && widget.query!.isNotEmpty) {
      lead = t.resultsFor(widget.query!);
    } else if (widget.retailerName != null) {
      lead = t.storeLead(widget.retailerName!);
    } else if (widget.dealsOnly) {
      lead = t.deals;
    } else {
      lead = widget.categoryName ?? t.allProducts;
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(lead, style: PkText.body(size: PkFont.sm, color: pk.textSecondary)),
        Text('  ·  ', style: PkText.body(size: PkFont.sm, color: pk.textMuted)),
        Text(t.productCount(_visible.length), style: PkText.mono(size: PkFont.xs, color: pk.textMuted)),
      ],
    );
  }

  Widget _filterBar(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
    return Container(
      margin: const EdgeInsets.only(bottom: PkSpace.x5),
      padding: const EdgeInsets.symmetric(horizontal: PkSpace.x4, vertical: PkSpace.x3),
      decoration: BoxDecoration(
        color: pk.surface,
        borderRadius: BorderRadius.circular(PkRadius.lg),
        border: Border.all(color: pk.borderSubtle, width: 1),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        crossAxisAlignment: WrapCrossAlignment.center,
        spacing: PkSpace.x4,
        runSpacing: PkSpace.x3,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.tune, size: 16, color: pk.textSecondary),
              const SizedBox(width: PkSpace.x2),
              Text(t.sort, style: PkText.label(size: PkFont.sm, weight: FontWeight.w600, color: pk.textSecondary)),
              const SizedBox(width: PkSpace.x3),
              PkSegmentedControl<String>(
                value: _sort,
                onChanged: (v) => setState(() => _sort = v),
                options: [
                  PkSegment('unit', t.sortUnit),
                  PkSegment('price', t.sortPrice),
                  PkSegment('deal', t.sortDeal),
                ],
              ),
            ],
          ),
          PkSwitch(
            label: t.onlyDeals,
            value: _onlyDeals,
            onChanged: (v) => setState(() => _onlyDeals = v),
          ),
        ],
      ),
    );
  }

  Widget _grid(BuildContext context) {
    return FutureBuilder<Paginated<Product>>(
      future: _firstPage,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const PkProductGridSkeleton(count: 8);
        }
        if (snap.hasError) {
          return PkErrorView(onRetry: _retry);
        }
        final items = _visible;
        if (items.isEmpty) {
          return PkEmptyView(
            icon: Icons.search,
            message: context.t.noMatch,
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PkResponsiveGrid(
              columnsFor: PkResponsiveGrid.products,
              children: [
                for (var i = 0; i < items.length; i++)
                  PkReveal(index: i, child: pkProductCard(context, items[i], heroPrefix: 'cat')),
              ],
            ),
            if (_hasNext) ...[
              const SizedBox(height: PkSpace.x6),
              Center(
                child: _loadingMore
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2.5),
                      )
                    : PkButton(
                        label: context.t.loadMore,
                        variant: PkButtonVariant.secondary,
                        onPressed: _loadMore,
                      ),
              ),
            ],
          ],
        );
      },
    );
  }

  // -- Phone category chip row ------------------------------------------------

  Widget _chipRow(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _tree,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 6,
              separatorBuilder: (_, _) => const SizedBox(width: PkSpace.x2),
              itemBuilder: (_, _) => const PkSkeleton(width: 96, height: 34),
            ),
          );
        }
        if (snap.hasError || !snap.hasData) return const SizedBox.shrink();
        final roots = snap.data!.where((c) => !c.hidden).toList();
        final nav = PkNavScope.of(context);
        final allActive = widget.categoryId == null &&
            widget.query == null &&
            widget.retailer == null &&
            !widget.dealsOnly;
        return SizedBox(
          height: 34,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _Chip(label: context.t.all, active: allActive, onTap: () => nav.openCategory()),
              for (final c in roots) ...[
                const SizedBox(width: PkSpace.x2),
                _Chip(
                  label: c.name,
                  active: widget.categoryId == c.categoryId,
                  onTap: () => nav.openCategory(categoryId: c.categoryId, categoryName: c.name),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
}

/// A single hoverable / selectable row in the desktop category rail.
class _RailItem extends StatefulWidget {
  final String label;
  final int? count;
  final bool active;
  final VoidCallback onTap;
  const _RailItem({required this.label, this.count, required this.active, required this.onTap});

  @override
  State<_RailItem> createState() => _RailItemState();
}

class _RailItemState extends State<_RailItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final active = widget.active;
    Color? bg;
    if (active) {
      bg = pk.primarySoft;
    } else if (_hovered) {
      bg = pk.surfaceSunken;
    }
    final fg = active ? pk.primary : pk.textPrimary;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: PkDur.fast,
          curve: PkCurve.standard,
          margin: const EdgeInsets.only(bottom: 2),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(PkRadius.md),
          ),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  widget.label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: PkText.label(
                    size: PkFont.sm,
                    weight: active ? FontWeight.w600 : FontWeight.w500,
                    color: fg,
                  ),
                ),
              ),
              if (widget.count != null) ...[
                const SizedBox(width: PkSpace.x2),
                Text('${widget.count}', style: PkText.mono(size: PkFont.xs2, color: pk.textMuted)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Compact horizontally-scrollable category chip for phone/tablet.
class _Chip extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _Chip({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: PkSpace.x4, vertical: PkSpace.x2),
          decoration: BoxDecoration(
            color: active ? pk.primarySoft : pk.surface,
            borderRadius: BorderRadius.circular(PkRadius.pill),
            border: Border.all(color: active ? pk.primarySoftBorder : pk.borderSubtle, width: 1),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: PkText.label(
              size: PkFont.sm,
              weight: FontWeight.w600,
              color: active ? pk.primary : pk.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
