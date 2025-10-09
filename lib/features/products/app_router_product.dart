// lib/features/products/app_router_product.dart
// Provides:
// 1) buildProductRouter()  -> standalone Product app router
// 2) buildProductRoutes()  -> feature routes for integration in the main app

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:hobby_sphere/app/router/router.dart'
    show Routes, ShellRouteArgs; // uses global route names + args
import 'package:hobby_sphere/core/constants/app_role.dart';

import 'package:hobby_sphere/features/products/homeScreen/presentation/screens/product_home_screen.dart';
import 'package:hobby_sphere/navigation/products/product_shell_bottom.dart';

// ---- type aliases to match your FeatureModule signature ----
typedef ToggleTheme = void Function();
typedef ChangeLocale = void Function(Locale);
typedef GetLocale = Locale Function();

/// -------------
/// Standalone router for the Product-only app
/// -------------
GoRouter buildProductRouter() {
  return GoRouter(
    // start at the product shell (you can change to Routes.productHome if you prefer)
    initialLocation: Routes.shell,
    routes: <RouteBase>[
      // Product shell with bottom navigation (independent from Activities shell)
      GoRoute(
        path: Routes.shell,
        name: Routes.shell,
        builder: (context, state) {
          // Read optional args (role/token/businessId); defaults keep it usable without args
          final args = state.extra is ShellRouteArgs
              ? state.extra as ShellRouteArgs
              : const ShellRouteArgs(
                  role: AppRole.user,
                  token: '',
                  businessId: 0,
                );

          return ProductShellBottom(
            role: args.role,
            token: args.token,
            businessId: args.businessId,
            onChangeLocale: (Locale p1) {},
            onToggleTheme: () {},
          );
        },
      ),

      // Plain product home route (can be pushed directly)
      GoRoute(
        path: Routes.productHome,
        name: Routes.productHome,
        builder: (_, __) => const ProductHomeScreen(),
      ),
    ],
    errorBuilder: (_, state) => _RouteErrorPage(
      message: state.error?.toString() ?? 'Unknown route error',
    ),
  );
}

/// -------------
/// Feature routes for the main super-app
/// -------------
/// Keep this list minimal (no shell here) to avoid clashing with the Activities shell.
List<RouteBase> buildProductRoutes({
  required ToggleTheme onToggleTheme,
  required ChangeLocale onChangeLocale,
  required GetLocale getCurrentLocale,
}) {
  return <RouteBase>[
    // Product Home
    GoRoute(
      path: Routes.productHome,
      name: Routes.productHome,
      builder: (_, __) => const ProductHomeScreen(),
    ),

    // Add more product feature routes here when needed, e.g.:
    // GoRoute(
    //   path: Routes.productDetails,
    //   name: Routes.productDetails,
    //   builder: (_, state) {
    //     final args = state.extra as ProductDetailsArgs;
    //     return ProductDetailsScreen(productId: args.productId);
    //   },
    // ),
  ];
}

// Small, friendly error page used by the standalone product router.
class _RouteErrorPage extends StatelessWidget {
  final String message;
  const _RouteErrorPage({required this.message, super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Routing Error'), centerTitle: true),
      body: Center(
        child: Container(
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: cs.errorContainer,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: tt.bodyMedium?.copyWith(
              color: cs.onErrorContainer,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }
}
