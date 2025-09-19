// === BLoC: orchestrates usecases + exposes states ===
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import '../../domain/usecases/get_user_profile.dart'; // UC
import '../../domain/usecases/toggle_user_visibility.dart'; // UC
import '../../domain/usecases/update_user_status.dart'; // UC
import 'user_profile_event.dart'; // events
import 'user_profile_state.dart'; // states

class UserProfileBloc extends Bloc<UserProfileEvent, UserProfileState> {
  final GetUserProfile getUser; // UC
  final ToggleUserVisibility toggleVisibility; // UC
  final UpdateUserStatus updateStatus; // UC

  UserProfileBloc({
    required this.getUser, // inject
    required this.toggleVisibility, // inject
    required this.updateStatus, // inject
  }) : super(const UserProfileLoading()) {
    // initial
    on<LoadUserProfile>(_onLoad); // handlers
    on<ToggleVisibilityPressed>(_onToggle);
    on<UpdateStatusPressed>(_onUpdateStatus);
  }

  Future<void> _onLoad(
    LoadUserProfile e,
    Emitter<UserProfileState> emit,
  ) async {
    emit(const UserProfileLoading()); // show spinner
    try {
      final user = await getUser(e.token, e.userId); // fetch
      emit(UserProfileLoaded(user)); // success
    } catch (err) {
      emit(UserProfileError(err.toString())); // error
    }
  }

  Future<void> _onToggle(
    ToggleVisibilityPressed e,
    Emitter<UserProfileState> emit,
  ) async {
    final prev = state; // keep prev
    if (prev is! UserProfileLoaded) return; // guard
    try {
      await toggleVisibility(e.token, e.newValue); // call
      add(LoadUserProfile(e.token, prev.user.id)); // refresh
    } catch (err) {
      emit(UserProfileError(err.toString())); // error
    }
  }

  Future<void> _onUpdateStatus(
    UpdateStatusPressed e,
    Emitter<UserProfileState> emit,
  ) async {
    try {
      await updateStatus(
        // call
        token: e.token,
        userId: e.userId,
        status: e.status,
        password: e.password,
      );
      add(LoadUserProfile(e.token, e.userId)); // refresh
    } catch (err) {
      emit(UserProfileError(err.toString())); // error
    }
  }
}
