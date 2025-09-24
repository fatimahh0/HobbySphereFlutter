import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/usecases/get_unread_notifications.dart';

class UnreadState {
  final int count;
  final bool loading;
  final String? error;
  const UnreadState({this.count = 0, this.loading = false, this.error});
  UnreadState copyWith({int? count, bool? loading, String? error}) =>
      UnreadState(
        count: count ?? this.count,
        loading: loading ?? this.loading,
        error: error,
      );
}

class UnreadCubit extends Cubit<UnreadState> {
  final GetUnreadNotifications getUnread;
  UnreadCubit(this.getUnread) : super(const UnreadState());

  Future<void> refresh(String token) async {
    try {
      emit(state.copyWith(loading: true, error: null));
      final c = await getUnread(token);
      emit(state.copyWith(count: c, loading: false));
    } catch (e) {
      emit(state.copyWith(loading: false, error: e.toString()));
    }
  }
}
