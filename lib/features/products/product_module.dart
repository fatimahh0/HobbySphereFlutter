// lib/features/products/product_module.dart
import 'package:go_router/go_router.dart';
import 'package:hobby_sphere/features/products/app_router_product.dart';

import '../../core/feature/feature_module.dart' hide ToggleTheme, ChangeLocale, GetLocale;

class ProductModule implements FeatureModule {
  @override
  String get key => 'product';

  @override
  List<RouteBase> routes({
    required ToggleTheme onToggleTheme,
    required ChangeLocale onChangeLocale,
    required GetLocale getCurrentLocale,
  }) {
    return buildProductRoutes(
      onToggleTheme: onToggleTheme,
      onChangeLocale: onChangeLocale,
      getCurrentLocale: getCurrentLocale,
    );
  }

  @override
  void registerDI() {
    // Register repositories/blocs for products here when you add them.
    // e.g. getIt.registerLazySingleton<ProductRepo>(() => ProductRepoImpl(...));
  }
}
