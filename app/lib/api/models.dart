// Plain Dart model classes for the πόσο κάνει (poso-kanei) public API.
//
// All parsing is null-safe and robust:
//  - numbers may arrive as int OR double  -> parsed via _d() / (v as num).toDouble()
//  - strings may have leading/trailing spaces -> names are trimmed
//  - lists / maps may be missing -> default to empty collections
//
// No Flutter dependencies here — pure Dart.

// ---------------------------------------------------------------------------
// Private parsing helpers
// ---------------------------------------------------------------------------

double? _d(dynamic v) => v == null ? null : (v as num).toDouble();

DateTime? _dt(dynamic v) {
  if (v == null) return null;
  return DateTime.tryParse(v.toString());
}

String? _s(dynamic v) => v?.toString();

/// Trim a string value, returning null when absent.
String? _st(dynamic v) {
  if (v == null) return null;
  return v.toString().trim();
}

int _i(dynamic v, [int fallback = 0]) {
  if (v == null) return fallback;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString()) ?? fallback;
}

bool _b(dynamic v, [bool fallback = false]) {
  if (v == null) return fallback;
  if (v is bool) return v;
  if (v is num) return v != 0;
  final s = v.toString().toLowerCase().trim();
  if (s == 'true') return true;
  if (s == 'false') return false;
  return fallback;
}

List<String> _strList(dynamic v) {
  if (v is List) {
    return v
        .where((e) => e != null)
        .map((e) => e.toString())
        .toList(growable: false);
  }
  return const <String>[];
}

List<Map<String, dynamic>> _mapList(dynamic v) {
  if (v is List) {
    return v
        .whereType<Map>()
        .map((e) => Map<String, dynamic>.from(e))
        .toList(growable: false);
  }
  return const <Map<String, dynamic>>[];
}

// ---------------------------------------------------------------------------
// Stats — /meta/stats
// ---------------------------------------------------------------------------

class Stats {
  final int totalProducts;
  final int activeProducts;
  final int retailerCount;
  final int productsOnDiscount;
  final List<String> retailers;
  final DateTime? timestamp;

  const Stats({
    required this.totalProducts,
    required this.activeProducts,
    required this.retailerCount,
    required this.productsOnDiscount,
    required this.retailers,
    required this.timestamp,
  });

  factory Stats.fromJson(Map<String, dynamic> json) {
    return Stats(
      totalProducts: _i(json['total_products']),
      activeProducts: _i(json['active_products']),
      retailerCount: _i(json['retailer_count']),
      productsOnDiscount: _i(json['products_on_discount']),
      retailers: _strList(json['retailers']),
      timestamp: _dt(json['timestamp']),
    );
  }
}

// ---------------------------------------------------------------------------
// Retailer — /meta/retailers item
// ---------------------------------------------------------------------------

class Retailer {
  final String id;
  final String name;
  final String? country;

  /// Kept as returned by the API (may be relative, e.g. "/images/retailer/lidl").
  /// Use [PkImages.resolve] from images.dart to obtain an absolute URL.
  final String? logoUrl;
  final String? website;

  const Retailer({
    required this.id,
    required this.name,
    required this.country,
    required this.logoUrl,
    required this.website,
  });

  factory Retailer.fromJson(Map<String, dynamic> json) {
    return Retailer(
      id: _s(json['id']) ?? '',
      name: _st(json['name']) ?? '',
      country: _s(json['country']),
      logoUrl: _s(json['logo_url']),
      website: _s(json['website']),
    );
  }
}

// ---------------------------------------------------------------------------
// VatRate — value within effective_vat_rates
// ---------------------------------------------------------------------------

class VatRate {
  final double rate;
  final String source;
  final bool inherited;

  const VatRate({
    required this.rate,
    required this.source,
    required this.inherited,
  });

  factory VatRate.fromJson(Map<String, dynamic> json) {
    return VatRate(
      rate: _d(json['rate']) ?? 0.0,
      source: _s(json['source']) ?? '',
      inherited: _b(json['inherited']),
    );
  }
}

// ---------------------------------------------------------------------------
// Category — /meta/categories/tree node (recursive)
// ---------------------------------------------------------------------------

class Category {
  final String categoryId;
  final String name;
  final String? nameEn;
  final String? imageUrl;
  final int depth;
  final bool hidden;
  final int totalProductCount;
  final int productCount;
  final List<Category> children;

