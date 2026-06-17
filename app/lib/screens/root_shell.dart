import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../api/models.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/core.dart';
import 'basket_screen.dart';
import 'category_screen.dart';
import 'home_screen.dart';
import 'nav.dart';
import 'product_screen.dart';
import 'stores_screen.dart';

/// The persistent app frame: glass header + nested navigator + (phone) bottom nav.
class RootShell extends StatefulWidget {
  const RootShell({super.key});
  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> implements PkNav {
  final _navKey = GlobalKey<NavigatorState>();
  final _searchCtrl = TextEditingController();
  PkTab _tab = PkTab.home;

  Route<void> _route(Widget page) => MaterialPageRoute(builder: (_) => page);

  void _resetTo(Widget page) =>
      _navKey.currentState?.pushAndRemoveUntil(_route(page), (r) => false);

  @override
  void goTab(PkTab tab) {
    setState(() => _tab = tab);
    switch (tab) {
      case PkTab.home:
        _searchCtrl.clear();
        _resetTo(const HomeScreen());
      case PkTab.deals:
        _resetTo(const CategoryScreen(dealsOnly: true, categoryName: 'Προσφορές'));
      case PkTab.stores:
        _resetTo(const StoresScreen());
      case PkTab.basket:
        _resetTo(const BasketScreen());
    }
  }

  @override
  void openCategory({
    String? categoryId,
    String? categoryName,
    String? query,
    String? retailer,
    String? retailerName,
    bool dealsOnly = false,
  }) {
    if (dealsOnly) setState(() => _tab = PkTab.deals);
    _navKey.currentState?.push(_route(CategoryScreen(
      categoryId: categoryId,
      categoryName: categoryName,
      query: query,
      retailer: retailer,
      retailerName: retailerName,
      dealsOnly: dealsOnly,
    )));
  }

  @override
  void openProduct(Product product, {String? heroTag}) =>
      _navKey.currentState?.push(_route(ProductScreen(product: product, heroTag: heroTag)));

  @override
  void openProductById(String id) =>
      _navKey.currentState?.push(_route(ProductScreen(productId: id)));

  @override
  void back() {
    if (_navKey.currentState?.canPop() ?? false) _navKey.currentState?.pop();
  }

  void _onSearchSubmit(String q) {
    final query = q.trim();
    if (query.isEmpty) return;
    openCategory(query: query);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = AppScope.of(context);
    final pk = context.pk;
    final width = MediaQuery.of(context).size.width;
    final showBottomNav = width < 768;

    final overlay = (app.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
        .copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: PkNavScope(
      nav: this,
      child: PopScope(
        canPop: false,
        onPopInvokedWithResult: (didPop, _) {
          if (didPop) return;
          final nav = _navKey.currentState;
          if (nav != null && nav.canPop()) {
            nav.pop();
          } else {
            SystemNavigator.pop();
          }
        },
        child: Scaffold(
          backgroundColor: pk.canvas,
          body: Column(
            children: [
              _GlassHeader(
                searchController: _searchCtrl,
                activeTab: _tab,
                basketCount: app.basketCount,
                dark: app.dark,
                showInlineSearch: width >= 1080,
                showNavLinks: width >= 768,
                onLogo: () => goTab(PkTab.home),
                onTab: goTab,
                onToggleTheme: app.toggleTheme,
                onSearchSubmit: _onSearchSubmit,
                onSearchTapPhone: () => openCategory(),
              ),
              Expanded(
                child: Navigator(
                  key: _navKey,
                  onGenerateRoute: (settings) =>
                      MaterialPageRoute(builder: (_) => const HomeScreen(), settings: settings),
                ),
              ),
            ],
          ),
          bottomNavigationBar: showBottomNav
              ? _BottomNav(active: _tab, basketCount: app.basketCount, onTab: goTab)
              : null,
        ),
      ),
      ),
    );
  }
}

// ── Glass header ─────────────────────────────────────────────────────────────
class _GlassHeader extends StatelessWidget {
  final TextEditingController searchController;
  final PkTab activeTab;
  final int basketCount;
  final bool dark;
  final bool showInlineSearch;
  final bool showNavLinks;
  final VoidCallback onLogo;
  final ValueChanged<PkTab> onTab;
  final VoidCallback onToggleTheme;
  final ValueChanged<String> onSearchSubmit;
  final VoidCallback onSearchTapPhone;

