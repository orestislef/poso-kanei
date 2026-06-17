import 'package:flutter/foundation.dart' show kIsWeb;

/// Where the API lives.
///
/// On mobile/desktop the app talks to the public API directly. On the web it
/// goes through a **same-origin reverse proxy** at `/posokanei/api` — browsers
/// block cross-origin fetches without CORS headers (which this API doesn't
/// send), and CanvasKit also taints cross-origin images. The proxy makes both
/// data and images same-origin.
class ApiConfig {
  ApiConfig._();

  static const String directBase = 'https://api.posokanei.gov.gr';

  /// Same-origin proxy path on the web deployment (orestislef.gr/posokanei/).
  static const String webProxyPath = '/posokanei/api';

  /// Base URL for API calls and image URLs.
  static String get base =>
      kIsWeb ? '${Uri.base.origin}$webProxyPath' : directBase;

  /// Rewrite an absolute API URL (e.g. an image URL embedded in a payload) so
  /// it goes through the web proxy. No-op off the web or for foreign URLs.
  static String? rewrite(String? url) {
    if (url == null) return null;
    final v = url.trim();
    if (v.isEmpty) return null;
    if (kIsWeb && v.startsWith(directBase)) {
      return '$base${v.substring(directBase.length)}';
    }
    return v;
  }
}
