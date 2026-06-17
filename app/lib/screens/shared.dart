import 'package:flutter/material.dart';

import '../api/images.dart';
import '../api/models.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';
import '../widgets/brand.dart';
import '../widgets/core.dart';
import '../widgets/domain.dart';
import 'nav.dart';

// ── Responsive helpers ──────────────────────────────────────────────────────
bool pkIsDesktop(BuildContext c) => MediaQuery.of(c).size.width >= PkLayout.bpDesktop;
bool pkIsPhone(BuildContext c) => MediaQuery.of(c).size.width < PkLayout.bpPhone;
double pkPageHPad(BuildContext c) => pkIsPhone(c) ? PkSpace.x4 : PkSpace.x8;

/// Centered, width-clamped page body with the footer pinned after the content.
class PageScaffold extends StatelessWidget {
  final Widget child;
  final bool showFooter;
  final ScrollController? controller;
  const PageScaffold({
    super.key,
    required this.child,
    this.showFooter = true,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final hpad = pkPageHPad(context);
    return SingleChildScrollView(
      controller: controller,
      child: Column(
        children: [
          SafeArea(
            top: false,
            bottom: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: PkLayout.container2xl),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(hpad, PkSpace.x7, hpad, PkSpace.x16),
                  child: child,
                ),
              ),
            ),
          ),
          if (showFooter) const PkFooter(),
        ],
      ),
    );
  }
}

class PkFooter extends StatelessWidget {
  const PkFooter({super.key});
  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final hpad = pkPageHPad(context);
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        border: Border(top: BorderSide(color: pk.borderSubtle)),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: PkLayout.container2xl),
          child: Padding(
            padding: EdgeInsets.fromLTRB(hpad, PkSpace.x7, hpad, PkSpace.x12),
            child: Wrap(
              crossAxisAlignment: WrapCrossAlignment.center,
              spacing: PkSpace.x4,
              runSpacing: PkSpace.x2,
              children: [
                const Logo(size: 18),
                Text(
                  '© 2026 πόσο κάνει · δεδομένα από api.posokanei.gov.gr',
                  style: PkText.mono(size: PkFont.xs, color: pk.textMuted),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Section header (title + optional trailing link) ─────────────────────────
class PkSectionHeader extends StatelessWidget {
  final String title;
  final String? linkLabel;
  final VoidCallback? onLink;
  const PkSectionHeader({super.key, required this.title, this.linkLabel, this.onLink});

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return Padding(
      padding: const EdgeInsets.only(bottom: PkSpace.x4 + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Text(title, style: PkText.display(size: PkFont.xl2 - 4, weight: FontWeight.w800, color: pk.textPrimary, tracking: -0.015)),
          ),
          if (linkLabel != null)
            PkTextLink(label: linkLabel!, onTap: onLink),
        ],
      ),
    );
  }
}

class PkTextLink extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  const PkTextLink({super.key, required this.label, this.onTap});
  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(PkRadius.sm),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label, style: PkText.label(size: PkFont.sm, color: pk.primary, weight: FontWeight.w600)),
            const SizedBox(width: 2),
            Icon(Icons.chevron_right, size: 16, color: pk.primary),
          ],
        ),
      ),
    );
  }
}

// ── Responsive grid (variable-height tiles via Wrap) ─────────────────────────
class PkResponsiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double gap;
  final int Function(double width) columnsFor;
  const PkResponsiveGrid({
    super.key,
    required this.children,
    this.gap = 18,
    required this.columnsFor,
  });

  /// Product grid: 4 / 3 / 2 columns by available width.
  static int products(double w) => w >= 1000 ? 4 : (w >= 680 ? 3 : 2);

  /// Category grid: up to 5 columns.
  static int categories(double w) => w >= 1040 ? 5 : (w >= 760 ? 4 : (w >= 520 ? 3 : 2));

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, c) {
        final cols = columnsFor(c.maxWidth).clamp(1, 6);
        final tileWidth = (c.maxWidth - gap * (cols - 1)) / cols;
        return Wrap(
          spacing: gap,
          runSpacing: gap,
          children: [
            for (final child in children) SizedBox(width: tileWidth, child: child),
          ],
        );
      },
    );
  }
}

// ── State views ──────────────────────────────────────────────────────────────
class PkErrorView extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;
  const PkErrorView({super.key, this.message = 'Κάτι πήγε στραβά. Δοκίμασε ξανά.', this.onRetry});
  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.cloud_off, size: 32, color: pk.textMuted),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center, style: PkText.body(size: PkFont.base, color: pk.textSecondary)),
          if (onRetry != null) ...[
            const SizedBox(height: 16),
            PkButton(label: 'Δοκίμασε ξανά', variant: PkButtonVariant.secondary, size: PkButtonSize.sm, onPressed: onRetry),
          ],
        ],
      ),
    );
  }
}

