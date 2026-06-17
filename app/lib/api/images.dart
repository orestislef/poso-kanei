// Image URL helpers for the πόσο κάνει (poso-kanei) public API.
//
// The API serves images under absolute paths on the same host, and returns
// some image references as relative paths (e.g. "/images/retailer/lidl").
// These helpers build absolute URLs and resolve relative ones.

class PkImages {
  PkImages._();

  static const String base = 'https://api.posokanei.gov.gr';

  /// Absolute URL for a product image, optionally cache-busted with [version].
  static String product(String id, {String? version}) =>
      '$base/images/product/$id${version != null ? '?v=$version' : ''}';

  /// Absolute URL for a category image, optionally cache-busted with [version].
  static String category(String id, {String? version}) =>
      '$base/images/category/$id${version != null ? '?v=$version' : ''}';

  /// Absolute URL for a retailer logo by slug.
  static String retailer(String slug) => '$base/images/retailer/$slug';

  /// Resolve a possibly-relative image reference to an absolute URL.
  ///
  ///  - null              -> null
  ///  - "http(s)://..."   -> returned unchanged
  ///  - "/images/..." or "images/..." -> prefixed with [base]
  static String? resolve(String? maybeRelative) {
    if (maybeRelative == null) return null;
    final value = maybeRelative.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return value;
    }
    final path = value.startsWith('/') ? value : '/$value';
    return '$base$path';
  }
}
