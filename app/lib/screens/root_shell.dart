import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import '../api/models.dart';
import '../i18n/strings.dart';
import '../router.dart';
import '../state/app_state.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/core.dart';
import 'nav.dart';

/// Translates the [PkNav] contract into clean, language-prefixed go_router URLs.
class _ShellNav implements PkNav {
  final BuildContext context;
  final Lang lang;
  _ShellNav(this.context, this.lang);

  String get _l => lang.code;

  @override
  void goTab(PkTab tab) {
    switch (tab) {
      case PkTab.home:
        context.go('/$_l');
      case PkTab.deals:
        context.go('/$_l/deals');
      case PkTab.stores:
        context.go('/$_l/stores');
      case PkTab.basket:
        context.go('/$_l/basket');
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
    if (dealsOnly) {
      context.go('/$_l/deals');
    } else if (categoryId != null) {
      context.push('/$_l/category/$categoryId', extra: categoryName);
    } else if (retailer != null) {
      context.push('/$_l/store/$retailer', extra: retailerName);
    } else if (query != null && query.trim().isNotEmpty) {
      context.push('/$_l/search?q=${Uri.encodeQueryComponent(query.trim())}');
    } else {
      context.push('/$_l/products');
    }
  }

  @override
  void openProduct(Product product, {String? heroTag}) => context.push(
        '/$_l/product/${product.id}',
        extra: ProductArgs(product: product, heroTag: heroTag),
      );

  @override
  void openProductById(String id) => context.push('/$_l/product/$id');

  @override
  void back() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/$_l');
    }
  }
}

/// The persistent app frame: glass header + routed child + (phone) bottom nav.
class RootShell extends StatefulWidget {
  final GoRouterState state;
  final Widget child;
  const RootShell({super.key, required this.state, required this.child});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  final _searchCtrl = TextEditingController();

  Lang get _lang => Lang.fromCode(
      widget.state.uri.pathSegments.isNotEmpty ? widget.state.uri.pathSegments.first : 'el');

  PkTab get _tab {
    final segs = widget.state.uri.pathSegments;
    if (segs.length >= 2) {
      switch (segs[1]) {
        case 'deals':
          return PkTab.deals;
        case 'stores':
          return PkTab.stores;
        case 'basket':
          return PkTab.basket;
      }
    }
    return PkTab.home;
  }

  void _switchLang() {
    final next = _lang == Lang.el ? Lang.en : Lang.el;
    final segs = widget.state.uri.pathSegments.toList();
    if (segs.isEmpty) {
      segs.add(next.code);
    } else {
      segs[0] = next.code;
    }
    final q = widget.state.uri.hasQuery ? '?${widget.state.uri.query}' : '';
    context.go('/${segs.join('/')}$q');
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
    final lang = _lang;

    // Keep app language in sync with the URL (source of truth).
    if (app.lang != lang) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) app.setLang(lang);
      });
    }

    final nav = _ShellNav(context, lang);
    final width = MediaQuery.of(context).size.width;
    final showBottomNav = width < 768;

    final overlay = (app.dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark).copyWith(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    );

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlay,
      child: PkNavScope(
        nav: nav,
        child: Scaffold(
          backgroundColor: pk.canvas,
          body: Column(
            children: [
              _GlassHeader(
                searchController: _searchCtrl,
                activeTab: _tab,
                basketCount: app.basketCount,
                dark: app.dark,
                lang: lang,
                showInlineSearch: width >= 1080,
                showNavLinks: width >= 768,
                onLogo: () => nav.goTab(PkTab.home),
                onTab: nav.goTab,
                onToggleTheme: app.toggleTheme,
                onToggleLang: _switchLang,
                onSearchSubmit: (q) {
                  if (q.trim().isNotEmpty) nav.openCategory(query: q);
                },
                onSearchTapPhone: () => nav.openCategory(),
              ),
              Expanded(child: widget.child),
            ],
          ),
          bottomNavigationBar: showBottomNav
              ? _BottomNav(active: _tab, basketCount: app.basketCount, onTab: nav.goTab)
              : null,
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
  final Lang lang;
  final bool showInlineSearch;
  final bool showNavLinks;
  final VoidCallback onLogo;
  final ValueChanged<PkTab> onTab;
  final VoidCallback onToggleTheme;
  final VoidCallback onToggleLang;
  final ValueChanged<String> onSearchSubmit;
  final VoidCallback onSearchTapPhone;

  const _GlassHeader({
    required this.searchController,
    required this.activeTab,
    required this.basketCount,
    required this.dark,
    required this.lang,
    required this.showInlineSearch,
    required this.showNavLinks,
    required this.onLogo,
    required this.onTab,
    required this.onToggleTheme,
    required this.onToggleLang,
    required this.onSearchSubmit,
    required this.onSearchTapPhone,
  });

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final t = context.t;
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
                              placeholder: t.searchHint,
                              iconLeft: Icon(Icons.search, size: 18, color: pk.textMuted),
                              onSubmitted: onSearchSubmit,
                            ),
                          ),
                        )
                      else
                        const Spacer(),
                      if (showNavLinks) ...[
                        const SizedBox(width: 16),
                        _NavLink(label: t.navHome, active: activeTab == PkTab.home, onTap: () => onTab(PkTab.home)),
                        _NavLink(label: t.navDeals, active: activeTab == PkTab.deals, onTap: () => onTab(PkTab.deals)),
                        _NavLink(label: t.navStores, active: activeTab == PkTab.stores, onTap: () => onTab(PkTab.stores)),
                      ],
                      const SizedBox(width: 6),
                      if (!showInlineSearch)
                        PkIconButton(
                          semanticLabel: t.searchShort,
                          onPressed: onSearchTapPhone,
                          child: Icon(Icons.search, size: 18, color: pk.textSecondary),
                        ),
                      _LangButton(lang: lang, onTap: onToggleLang, semanticLabel: t.toggleLang),
                      PkIconButton(
                        semanticLabel: t.toggleTheme,
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

/// EL / EN language toggle pill.
class _LangButton extends StatelessWidget {
  final Lang lang;
  final VoidCallback onTap;
  final String semanticLabel;
  const _LangButton({required this.lang, required this.onTap, required this.semanticLabel});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return Semantics(
      button: true,
      label: semanticLabel,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(PkRadius.sm),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Text(
            lang == Lang.el ? 'EL' : 'EN',
            style: PkText.mono(size: 13, weight: FontWeight.w700, color: pk.textSecondary, tracking: 0.04),
          ),
        ),
      ),
    );
  }
}

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
    final t = context.t;
    final items = <(PkTab, IconData, String)>[
      (PkTab.home, Icons.home_outlined, t.navHome),
      (PkTab.deals, Icons.local_offer_outlined, t.navDeals),
      (PkTab.stores, Icons.storefront_outlined, t.navStores),
      (PkTab.basket, Icons.shopping_basket_outlined, t.navBasket),
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
