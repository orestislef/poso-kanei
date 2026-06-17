import 'package:go_router/go_router.dart';

import 'api/models.dart';
import 'i18n/lang.dart';
import 'screens/basket_screen.dart';
import 'screens/category_screen.dart';
import 'screens/home_screen.dart';
import 'screens/not_found_screen.dart';
import 'screens/product_screen.dart';
import 'screens/root_shell.dart';
import 'screens/stores_screen.dart';
import 'widgets/domain/store_chip.dart';

/// Extra payload when opening a product from a card (avoids a refetch + keeps
/// the Hero tag), or a category/store with a known display name.
class ProductArgs {
  final Product? product;
  final String? heroTag;
  const ProductArgs({this.product, this.heroTag});
}

/// The app router: clean, shareable, language-prefixed paths.
///
///   /el                      home            /en
///   /el/deals                deals
///   /el/stores               store directory
///   /el/basket               basket
///   /el/products             all products
///   /el/search?q=…           search results
///   /el/category/:id         a category
///   /el/store/:slug          a single retailer
///   /el/product/:id          a product
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: '/el',
    errorBuilder: (context, state) => const NotFoundScreen(),
    redirect: (context, state) {
      final segments = state.uri.pathSegments;
      // Ensure the first segment is a valid language; default to Greek.
      if (segments.isEmpty) return '/el';
      if (!Lang.isValid(segments.first)) {
        return '/el${state.uri.path}${state.uri.hasQuery ? '?${state.uri.query}' : ''}';
      }
      return null;
    },
    routes: [
      ShellRoute(
        builder: (context, state, child) => RootShell(state: state, child: child),
        routes: [
          GoRoute(
            path: '/:lang',
            builder: (context, state) => const HomeScreen(),
            routes: [
              GoRoute(
                path: 'deals',
                builder: (context, state) => CategoryScreen(
                  dealsOnly: true,
                  categoryName: _lang(state).code == 'en' ? 'Deals' : 'Προσφορές',
                ),
              ),
              GoRoute(
                path: 'stores',
                builder: (context, state) => const StoresScreen(),
              ),
              GoRoute(
                path: 'basket',
                builder: (context, state) => const BasketScreen(),
              ),
              GoRoute(
                path: 'products',
                builder: (context, state) => const CategoryScreen(),
              ),
              GoRoute(
                path: 'search',
                builder: (context, state) =>
                    CategoryScreen(query: state.uri.queryParameters['q'] ?? ''),
              ),
              GoRoute(
                path: 'category/:id',
                builder: (context, state) {
                  final name = state.extra is String ? state.extra as String : null;
                  return CategoryScreen(
                    categoryId: state.pathParameters['id'],
                    categoryName: name,
                  );
                },
              ),
              GoRoute(
                path: 'store/:slug',
                builder: (context, state) {
                  final slug = state.pathParameters['slug']!;
                  final name = state.extra is String
                      ? state.extra as String
                      : (kRetailers[slug]?.name ?? slug);
                  return CategoryScreen(retailer: slug, retailerName: name);
                },
              ),
              GoRoute(
                path: 'product/:id',
                builder: (context, state) {
                  final args = state.extra is ProductArgs ? state.extra as ProductArgs : null;
                  return ProductScreen(
                    productId: state.pathParameters['id'],
                    product: args?.product,
                    heroTag: args?.heroTag,
                  );
                },
              ),
            ],
          ),
        ],
      ),
    ],
  );
}

Lang _lang(GoRouterState state) =>
    Lang.fromCode(state.uri.pathSegments.isNotEmpty ? state.uri.pathSegments.first : 'el');
