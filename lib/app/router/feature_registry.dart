import 'package:go_router/go_router.dart';
import 'package:hobby_sphere/app/app_config.dart';

import '../../core/feature/feature_module.dart';
import '../../features/activities/activities_module.dart';

final Map<String, FeatureModule> _featureMap = {
  'activity': ActivitiesModule(),
  // 'auth': AuthModule(),
  // 'payment': PaymentModule(),
};

List<FeatureModule> _modulesFor(AppKind kind, List<String> enabledKeys) {
  return enabledKeys
      .map((k) => _featureMap[k])
      .where((m) => m != null)
      .cast<FeatureModule>()
      .toList();
}

GoRouter buildComposedRouter({
  required AppKind kind,
  required List<String> enabledFeatures,
  required ToggleTheme onToggleTheme,
  required ChangeLocale onChangeLocale,
  required GetLocale getCurrentLocale,
}) {
  final modules = _modulesFor(kind, enabledFeatures);
  for (final m in modules) {
    m.registerDI();
  }

  final routes = <RouteBase>[];
  for (final m in modules) {
    routes.addAll(
      m.routes(
        onToggleTheme: onToggleTheme,
        onChangeLocale: onChangeLocale,
        getCurrentLocale: getCurrentLocale,
      ),
    );
  }

  return GoRouter(routes: routes);
}