  const Category({
    required this.categoryId,
    required this.name,
    required this.nameEn,
    required this.imageUrl,
    required this.depth,
    required this.hidden,
    required this.totalProductCount,
    required this.productCount,
    required this.children,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    final rawChildren = _mapList(json['children']);
    return Category(
      categoryId: _s(json['category_id']) ?? '',
      name: _st(json['name']) ?? '',
      nameEn: _st(json['name_en']),
      imageUrl: _s(json['image_url']),
      depth: _i(json['depth']),
      hidden: _b(json['hidden']),
      totalProductCount: _i(json['total_product_count']),
      productCount: _i(json['product_count']),
      children:
          rawChildren.map(Category.fromJson).toList(growable: false),
    );
  }

  /// Primary display label — the Greek [name].
  String get displayName => name;

  /// Whether a distinct English name is available.
  bool get hasEnglish =>
      nameEn != null && nameEn!.trim().isNotEmpty && nameEn != name;
}

// ---------------------------------------------------------------------------
// PriceStats — price_stats object on a product
// ---------------------------------------------------------------------------

class PriceStats {
  final double? minPrice;
  final double? maxPrice;
  final double? avgPrice;
  final double? minUnitPrice;
  final int retailerCount;

  const PriceStats({
    required this.minPrice,
    required this.maxPrice,
    required this.avgPrice,
    required this.minUnitPrice,
    required this.retailerCount,
  });

  factory PriceStats.fromJson(Map<String, dynamic> json) {
    return PriceStats(
      minPrice: _d(json['min_price']),
      maxPrice: _d(json['max_price']),
      avgPrice: _d(json['avg_price']),
      minUnitPrice: _d(json['min_unit_price']),
      retailerCount: _i(json['retailer_count']),
    );
  }
}

// ---------------------------------------------------------------------------
// RetailerPrice — retailer_prices item on a product
// ---------------------------------------------------------------------------

class RetailerPrice {
  final String retailer;
  final String? retailerDisplayName;
  final double price;
  final double? priceNormalized;
  final bool isDiscount;
  final num? discountPercentage;
  final DateTime? lastUpdated;
  final String? country;

  const RetailerPrice({
    required this.retailer,
    required this.retailerDisplayName,
    required this.price,
    required this.priceNormalized,
    required this.isDiscount,
    required this.discountPercentage,
    required this.lastUpdated,
    required this.country,
  });

  factory RetailerPrice.fromJson(Map<String, dynamic> json) {
    return RetailerPrice(
      retailer: _s(json['retailer']) ?? '',
      retailerDisplayName: _st(json['retailer_display_name']),
      price: _d(json['price']) ?? 0.0,
      priceNormalized: _d(json['price_normalized']),
      isDiscount: _b(json['is_discount']),
      discountPercentage: json['discount_percentage'] as num?,
      lastUpdated: _dt(json['last_updated']),
      country: _s(json['country']),
    );
  }
}

// ---------------------------------------------------------------------------
// Product — list item or /products/<id>
// ---------------------------------------------------------------------------

class Product {
  final String id;
  final String name;
  final String? brand;
  final String? category;
  final String? subcategory;
  final String? description;
  final String? imageUrl;
  final String? unit;
  final List<String> categoryIds;
  final double? unitQuantity;
  final bool privateLabel;
  final bool hasImage;
  final bool isInternational;
  final DateTime? updatedAt;
  final List<String> availableCountries;
  final PriceStats? priceStats;
  final List<RetailerPrice> retailerPrices;

  const Product({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.subcategory,
    required this.description,
    required this.imageUrl,
    required this.unit,
    required this.categoryIds,
    required this.unitQuantity,
    required this.privateLabel,
    required this.hasImage,
    required this.isInternational,
    required this.updatedAt,
    required this.availableCountries,
    required this.priceStats,
    required this.retailerPrices,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    final psRaw = json['price_stats'];
    final rpRaw = _mapList(json['retailer_prices']);
    return Product(
      id: _s(json['id']) ?? '',
      name: _st(json['name']) ?? '',
      brand: _st(json['brand']),
      category: _st(json['category']),
      subcategory: _st(json['subcategory']),
      description: _st(json['description']),
      imageUrl: _s(json['image_url']),
      unit: _st(json['unit']),
      categoryIds: _strList(json['category_ids']),
      unitQuantity: _d(json['unit_quantity']),
      privateLabel: _b(json['private_label']),
      hasImage: _b(json['has_image']),
      isInternational: _b(json['is_international']),
      updatedAt: _dt(json['updated_at']),
      availableCountries: _strList(json['available_countries']),
      priceStats: psRaw is Map
          ? PriceStats.fromJson(Map<String, dynamic>.from(psRaw))
          : null,
      retailerPrices:
          rpRaw.map(RetailerPrice.fromJson).toList(growable: false),
    );
  }

  // -- convenience getters ---------------------------------------------------

  double? get minPrice => priceStats?.minPrice;

  double? get minUnitPrice => priceStats?.minUnitPrice;

  int get storeCount => retailerPrices.length;

  /// The largest discount percentage among discounted retailer prices, or null.
  num? get bestDiscount {
    num? best;
    for (final rp in retailerPrices) {
      if (!rp.isDiscount) continue;
      final d = rp.discountPercentage;
      if (d == null) continue;
      if (best == null || d > best) best = d;
    }
    return best;
  }

  /// Retailer prices sorted ascending by price (does not mutate the original).
  List<RetailerPrice> get sortedByPrice {
    final list = List<RetailerPrice>.from(retailerPrices);
    list.sort((a, b) => a.price.compareTo(b.price));
    return list;
  }
}

// ---------------------------------------------------------------------------
// History — /products/<id>/history
// ---------------------------------------------------------------------------

class HistoryPoint {
  final DateTime date;
  final double price;
  final String? country;

