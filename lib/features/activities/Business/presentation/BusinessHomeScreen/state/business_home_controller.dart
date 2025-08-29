import "package:flutter/foundation.dart";
import "package:hobby_sphere/features/activities/Business/domain/entities/business_activity.dart";
import "package:hobby_sphere/features/activities/Business/domain/usecases/get_business_activities.dart";
import "package:hobby_sphere/features/activities/Business/domain/usecases/get_business_activity_by_id.dart";
import "package:hobby_sphere/features/activities/Business/domain/usecases/delete_business_activity.dart";

/// Immutable state snapshot for the Business Home screen.
class BusinessHomeState {
  final List<BusinessActivity> items;
  final bool loading;
  final bool refreshing;
  final String currency;

  const BusinessHomeState({
    this.items = const [],
    this.loading = false,
    this.refreshing = false,
    this.currency = "CAD",
  });

  BusinessHomeState copyWith({
    List<BusinessActivity>? items,
    bool? loading,
    bool? refreshing,
    String? currency,
  }) {
    return BusinessHomeState(
      items: items ?? this.items,
      loading: loading ?? this.loading,
      refreshing: refreshing ?? this.refreshing,
      currency: currency ?? this.currency,
    );
  }
}

/// Controller = where the presentation logic lives (no widgets).
/// UI listens to this controller and rebuilds via AnimatedBuilder.
class BusinessHomeController extends ChangeNotifier {
  final GetBusinessActivities _getList;
  final GetBusinessActivityById _getOne;
  final DeleteBusinessActivity _deleteOne;

  // Session context (owned by the screen, passed in here)
  final String token;
  final int businessId;

  BusinessHomeState _state = const BusinessHomeState();
  BusinessHomeState get state => _state;

  // Simple event callbacks for the UI to show snackbars/navigation
  void Function(String message)? onInfo;
  void Function(String message)? onError;

  BusinessHomeController({
    required GetBusinessActivities getList,
    required GetBusinessActivityById getOne,
    required DeleteBusinessActivity deleteOne,
    required this.token,
    required this.businessId,
  })  : _getList = getList,
        _getOne = getOne,
        _deleteOne = deleteOne;

  Future<void> load() async {
    _setLoading(true);
    try {
      final list = await _getList(businessId: businessId, token: token);
      _state = _state.copyWith(items: list, loading: false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      onError?.call("Load error: $e");
    }
  }

  Future<void> refresh() async {
    _state = _state.copyWith(refreshing: true);
    notifyListeners();
    try {
      final list = await _getList(businessId: businessId, token: token);
      _state = _state.copyWith(items: list, refreshing: false);
      notifyListeners();
    } catch (e) {
      _state = _state.copyWith(refreshing: false);
      notifyListeners();
      onError?.call("Refresh error: $e");
    }
  }

  Future<void> openDetails(int id) async {
    try {
      await _getOne(token: token, id: id);
      onInfo?.call("Open details #$id"); // UI can push route
    } catch (e) {
      onError?.call("Details error: $e");
    }
  }

  Future<void> openEdit(int id) async {
    try {
      await _getOne(token: token, id: id);
      onInfo?.call("Open edit #$id"); // UI can push route
    } catch (e) {
      onError?.call("Edit error: $e");
    }
  }

  Future<void> deleteActivity(int id) async {
    try {
      await _deleteOne(token: token, id: id);
      onInfo?.call("Deleted");
      await load(); // reload list after delete
    } catch (e) {
      onError?.call("Delete error: $e");
    }
  }

  void _setLoading(bool v) {
    _state = _state.copyWith(loading: v);
    notifyListeners();
  }
}
