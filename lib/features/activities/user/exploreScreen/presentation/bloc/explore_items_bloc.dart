import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/bloc/explore_items_event.dart';
import 'package:hobby_sphere/features/activities/user/exploreScreen/presentation/bloc/explore_items_state.dart';
import 'package:hobby_sphere/features/activities/user/userHome/domain/usecases/get_upcoming_guest_items.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_items_by_type.dart';

class ExploreItemsBloc extends Bloc<ExploreItemsEvent, ExploreItemsState> {
  final GetUpcomingGuestItems getUpcomingGuest;
  final GetItemsByType getItemsByType;

  int? _selectedTypeId; // null = All

  ExploreItemsBloc({
    required this.getUpcomingGuest,
    required this.getItemsByType,
  }) : super(const ExploreItemsInitial()) {
    on<ExploreItemsLoadAll>(_onLoadAll);
    on<ExploreItemsLoadByType>(_onLoadByType);
    on<ExploreItemsRefresh>(_onRefresh);
  }

  Future<void> _onLoadAll(
    ExploreItemsLoadAll event,
    Emitter<ExploreItemsState> emit,
  ) async {
    if (_selectedTypeId == null && state is ExploreItemsLoaded) return;
    _selectedTypeId = null;
    emit(const ExploreItemsLoading(selectedTypeId: null));
    try {
      final items = await getUpcomingGuest();
      emit(ExploreItemsLoaded(items, selectedTypeId: _selectedTypeId));
    } catch (e) {
      emit(ExploreItemsError(e.toString(), selectedTypeId: _selectedTypeId));
    }
  }

  Future<void> _onLoadByType(
    ExploreItemsLoadByType event,
    Emitter<ExploreItemsState> emit,
  ) async {
    if (_selectedTypeId == event.typeId && state is ExploreItemsLoaded) return;
    _selectedTypeId = event.typeId;
    emit(ExploreItemsLoading(selectedTypeId: _selectedTypeId));
    try {
      final items = await getItemsByType(event.typeId);
      emit(ExploreItemsLoaded(items, selectedTypeId: _selectedTypeId));
    } catch (e) {
      emit(ExploreItemsError(e.toString(), selectedTypeId: _selectedTypeId));
    }
  }

  Future<void> _onRefresh(
    ExploreItemsRefresh event,
    Emitter<ExploreItemsState> emit,
  ) async {
    if (_selectedTypeId == null) {
      await _onLoadAll(const ExploreItemsLoadAll(), emit);
    } else {
      await _onLoadByType(ExploreItemsLoadByType(_selectedTypeId!), emit);
    }
  }
}
