import "package:flutter/foundation.dart";
import "package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart";
import "package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart";
import "package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart";
import "package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart";

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

class BusinessHomeController extends ChangeNotifier {
  final GetBusinessActivities _getList;
  final GetBusinessActivityById _getOne;
  final DeleteBusinessActivity _deleteOne;

  final String token;
  final int businessId;

  BusinessHomeState _state = const BusinessHomeState();
  BusinessHomeState get state => _state;

  // UI callbacks (toast/banner/router)
  void Function(String message)? onInfo;
  void Function(String message)? onError;

  // guards
  bool _isDisposed = false;
  bool _loadingInFlight = false;
  bool _refreshInFlight = false;

  // toggle if you want instant UX for delete
  final bool optimisticDelete;

  BusinessHomeController({
    required GetBusinessActivities getList,
    required GetBusinessActivityById getOne,
    required DeleteBusinessActivity deleteOne,
    required this.token,
    required this.businessId,
    this.optimisticDelete = false,
  }) : _getList = getList,
       _getOne = getOne,
       _deleteOne = deleteOne;

       
  

  // ---- public API -----------------------------------------------------------


  Future<void> load() async {
    if (_loadingInFlight) return;
    _loadingInFlight = true;
    _setLoading(true);
    try {
      final list = await _getList(businessId: businessId, token: token);
      _state = _state.copyWith(items: list);
      _safeNotify();
    } catch (e) {
      onError?.call("Load error: ${_err(e)}");
    } finally {
      _setLoading(false);
      _loadingInFlight = false;
    }
  }

  Future<void> refresh() async {
    if (_refreshInFlight) return;
    _refreshInFlight = true;
    _setRefreshing(true);
    try {
      final list = await _getList(businessId: businessId, token: token);
      _state = _state.copyWith(items: list);
      _safeNotify();
    } catch (e) {
      onError?.call("Refresh error: ${_err(e)}");
    } finally {
      _setRefreshing(false);
      _refreshInFlight = false;
    }
  }

  Future<void> openDetails(int id) async {
    try {
      await _getOne(token: token, id: id);
      onInfo?.call("Open details #$id");
    } catch (e) {
      onError?.call("Details error: ${_err(e)}");
    }
  }

  Future<void> openEdit(int id) async {
    try {
      await _getOne(token: token, id: id);
      onInfo?.call("Open edit #$id");
    } catch (e) {
      onError?.call("Edit error: ${_err(e)}");
    }
  }

  Future<void> deleteActivity(int id) async {
    if (optimisticDelete) {
      // optimistic path (instant UX + rollback on failure)
      final before = _state.items;
      final after = before.where((a) => a.id != id).toList();
      _state = _state.copyWith(items: after);
      _safeNotify();

      try {
        await _deleteOne(token: token, id: id);
        onInfo?.call("Activity deleted");
      } catch (e) {
        // rollback
        _state = _state.copyWith(items: before);
        _safeNotify();
        onError?.call("Delete error: ${_err(e)}");
      }
      return;
    }

    // safe path (reload after delete; message after list is fresh)
    try {
      await _deleteOne(token: token, id: id);
      await load();
      onInfo?.call("Activity deleted");
    } catch (e) {
      onError?.call("Delete error: ${_err(e)}");
    }
  }

  // ---- internals -----------------------------------------------------------

  void _setLoading(bool v) {
    _state = _state.copyWith(loading: v);
    _safeNotify();
  }

  void _setRefreshing(bool v) {
    _state = _state.copyWith(refreshing: v);
    _safeNotify();
  }

  String _err(Object e) {
    // normalize Dio/HTTP/domain errors into a small readable string
    final s = e.toString();
    // Trim common prefixes if you want
    return s.length > 140 ? "${s.substring(0, 140)}…" : s;
  }

  void _safeNotify() {
    if (!_isDisposed) notifyListeners();
  }

  @override
  void dispose() {
    _isDisposed = true;
    super.dispose();
  }
}