class PkEmptyView extends StatelessWidget {
  final IconData icon;
  final String? title;
  final String message;
  final Widget? action;
  final bool big;
  const PkEmptyView({super.key, this.icon = Icons.search, this.title, required this.message, this.action, this.big = false});
  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: big ? 90 : 60, horizontal: 20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: big ? 84 : 64,
            height: big ? 84 : 64,
            decoration: BoxDecoration(color: pk.surfaceSunken, shape: BoxShape.circle),
            child: Icon(icon, size: big ? 40 : 28, color: pk.textMuted),
          ),
          const SizedBox(height: 14),
          if (title != null) ...[
            Text(title!, style: PkText.display(size: PkFont.xl2 - 4, weight: FontWeight.w800, color: pk.textPrimary)),
            const SizedBox(height: 8),
          ],
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 360),
            child: Text(message, textAlign: TextAlign.center, style: PkText.body(size: PkFont.sm, color: pk.textMuted)),
          ),
          if (action != null) ...[const SizedBox(height: 18), action!],
        ],
      ),
    );
  }
}

// ── Product helpers ──────────────────────────────────────────────────────────
/// Friendly pack label from unit + unit_quantity (e.g. "400g", "1L", "1kg").
String? pkPackLabel(Product p) {
  final q = p.unitQuantity;
  final u = p.unit;
  if (q == null || u == null) return null;
  switch (u) {
    case 'kg':
      return q < 1 ? '${(q * 1000).round()}g' : '${_trim(q)}kg';
    case 'L':
      return q < 1 ? '${(q * 1000).round()}ml' : '${_trim(q)}L';
    case 'piece':
      return q == 1 ? '1 τεμ.' : '${_trim(q)} τεμ.';
    default:
      return '${_trim(q)} $u';
  }
}

String _trim(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

/// Builds a fully-wired [ProductCard] (tap → product detail).
Widget pkProductCard(BuildContext context, Product p, {String heroPrefix = 'grid'}) {
  final tag = 'product-$heroPrefix-${p.id}';
  return ProductCard(
    name: p.name,
    brand: p.brand,
    packSize: pkPackLabel(p),
    imageUrl: p.hasImage ? PkImages.display(p.imageUrl) : null,
    price: p.minPrice ?? 0,
    unitPrice: p.minUnitPrice ?? (p.minPrice ?? 0),
    unit: p.unit ?? 'kg',
    storeCount: p.storeCount,
    discountPct: p.bestDiscount,
    onTap: () => PkNavScope.of(context).openProduct(p, heroTag: tag),
    heroTag: tag,
  );
}

/// A grid of product-card skeletons that mirrors the real layout.
class PkProductGridSkeleton extends StatelessWidget {
  final int count;
  const PkProductGridSkeleton({super.key, this.count = 8});
  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    return PkResponsiveGrid(
      columnsFor: PkResponsiveGrid.products,
      children: List.generate(count, (_) {
        return Container(
          decoration: BoxDecoration(
            color: pk.surfaceRaised,
            borderRadius: BorderRadius.circular(PkRadius.card),
            border: Border.all(color: pk.borderSubtle),
            boxShadow: pk.shadowSm,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const AspectRatio(aspectRatio: 1, child: PkSkeleton()),
              Padding(
                padding: const EdgeInsets.fromLTRB(12, 12, 12, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    PkSkeleton(width: 60, height: 10, variant: PkSkeletonVariant.text),
                    SizedBox(height: 8),
                    PkSkeleton(height: 12, variant: PkSkeletonVariant.text),
                    SizedBox(height: 6),
                    PkSkeleton(width: 120, height: 12, variant: PkSkeletonVariant.text),
                    SizedBox(height: 14),
                    PkSkeleton(width: 90, height: 22),
                  ],
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}

/// Staggered fade+slide reveal for grid/list children on first paint.
class PkReveal extends StatelessWidget {
  final int index;
  final Widget child;
  const PkReveal({super.key, required this.index, required this.child});
  @override
  Widget build(BuildContext context) {
    final reduce = MediaQuery.of(context).disableAnimations;
    if (reduce) return child;
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: PkDur.slow + (PkDur.staggerStep * (index % 12)),
      curve: PkCurve.standard,
      builder: (context, t, c) => Opacity(
        opacity: t.clamp(0, 1),
        child: Transform.translate(offset: Offset(0, (1 - t) * 12), child: c),
      ),
      child: child,
    );
  }
}