  const _GlassHeader({
    required this.searchController,
    required this.activeTab,
    required this.basketCount,
    required this.dark,
    required this.showInlineSearch,
    required this.showNavLinks,
    required this.onLogo,
    required this.onTab,
    required this.onToggleTheme,
    required this.onSearchSubmit,
    required this.onSearchTapPhone,
  });

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final hpad = pkHeaderPad(context);
    return ClipRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
        child: Container(
          decoration: BoxDecoration(
            color: pk.canvas.withValues(alpha: 0.82),
            border: Border(bottom: BorderSide(color: pk.borderSubtle)),
          ),
          child: SafeArea(
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: PkLayout.container2xl),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: hpad, vertical: 14),
                  child: Row(
                    children: [
                      InkWell(onTap: onLogo, child: const Logo(size: 22)),
                      const SizedBox(width: 20),
                      if (showInlineSearch)
                        Expanded(
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 520),
                            child: PkInput(
                              controller: searchController,
                              placeholder: 'Αναζήτησε 8.500+ προϊόντα — γάλα, ελαιόλαδο, καφέ…',
                              iconLeft: Icon(Icons.search, size: 18, color: pk.textMuted),
                              onSubmitted: onSearchSubmit,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (showNavLinks) ...[
                        const SizedBox(width: 16),
                        _NavLink(label: 'Αρχική', active: activeTab == PkTab.home, onTap: () => onTab(PkTab.home)),
                        _NavLink(label: 'Προσφορές', active: activeTab == PkTab.deals, onTap: () => onTab(PkTab.deals)),
                        _NavLink(label: 'Καταστήματα', active: activeTab == PkTab.stores, onTap: () => onTab(PkTab.stores)),
                      ],
                      const SizedBox(width: 6),
                      if (!showInlineSearch)
                        PkIconButton(
                          semanticLabel: 'Αναζήτηση',
                          onPressed: onSearchTapPhone,
                          child: Icon(Icons.search, size: 18, color: pk.textSecondary),
                        ),
                      PkIconButton(
                        semanticLabel: 'Εναλλαγή θέματος',
                        onPressed: onToggleTheme,
                        child: Icon(dark ? Icons.light_mode_outlined : Icons.dark_mode_outlined, size: 18, color: pk.textSecondary),
                      ),
                      const SizedBox(width: 4),
                      _BasketButton(count: basketCount, onTap: () => onTab(PkTab.basket)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

double pkHeaderPad(BuildContext c) =>
    MediaQuery.of(c).size.width < PkLayout.bpPhone ? PkSpace.x4 : PkSpace.x8;

class _NavLink extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _NavLink({required this.label, required this.active, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PkRadius.sm),
        child: AnimatedContainer(
          duration: PkDur.fast,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: active ? pk.primarySoft : Colors.transparent,
            borderRadius: BorderRadius.circular(PkRadius.sm),
          ),
          child: Text(
            label,
            style: PkText.label(size: PkFont.sm, weight: FontWeight.w600, color: active ? pk.primary : pk.textSecondary),
          ),
        ),
      ),
    );
  }
}

class _BasketButton extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _BasketButton({required this.count, required this.onTap});
  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PkRadius.md),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: pk.primary, borderRadius: BorderRadius.circular(PkRadius.md)),
            child: Icon(Icons.shopping_basket_outlined, size: 18, color: pk.onPrimary),
          ),
          if (count > 0)
            Positioned(
              top: -5,
              right: -5,
              child: Container(
                constraints: const BoxConstraints(minWidth: 19),
                height: 19,
                padding: const EdgeInsets.symmetric(horizontal: 5),
                decoration: BoxDecoration(
                  color: pk.deal,
                  borderRadius: BorderRadius.circular(PkRadius.pill),
                  border: Border.all(color: pk.canvas, width: 2),
                ),
                alignment: Alignment.center,
                child: Text('$count', style: PkText.mono(size: PkFont.xs2, weight: FontWeight.w700, color: Colors.white)),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Bottom nav (phone) ───────────────────────────────────────────────────────
class _BottomNav extends StatelessWidget {
  final PkTab active;
  final int basketCount;
  final ValueChanged<PkTab> onTab;
  const _BottomNav({required this.active, required this.basketCount, required this.onTab});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final items = <(PkTab, IconData, String)>[
      (PkTab.home, Icons.home_outlined, 'Αρχική'),
      (PkTab.deals, Icons.local_offer_outlined, 'Προσφορές'),
      (PkTab.stores, Icons.storefront_outlined, 'Μαγαζιά'),
      (PkTab.basket, Icons.shopping_basket_outlined, 'Καλάθι'),
    ];
    return Container(
      decoration: BoxDecoration(
        color: pk.surfaceRaised,
        border: Border(top: BorderSide(color: pk.borderSubtle)),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: [
              for (final (tab, icon, label) in items)
                Expanded(
                  child: InkWell(
                    onTap: () => onTab(tab),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Icon(icon, size: 22, color: active == tab ? pk.primary : pk.textMuted),
                            if (tab == PkTab.basket && basketCount > 0)
                              Positioned(
                                top: -4,
                                right: -8,
                                child: Container(
                                  constraints: const BoxConstraints(minWidth: 16),
                                  height: 16,
                                  padding: const EdgeInsets.symmetric(horizontal: 4),
                                  decoration: BoxDecoration(color: pk.deal, borderRadius: BorderRadius.circular(PkRadius.pill)),
                                  alignment: Alignment.center,
                                  child: Text('$basketCount', style: PkText.mono(size: 9, weight: FontWeight.w700, color: Colors.white)),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(label, style: PkText.label(size: PkFont.xs2, weight: FontWeight.w600, color: active == tab ? pk.primary : pk.textMuted)),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
