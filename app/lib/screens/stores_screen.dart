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

/// Retailer directory — every chain we compare, grouped Greek-first.
class StoresScreen extends StatefulWidget {
  const StoresScreen({super.key});
  @override
  State<StoresScreen> createState() => _StoresScreenState();
}

class _StoresScreenState extends State<StoresScreen> {
  Future<List<Retailer>>? _stores;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    _stores = AppScope.read(context).api.fetchRetailers();
  }

  void _reload() {
    setState(() => _stores = AppScope.read(context).api.fetchRetailers());
  }

  /// Greek retailers first, then the rest; alphabetical by name within group.
  List<Retailer> _sorted(List<Retailer> input) {
    bool isGreek(Retailer r) => (r.country ?? '').toUpperCase() == 'GR';
    final list = List<Retailer>.from(input)
      ..sort((a, b) {
        final ga = isGreek(a), gb = isGreek(b);
        if (ga != gb) return ga ? -1 : 1;
        return a.name.toLowerCase().compareTo(b.name.toLowerCase());
      });
    return list;
  }

  static int _columnsFor(double w) => w >= 1000 ? 4 : (w >= 680 ? 3 : 2);

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            t.storesTitle,
            style: PkText.display(size: 30, weight: FontWeight.w800, color: pk.textPrimary, tracking: -0.02),
          ),
          const SizedBox(height: 6),
          Text(
            t.storesSubtitle,
            style: PkText.body(size: 16, color: pk.textSecondary, height: 1.5),
          ),
          const SizedBox(height: 22),
          FutureBuilder<List<Retailer>>(
            future: _stores,
            builder: (context, snap) {
              if (snap.connectionState != ConnectionState.done) {
                return PkResponsiveGrid(
                  columnsFor: _columnsFor,
                  children: List.generate(
                    12,
                    (_) => const PkSkeleton(height: 150, variant: PkSkeletonVariant.card),
                  ),
                );
              }
              if (snap.hasError || !snap.hasData) {
                return PkErrorView(onRetry: _reload);
              }
              final stores = _sorted(snap.data!);
              if (stores.isEmpty) {
                return PkEmptyView(
                  icon: Icons.storefront_outlined,
                  message: t.noStores,
                );
              }
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  PkBadge(label: t.storesCount(stores.length), tone: PkBadgeTone.neutral),
                  const SizedBox(height: 22),
                  PkResponsiveGrid(
                    columnsFor: _columnsFor,
                    children: [
                      for (var i = 0; i < stores.length; i++)
                        PkReveal(index: i, child: _storeCard(context, stores[i])),
                    ],
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _storeCard(BuildContext context, Retailer r) {
    final pk = context.pk;
    final nav = PkNavScope.of(context);
    final country = (r.country ?? '').trim().toUpperCase();
    return PkCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _logo(context, r),
          const SizedBox(height: 12),
          Text(
            r.name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: PkText.label(size: PkFont.base, weight: FontWeight.w700, color: pk.textPrimary),
          ),
          if (country.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(country, style: PkText.mono(size: 11, color: pk.textMuted)),
          ],
          const SizedBox(height: 12),
          PkTextLink(
            label: context.t.browseStore,
            onTap: () => nav.openCategory(retailer: r.id, retailerName: r.name),
          ),
        ],
      ),
    );
  }

  /// Real logo when it loads; silently collapses to nothing on error so a
  /// broken image never shows (the monogram below always renders the brand).
  Widget _logo(BuildContext context, Retailer r) {
    final pk = context.pk;
    return Container(
      width: 56,
      height: 56,
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: pk.surfaceSunken,
        borderRadius: BorderRadius.circular(PkRadius.md),
        border: Border.all(color: pk.borderSubtle),
      ),
      clipBehavior: Clip.antiAlias,
      child: CachedNetworkImage(
        imageUrl: PkImages.resolve(r.logoUrl) ?? PkImages.retailer(r.id),
        fit: BoxFit.contain,
        fadeInDuration: PkDur.fast,
        placeholder: (context, _) => StoreChip(slug: r.id, name: r.name, size: PkStoreChipSize.lg, showName: false),
        errorWidget: (context, url, error) => StoreChip(slug: r.id, name: r.name, size: PkStoreChipSize.lg, showName: false),
      ),
    );
  }
}
