// Image URL helpers for the πόσο κάνει (poso-kanei) public API.
//
// The API serves images under absolute paths on the same host, and returns
// some references as relative paths (e.g. "/images/retailer/lidl"). On the web
// these are routed through the same-origin proxy (see [ApiConfig]).

import 'api_config.dart';

class PkImages {
  PkImages._();

  static String get _base => ApiConfig.base;

  /// Absolute URL for a product image, optionally cache-busted with [version].
  static String product(String id, {String? version}) =>
      '$_base/images/product/$id${version != null ? '?v=$version' : ''}';

  /// Absolute URL for a category image, optionally cache-busted with [version].
  static String category(String id, {String? version}) =>
      '$_base/images/category/$id${version != null ? '?v=$version' : ''}';

  /// Absolute URL for a retailer logo by slug.
  static String retailer(String slug) => '$_base/images/retailer/$slug';

  /// Rewrite an absolute image URL from a payload so it loads via the proxy on
  /// the web. Returns null for null/empty input.
  static String? display(String? url) => ApiConfig.rewrite(url);

  /// Resolve a possibly-relative image reference to a loadable URL.
  ///
  ///  - null / empty       -> null
  ///  - "http(s)://..."    -> rewritten through the proxy on web, else unchanged
  ///  - "/images/..." etc  -> prefixed with the (proxy-aware) base
  static String? resolve(String? maybeRelative) {
    if (maybeRelative == null) return null;
    final value = maybeRelative.trim();
    if (value.isEmpty) return null;
    if (value.startsWith('http://') || value.startsWith('https://')) {
      return ApiConfig.rewrite(value);
    }
    final path = value.startsWith('/') ? value : '/$value';
    return '$_base$path';
  }
}