  const HistoryPoint({
    required this.date,
    required this.price,
    required this.country,
  });

  factory HistoryPoint.fromJson(Map<String, dynamic> json) {
    return HistoryPoint(
      date: _dt(json['date']) ?? DateTime.fromMillisecondsSinceEpoch(0),
      price: _d(json['price']) ?? 0.0,
      country: _s(json['country']),
    );
  }
}

class PriceHistory {
  final String? productName;
  final String? unit;
  final double? unitQuantity;
  final List<String> retailers;
  final Map<String, List<HistoryPoint>> dailyPrices;
  final DateTime? rangeStart;
  final DateTime? rangeEnd;
  final bool hasTimeseries;

  const PriceHistory({
    required this.productName,
    required this.unit,
    required this.unitQuantity,
    required this.retailers,
    required this.dailyPrices,
    required this.rangeStart,
    required this.rangeEnd,
    required this.hasTimeseries,
  });

  factory PriceHistory.fromJson(Map<String, dynamic> json) {
    final dailyRaw = json['daily_prices'];
    final daily = <String, List<HistoryPoint>>{};
    if (dailyRaw is Map) {
      dailyRaw.forEach((key, value) {
        final points = _mapList(value)
            .map(HistoryPoint.fromJson)
            .toList(growable: false);
        // Keep each retailer's series in chronological order.
        final sorted = List<HistoryPoint>.from(points)
          ..sort((a, b) => a.date.compareTo(b.date));
        daily[key.toString()] = sorted;
      });
    }

    final dateRange = json['date_range'];
    DateTime? start;
    DateTime? end;
    if (dateRange is Map) {
      start = _dt(dateRange['start']);
      end = _dt(dateRange['end']);
    }

    return PriceHistory(
      productName: _st(json['product_name']),
      unit: _st(json['unit']),
      unitQuantity: _d(json['unit_quantity']),
      retailers: _strList(json['retailers']),
      dailyPrices: daily,
      rangeStart: start,
      rangeEnd: end,
      hasTimeseries: _b(json['has_price_history_timeseries']),
    );
  }

  /// Prices for a single retailer [slug] in chronological (date) order.
  List<double> seriesFor(String slug) {
    final points = dailyPrices[slug];
    if (points == null || points.isEmpty) return const <double>[];
    return points.map((p) => p.price).toList(growable: false);
  }

  /// A merged "cheapest across all retailers" series in date order.
  ///
  /// Collects every distinct date present across all retailers, sorts them,
  /// and for each date computes the minimum price across all retailers using
  /// each retailer's last-known price on-or-before that date (carry-forward).
  /// Returns an empty list when there is no data.
  List<double> get cheapestSeries {
    if (dailyPrices.isEmpty) return const <double>[];

    // Collect and sort all distinct dates.
    final allDates = <DateTime>{};
    for (final series in dailyPrices.values) {
      for (final p in series) {
        allDates.add(p.date);
      }
    }
    if (allDates.isEmpty) return const <double>[];
    final dates = allDates.toList()..sort((a, b) => a.compareTo(b));

    final result = <double>[];
    for (final date in dates) {
      double? minOnDate;
      for (final series in dailyPrices.values) {
        // Last point on-or-before `date` (series already sorted ascending).
        double? carried;
        for (final p in series) {
          if (p.date.isAfter(date)) break;
          carried = p.price;
        }
        if (carried == null) continue;
        if (minOnDate == null || carried < minOnDate) minOnDate = carried;
      }
      if (minOnDate != null) result.add(minOnDate);
    }
    return result;
  }
}

// ---------------------------------------------------------------------------
// Paginated<T> — products listing wrapper
// ---------------------------------------------------------------------------

class Paginated<T> {
  final int total;
  final int page;
  final int pageSize;
  final int totalPages;
  final bool hasNext;
  final bool hasPrev;
  final List<T> items;

  const Paginated({
    required this.total,
    required this.page,
    required this.pageSize,
    required this.totalPages,
    required this.hasNext,
    required this.hasPrev,
    required this.items,
  });

  factory Paginated.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) itemFromJson, {
    String itemsKey = 'products',
  }) {
    final items = _mapList(json[itemsKey])
        .map(itemFromJson)
        .toList(growable: false);
    return Paginated<T>(
      total: _i(json['total']),
      page: _i(json['page'], 1),
      pageSize: _i(json['page_size']),
      totalPages: _i(json['total_pages']),
      hasNext: _b(json['has_next']),
      hasPrev: _b(json['has_prev']),
      items: items,
    );
  }
}
