import 'package:flutter/material.dart';

import '../api/images.dart';
import '../api/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/core.dart';
import '../widgets/domain.dart';
import 'nav.dart';
import 'shared.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<Stats>? _stats;
  Future<List<Category>>? _cats;
  Future<Paginated<Product>>? _drops;
  Future<List<Retailer>>? _stores;
  bool _init = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_init) return;
    _init = true;
    final api = AppScope.read(context).api;
    _stats = api.fetchStats();
    _cats = api.fetchCategoryTree();
    _drops = api.fetchProducts(hasDiscount: true, pageSize: 8);
    _stores = api.fetchRetailers();
  }

  @override
  Widget build(BuildContext context) {
    final nav = PkNavScope.of(context);
    return PageScaffold(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _hero(context),
          const SizedBox(height: 44),
          PkSectionHeader(
            title: 'Περιήγηση κατηγοριών',
            linkLabel: 'Όλες οι κατηγορίες',
            onLink: () => nav.openCategory(),
          ),
          _categories(context),
          const SizedBox(height: 44),
          PkSectionHeader(
            title: "Οι μεγαλύτερες πτώσεις σήμερα",
            linkLabel: 'Όλες οι προσφορές',
            onLink: () => nav.goTab(PkTab.deals),
          ),
          _dropsGrid(context),
          const SizedBox(height: 44),
          const PkSectionHeader(title: 'Συγκρίνουμε 22 μαγαζιά'),
          _storeStrip(context),
        ],
      ),
    );
  }

  Widget _hero(BuildContext context) {
    final pk = context.pk;
    final phone = pkIsPhone(context);
    return SizedBox(
      width: double.infinity,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Positioned(
            top: -120,
            child: Container(
              width: 760,
              height: 520,
              decoration: BoxDecoration(
                gradient: RadialGradient(colors: [pk.primarySoft, pk.primarySoft.withValues(alpha: 0)], stops: const [0, 0.6]),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: 12, bottom: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text('PRICE INTELLIGENCE · ΕΛΛΑΔΑ', textAlign: TextAlign.center, style: PkText.eyebrow(size: PkFont.xs, color: pk.dealText)),
                const SizedBox(height: 16),
                Text('Μην ρωτάς πόσο κάνει.',
                    textAlign: TextAlign.center,
                    style: PkText.display(size: phone ? 34 : 56, weight: FontWeight.w800, color: pk.textPrimary, tracking: -0.03, height: 1.04)),
                Text('Ρώτα πού είναι φθηνότερο.',
                    textAlign: TextAlign.center,
                    style: PkText.display(size: phone ? 34 : 56, weight: FontWeight.w800, color: pk.primary, tracking: -0.03, height: 1.04)),
                const SizedBox(height: 18),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Text(
                    'Σύγκρινε κάθε ελληνικό σούπερ μάρκετ με βάση την πραγματική τιμή ανά κιλό, φτιάξε καλάθι και άσε το πόσο κάνει να διαλέξει τα φθηνότερα μαγαζιά.',
                    textAlign: TextAlign.center,
                    style: PkText.body(size: phone ? 15 : 18, color: pk.textSecondary, height: 1.5),
                  ),
                ),
                const SizedBox(height: 34),
                _statsRow(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statsRow(BuildContext context) {
    final pk = context.pk;
    return FutureBuilder<Stats>(
      future: _stats,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const SizedBox(height: 48, child: Center(child: PkSkeleton(width: 320, height: 28)));
        }
        if (snap.hasError || !snap.hasData) return const SizedBox.shrink();
        final s = snap.data!;
        Widget dot() => Container(width: 5, height: 5, margin: const EdgeInsets.symmetric(horizontal: 14), decoration: BoxDecoration(color: pk.borderStrong, shape: BoxShape.circle));
        return Wrap(
          alignment: WrapAlignment.center,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            StatCounter(value: s.totalProducts, label: 'προϊόντα'),
            dot(),
            StatCounter(value: s.retailerCount, label: 'καταστήματα'),
            dot(),
            StatCounter(value: s.productsOnDiscount, label: 'σε προσφορά', tone: PkStatTone.deal),
          ],
        );
      },
    );
  }

  Widget _categories(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _cats,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return PkResponsiveGrid(
            columnsFor: PkResponsiveGrid.categories,
            children: List.generate(10, (_) => const PkSkeleton(height: 150, variant: PkSkeletonVariant.card)),
          );
        }
        if (snap.hasError || !snap.hasData) {
          return PkErrorView(onRetry: () => setState(() => _cats = AppScope.read(context).api.fetchCategoryTree()));
        }
        final cats = snap.data!.where((c) => !c.hidden).take(10).toList();
        final nav = PkNavScope.of(context);
        return PkResponsiveGrid(
          columnsFor: PkResponsiveGrid.categories,
          children: [
            for (var i = 0; i < cats.length; i++)
              PkReveal(
                index: i,
                child: CategoryCard(
                  name: cats[i].name,
                  count: cats[i].totalProductCount,
                  imageUrl: PkImages.display(cats[i].imageUrl),
                  onTap: () => nav.openCategory(categoryId: cats[i].categoryId, categoryName: cats[i].name),
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _dropsGrid(BuildContext context) {
    return FutureBuilder<Paginated<Product>>(
      future: _drops,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const PkProductGridSkeleton(count: 8);
        }
        if (snap.hasError || !snap.hasData) {
          return PkErrorView(onRetry: () => setState(() => _drops = AppScope.read(context).api.fetchProducts(hasDiscount: true, pageSize: 8)));
        }
        final items = snap.data!.items.toList()
          ..sort((a, b) => (b.bestDiscount ?? 0).compareTo(a.bestDiscount ?? 0));
        if (items.isEmpty) {
          return const PkEmptyView(icon: Icons.local_offer_outlined, message: 'Δεν υπάρχουν νέες πτώσεις σήμερα. Παρακολουθούμε 2.702 προσφορές.');
        }
        return PkResponsiveGrid(
          columnsFor: PkResponsiveGrid.products,
          children: [
            for (var i = 0; i < items.length; i++)
              PkReveal(index: i, child: pkProductCard(context, items[i], heroPrefix: 'drops')),
          ],
        );
      },
    );
  }

  Widget _storeStrip(BuildContext context) {
    final pk = context.pk;
    return FutureBuilder<List<Retailer>>(
      future: _stores,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return Wrap(spacing: 14, runSpacing: 14, children: List.generate(12, (_) => const PkSkeleton(width: 72, height: 72, variant: PkSkeletonVariant.card)));
        }
        if (snap.hasError || !snap.hasData) return const SizedBox.shrink();
        final stores = snap.data!;
        final nav = PkNavScope.of(context);
        return Wrap(
          spacing: 14,
          runSpacing: 14,
          children: [
            for (final s in stores)
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => nav.openCategory(retailer: s.id, retailerName: s.name),
                  child: Tooltip(
                    message: s.name,
                    child: Container(
                      width: 72,
                      height: 72,
                      decoration: BoxDecoration(
                        color: pk.surfaceRaised,
                        border: Border.all(color: pk.borderSubtle),
                        borderRadius: BorderRadius.circular(PkRadius.lg),
                        boxShadow: pk.shadowXs,
                      ),
                      alignment: Alignment.center,
                      child: StoreChip(slug: s.id, name: s.name, size: PkStoreChipSize.lg, showName: false, logo: true),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}
