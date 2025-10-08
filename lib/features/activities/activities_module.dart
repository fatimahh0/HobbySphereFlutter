import 'package:go_router/go_router.dart';
import '../../core/feature/feature_module.dart';
import 'routes_activity.dart';

class ActivitiesModule implements FeatureModule {
  @override
  String get key => 'activity';

  @override
  List<RouteBase> routes({
    required ToggleTheme onToggleTheme,
    required ChangeLocale onChangeLocale,
    required GetLocale getCurrentLocale,
  }) {
    return buildActivityRoutes(
      onToggleTheme: onToggleTheme,
      onChangeLocale: onChangeLocale,
      getCurrentLocale: getCurrentLocale,
    );
  }

  @override
  void registerDI() {
    // register repos/blocs if you use get_it
  }
}
