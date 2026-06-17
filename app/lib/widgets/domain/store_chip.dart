import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../api/images.dart';
import '../../theme/app_theme.dart';
import '../../theme/tokens.dart';

/// Retailer registry: slug → display name, monogram, brand background & foreground.
const Map<String, ({String name, String short, Color bg, Color fg})> kRetailers = {
  'sklavenitis': (name: 'Σκλαβενίτης', short: 'ΣΚ', bg: Color(0xFF0A4EA2), fg: Color(0xFFFFFFFF)),
  'ab_vasilopoulos': (name: 'ΑΒ Βασιλόπουλος', short: 'ΑΒ', bg: Color(0xFFE2001A), fg: Color(0xFFFFFFFF)),
  'masoutis': (name: 'Μασούτης', short: 'Μ', bg: Color(0xFFE30613), fg: Color(0xFFFFFFFF)),
  'mymarket': (name: 'My Market', short: 'MY', bg: Color(0xFFE6007E), fg: Color(0xFFFFFFFF)),
  'galaxias': (name: 'Γαλαξίας', short: 'Γ', bg: Color(0xFF005BAA), fg: Color(0xFFFFFFFF)),
  'kritikos': (name: 'Κρητικός', short: 'ΚΡ', bg: Color(0xFF1A7A3C), fg: Color(0xFFFFFFFF)),
  'market_in': (name: 'Market In', short: 'MI', bg: Color(0xFFE2231A), fg: Color(0xFFFFFFFF)),
  'synka': (name: 'ΣΥΝ.ΚΑ', short: 'ΣΚ', bg: Color(0xFFF7A800), fg: Color(0xFF1C1A16)),
  'halkiadakis': (name: 'Χαλκιαδάκης', short: 'X', bg: Color(0xFF0066B3), fg: Color(0xFFFFFFFF)),
  'lidl': (name: 'Lidl', short: 'L', bg: Color(0xFF0050AA), fg: Color(0xFFFDE100)),
  'alphamega': (name: 'AlphaMega', short: 'AM', bg: Color(0xFFE30613), fg: Color(0xFFFFFFFF)),
  'auchan': (name: 'Auchan', short: 'A', bg: Color(0xFFE2001A), fg: Color(0xFFFFFFFF)),
  'carrefour_it': (name: 'Carrefour', short: 'C', bg: Color(0xFF004E9E), fg: Color(0xFFFFFFFF)),
  'conad': (name: 'Conad', short: 'CO', bg: Color(0xFFE2001A), fg: Color(0xFFFFFFFF)),
  'colruyt': (name: 'Colruyt', short: 'CL', bg: Color(0xFFC8102E), fg: Color(0xFFFFFFFF)),
  'delhaize': (name: 'Delhaize', short: 'D', bg: Color(0xFFED1C24), fg: Color(0xFFFFFFFF)),
  'continente': (name: 'Continente', short: 'CT', bg: Color(0xFFE30613), fg: Color(0xFFFFFFFF)),
  'freshful': (name: 'Freshful', short: 'F', bg: Color(0xFF00A651), fg: Color(0xFFFFFFFF)),
  'ebag': (name: 'eBag', short: 'eB', bg: Color(0xFFED028C), fg: Color(0xFFFFFFFF)),
  'edeka24': (name: 'Edeka24', short: 'E', bg: Color(0xFFFFD100), fg: Color(0xFF1C1A16)),
};

enum PkStoreChipSize { sm, md, lg }

/// A retailer monogram square + optional name. Unknown slugs fall back to a
/// neutral square using the first two characters of the name/slug.
class StoreChip extends StatelessWidget {
  final String slug;
  final String? name;
  final PkStoreChipSize size;
  final bool showName;

  /// Render the real retailer logo (`/images/retailer/<slug>`) on a light tile,
  /// falling back to the colored monogram while loading or on error.
  /// Defaults to true so every market shows its real logo.
  final bool logo;

  const StoreChip({
    super.key,
    required this.slug,
    this.name,
    this.size = PkStoreChipSize.md,
    this.showName = true,
    this.logo = true,
  });

  double get _logoSize => switch (size) {
        PkStoreChipSize.sm => 24,
        PkStoreChipSize.md => 32,
        PkStoreChipSize.lg => 44,
      };

  double get _logoFont => switch (size) {
        PkStoreChipSize.sm => 11,
        PkStoreChipSize.md => 14,
        PkStoreChipSize.lg => 18,
      };

  @override
  Widget build(BuildContext context) {
    final pk = context.pk;
    final entry = kRetailers[slug];

    final Color bg;
    final Color fg;
    final String short;
    final String displayName;

    if (entry != null) {
      bg = entry.bg;
      fg = entry.fg;
      short = entry.short;
      displayName = name ?? entry.name;
    } else {
      bg = pk.borderStrong;
      fg = Colors.white;
      final source = (name ?? slug).trim();
      final taken = source.length >= 2 ? source.substring(0, 2) : source;
      short = taken.toUpperCase();
      displayName = name ?? slug;
    }

    final radius = BorderRadius.circular(
      size == PkStoreChipSize.lg ? PkRadius.md : PkRadius.sm,
    );

    Widget monogram() => Container(
          width: _logoSize,
          height: _logoSize,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: bg, borderRadius: radius),
          child: Text(
            short,
            textAlign: TextAlign.center,
            style: PkText.display(size: _logoFont, weight: FontWeight.w800, color: fg),
          ),
        );

    final Widget logoWidget = logo
        ? Container(
            width: _logoSize,
            height: _logoSize,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: radius,
              border: Border.all(color: pk.borderSubtle),
            ),
            clipBehavior: Clip.antiAlias,
            child: Padding(
              padding: EdgeInsets.all(_logoSize * 0.16),
              child: CachedNetworkImage(
                imageUrl: PkImages.retailer(slug),
                fit: BoxFit.contain,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (_, _) => monogram(),
                errorWidget: (_, _, _) => monogram(),
              ),
            ),
          )
        : monogram();

    if (!showName) return logoWidget;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        logoWidget,
        const SizedBox(width: PkSpace.x2),
        Flexible(
          child: Text(
            displayName,
            overflow: TextOverflow.ellipsis,
            style: PkText.label(
              size: PkFont.sm,
              weight: FontWeight.w600,
              color: pk.textPrimary,
            ),
          ),
        ),
      ],
    );
  }
}
