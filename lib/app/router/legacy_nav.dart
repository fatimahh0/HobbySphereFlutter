// Bridge so old LegacyNav.pushNamed(...) calls keep working with GoRouter.
//
// Works with BOTH:
//   • path strings: "/community/myposts"
//   • named routes: Routes.myPosts
//
// Example:
//   LegacyNav.pushNamed(context, Routes.userNotifications,
//     arguments: UserNotificationsRouteArgs(token: token),
//   );
//
// Or via the extension:
//   context.pushNamedCompat(Routes.userNotifications, extra: args);

import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

class LegacyNav {
  static Future<T?> pushNamed<T extends Object?>(
    BuildContext context,
    String routeNameOrPath, {
    Object? arguments,
  }) {
    final go = GoRouter.of(context);

    // If it looks like a path (starts with '/'), push by LOCATION.
    // Otherwise treat it as a NAMED route.
    if (routeNameOrPath.startsWith('/')) {
      return go.push<T>(routeNameOrPath, extra: arguments);
    } else {
      return go.pushNamed<T>(routeNameOrPath, extra: arguments);
    }
  }

  static Future<T?> pushReplacementNamed<T extends Object?>(
    BuildContext context,
    String routeNameOrPath, {
    Object? arguments,
  }) {
    final go = GoRouter.of(context);
    if (routeNameOrPath.startsWith('/')) {
      return go.pushReplacement<T>(routeNameOrPath, extra: arguments);
    } else {
      return go.pushReplacementNamed<T>(routeNameOrPath, extra: arguments);
    }
  }

  static void pushNamedAndRemoveUntil(
    BuildContext context,
    String routeNameOrPath,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    // In GoRouter the "clear stack and go here" equivalent is go/goNamed.
    final go = GoRouter.of(context);
    if (routeNameOrPath.startsWith('/')) {
      go.go(routeNameOrPath, extra: arguments);
    } else {
      go.goNamed(routeNameOrPath, extra: arguments);
    }
  }

  static void pop<T extends Object?>(BuildContext context, [T? result]) {
    GoRouter.of(context).pop(result);
  }
}

// Optional sugar to minimize diffs when replacing old calls
extension GoCompat on BuildContext {
  Future<T?> pushNamedCompat<T extends Object?>(
    String routeNameOrPath, {
    Object? extra,
  }) {
    final go = GoRouter.of(this);
    if (routeNameOrPath.startsWith('/')) {
      return go.push<T>(routeNameOrPath, extra: extra);
    } else {
      return go.pushNamed<T>(routeNameOrPath, extra: extra);
    }
  }

  Future<T?> replaceNamedCompat<T extends Object?>(
    String routeNameOrPath, {
    Object? extra,
  }) {
    final go = GoRouter.of(this);
    if (routeNameOrPath.startsWith('/')) {
      return go.pushReplacement<T>(routeNameOrPath, extra: extra);
    } else {
      return go.pushReplacementNamed<T>(routeNameOrPath, extra: extra);
    }
  }

  void goCompat(String routeNameOrPath, {Object? extra}) {
    final go = GoRouter.of(this);
    if (routeNameOrPath.startsWith('/')) {
      go.go(routeNameOrPath, extra: extra);
    } else {
      go.goNamed(routeNameOrPath, extra: extra);
    }
  }
}
