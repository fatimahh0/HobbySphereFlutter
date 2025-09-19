// === Small cubit used inside dialog to submit password ===
import 'package:flutter_bloc/flutter_bloc.dart'; // cubit
import '../../domain/usecases/update_user_status.dart'; // uc

sealed class DeactivateUserState {} // base

class DeactivateIdle extends DeactivateUserState {} // idle

class DeactivateSubmitting extends DeactivateUserState {} // loading

class DeactivateSuccess extends DeactivateUserState {} // ok

class DeactivateFailure extends DeactivateUserState {
  // error
  final String message; // error text
  DeactivateFailure(this.message); // ctor
}

class DeactivateUserCubit extends Cubit<DeactivateUserState> {
  final UpdateUserStatus usecase; // dep

  DeactivateUserCubit(this.usecase) : super(DeactivateIdle()); // start

  Future<void> submit({
    required String token, // bearer
    required int userId, // id
    required String password, // current password
  }) async {
    emit(DeactivateSubmitting()); // spinner
    try {
      await usecase(
        // call uc
        token: token,
        userId: userId,
        status: 'INACTIVE',
        password: password,
      );
      emit(DeactivateSuccess()); // ok
    } catch (e) {
      emit(DeactivateFailure('$e')); // show error
    }
  }
}
