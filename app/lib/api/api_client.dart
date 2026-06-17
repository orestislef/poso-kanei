// HTTP client for the πόσο κάνει (poso-kanei) public read-only API.
//
// Pure Dart — no Flutter widgets. Greek text is decoded as UTF-8.

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'models.dart';

/// Thrown when the API returns a non-2xx response or the request fails.
class ApiException implements Exception {
  final int? statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() =>
      'ApiException(${statusCode ?? 'no status'}): $message';
}

class ApiClient {
  final http.Client _client;
  final String base;

  ApiClient({http.Client? client, this.base = 'https://api.posokanei.gov.gr'})
      : _client = client ?? http.Client();

  static const Duration _timeout = Duration(seconds: 20);

  /// Perform a GET request and return the decoded JSON body.
  ///
  /// Greek characters are decoded via [utf8] from the raw response bytes so
  /// they survive regardless of the server's charset reporting.
  Future<dynamic> _getJson(String path, [Map<String, String>? query]) async {
    final uri = Uri.parse('$base$path').replace(
      queryParameters: (query != null && query.isNotEmpty) ? query : null,
    );

    final http.Response response;
    try {
      response = await _client.get(
        uri,
        headers: const {'Accept': 'application/json'},
      ).timeout(_timeout);
    } catch (e) {
      throw ApiException(null, 'Request failed: $e');
    }

    if (response.statusCode != 200) {
      throw ApiException(
        response.statusCode,
        utf8.decode(response.bodyBytes, allowMalformed: true),
      );
    }

    return jsonDecode(utf8.decode(response.bodyBytes));
  }

  // -- Meta ------------------------------------------------------------------

  Future<Stats> fetchStats() async {
    final json = await _getJson('/meta/stats');
    return Stats.fromJson(Map<String, dynamic>.from(json as Map));
  }

  Future<List<Retailer>> fetchRetailers() async {
    final json = await _getJson('/meta/retailers');
    final raw = (json is Map) ? json['retailers'] : json;
    if (raw is! List) return const <Retailer>[];
    return raw
        .whereType<Map>()
        .map((e) => Retailer.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  Future<List<Category>> fetchCategoryTree({
    bool includeCounts = true,
    bool includeHidden = false,
  }) async {
    final json = await _getJson('/meta/categories/tree', {
      'include_counts': includeCounts.toString(),
      'include_hidden': includeHidden.toString(),
    });
    final raw = (json is Map) ? json['tree'] : json;
    if (raw is! List) return const <Category>[];
    return raw
        .whereType<Map>()
        .map((e) => Category.fromJson(Map<String, dynamic>.from(e)))
        .toList(growable: false);
  }

  // -- Products --------------------------------------------------------------

  /// List products with optional filters.
  ///
  /// Note: the server has no working sort/brand/country/price filters, so
  /// those are intentionally not sent.
  Future<Paginated<Product>> fetchProducts({
    String? category,
    String? query,
    String? retailer,
    bool? hasDiscount,
    bool? privateLabel,
    int page = 1,
    int pageSize = 20,
  }) async {
    final params = <String, String>{
      'page': page.toString(),
      'page_size': pageSize.toString(),
    };
    if (category != null) params['category'] = category;
    if (query != null) params['q'] = query;
    if (retailer != null) params['retailer'] = retailer;
    if (hasDiscount == true) params['has_discount'] = 'true';
    if (privateLabel == true) params['private_label'] = 'true';

    final json = await _getJson('/products', params);
    return Paginated<Product>.fromJson(
      Map<String, dynamic>.from(json as Map),
      Product.fromJson,
    );
  }

  Future<Product> fetchProduct(String id) async {
    final json = await _getJson('/products/$id');
    return Product.fromJson(Map<String, dynamic>.from(json as Map));
  }

  Future<PriceHistory> fetchHistory(String id) async {
    final json = await _getJson('/products/$id/history');
    return PriceHistory.fromJson(Map<String, dynamic>.from(json as Map));
  }

  void close() => _client.close();
}
