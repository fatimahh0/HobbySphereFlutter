import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/common/events/business_feed.dart';

// currency
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';

import 'business_home_event.dart';
import 'business_home_state.dart';

class BusinessHomeBloc extends Bloc<BusinessHomeEvent, BusinessHomeState> {
  final GetBusinessActivities _getList;
  final GetBusinessActivityById _getOne;
  final DeleteBusinessActivity _deleteOne;

  final GetCurrentCurrency _getCurrency; // ✅ added

  final String token;
  final int businessId;
  final bool optimisticDelete;

  StreamSubscription<BusinessEvent>? _feedSub;

  BusinessHomeBloc({
    required GetBusinessActivities getList,
    required GetBusinessActivityById getOne,
    required DeleteBusinessActivity deleteOne,
    required this.token,
    required this.businessId,
    this.optimisticDelete = false,
  }) : _getList = getList,
       _getOne = getOne,
       _deleteOne = deleteOne,
       _getCurrency = GetCurrentCurrency(
         CurrencyRepositoryImpl(CurrencyService()),
       ), // ✅ init currency usecase
       super(const BusinessHomeState()) {
    // Event handlers
    on<BusinessHomeStarted>(_onStarted);
    on<BusinessHomeRefreshed>(_onRefreshed);
    on<BusinessHomeViewRequested>(_onView);
    on<BusinessHomeEditRequested>(_onEdit);
    on<BusinessHomeDeleteRequested>(_onDelete);
    on<BusinessHomeFeedbackCleared>(_onClearFeedback);

    // External feed → local list updates
    on<BusinessHomeExternalCreated>(_onExternalCreated);
    on<BusinessHomeExternalUpdated>(_onExternalUpdated);
    on<BusinessHomeExternalDeleted>(_onExternalDeleted);

    // Subscribe to global bus
    _feedSub = BusinessFeed().stream.listen((e) {
      if (e is BusinessActivityCreated) {
        add(BusinessHomeExternalCreated(e.activity));
      } else if (e is BusinessActivityUpdated) {
        add(BusinessHomeExternalUpdated(e.activity));
      } else if (e is BusinessActivityDeleted) {
        add(BusinessHomeExternalDeleted(e.id));
      }
    });
  }

  // ===== handlers =====

  Future<void> _onStarted(
    BusinessHomeStarted event,
    Emitter<BusinessHomeState> emit,
  ) async {
    emit(state.copyWith(loading: true, message: null, error: null));
    try {
      final list = await _getList(businessId: businessId, token: token);

      // ✅ fetch currency
      final cur = await _getCurrency(token);

      emit(state.copyWith(loading: false, items: list, currency: cur.code));
    } catch (e) {
      emit(state.copyWith(loading: false, error: _err(e)));
    }
  }

  Future<void> _onRefreshed(
    BusinessHomeRefreshed event,
    Emitter<BusinessHomeState> emit,
  ) async {
    emit(state.copyWith(refreshing: true, message: null, error: null));
    try {
      final list = await _getList(businessId: businessId, token: token);

      // ✅ fetch currency again on refresh
      final cur = await _getCurrency(token);

      emit(state.copyWith(refreshing: false, items: list, currency: cur.code));
      event.ack?.complete();
    } catch (e) {
      emit(state.copyWith(refreshing: false, error: _err(e)));
      event.ack?.complete();
    }
  }

  Future<void> _onView(
    BusinessHomeViewRequested event,
    Emitter<BusinessHomeState> emit,
  ) async {
    try {
      await _getOne(token: token, id: event.id);
      emit(state.copyWith(message: 'Open details #${event.id}'));
    } catch (e) {
      emit(state.copyWith(error: _err(e)));
    }
  }

  Future<void> _onEdit(
    BusinessHomeEditRequested event,
    Emitter<BusinessHomeState> emit,
  ) async {
    try {
      await _getOne(token: token, id: event.id);
      emit(state.copyWith(message: 'Open edit #${event.id}'));
    } catch (e) {
      emit(state.copyWith(error: _err(e)));
    }
  }

  Future<void> _onDelete(
    BusinessHomeDeleteRequested event,
    Emitter<BusinessHomeState> emit,
  ) async {
    if (optimisticDelete) {
      final before = state.items;
      final after = before.where((a) => a.id != event.id).toList();
      emit(state.copyWith(items: after, message: null, error: null));
      try {
        await _deleteOne(token: token, id: event.id);
        emit(state.copyWith(message: 'Activity deleted'));
        BusinessFeed().emit(BusinessActivityDeleted(event.id));
      } catch (e) {
        emit(state.copyWith(items: before, error: _err(e)));
      }
      return;
    }

    try {
      await _deleteOne(token: token, id: event.id);
      final list = await _getList(businessId: businessId, token: token);
      emit(state.copyWith(items: list, message: 'Activity deleted'));
      BusinessFeed().emit(BusinessActivityDeleted(event.id));
    } catch (e) {
      emit(state.copyWith(error: _err(e)));
    }
  }

  void _onExternalCreated(
    BusinessHomeExternalCreated event,
    Emitter<BusinessHomeState> emit,
  ) {
    emit(state.copyWith(items: [event.activity, ...state.items]));
  }

  void _onExternalUpdated(
    BusinessHomeExternalUpdated event,
    Emitter<BusinessHomeState> emit,
  ) {
    final updated = state.items
        .map((a) => a.id == event.activity.id ? event.activity : a)
        .toList();
    emit(state.copyWith(items: updated));
  }

  void _onExternalDeleted(
    BusinessHomeExternalDeleted event,
    Emitter<BusinessHomeState> emit,
  ) {
    emit(
      state.copyWith(
        items: state.items.where((a) => a.id != event.id).toList(),
      ),
    );
  }

  void _onClearFeedback(
    BusinessHomeFeedbackCleared event,
    Emitter<BusinessHomeState> emit,
  ) {
    emit(state.copyWith(message: null, error: null));
  }

  String _err(Object e) {
    final s = e.toString();
    return s.length > 160 ? '${s.substring(0, 160)}…' : s;
  }

  @override
  Future<void> close() async {
    await _feedSub?.cancel();
    return super.close();
  }
}
