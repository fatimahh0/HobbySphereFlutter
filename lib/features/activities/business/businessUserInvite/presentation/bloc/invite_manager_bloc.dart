import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/usecases/send_manager_invite.dart';
import 'invite_manager_event.dart';
import 'invite_manager_state.dart';

class InviteManagerBloc extends Bloc<InviteManagerEvent, InviteManagerState> {
  final SendManagerInvite sendInvite;

  InviteManagerBloc({required this.sendInvite})
    : super(const InviteManagerState()) {
    on<InviteEmailChanged>((e, emit) {
      emit(
        state.copyWith(
          email: e.email,
          emailErrorCode: validateEmailCode(e.email),
          successMessage: null,
          error: null,
        ),
      );
    });

    on<InviteSubmitted>(_onSubmit);
  }

  Future<void> _onSubmit(
    InviteSubmitted e,
    Emitter<InviteManagerState> emit,
  ) async {
    final code = validateEmailCode(state.email);
    if (code != null) {
      emit(
        state.copyWith(emailErrorCode: code, error: null, successMessage: null),
      );
      return;
    }

    emit(state.copyWith(submitting: true, error: null, successMessage: null));

    final res = await sendInvite(
      token: e.token,
      businessId: e.businessId,
      email: state.email.trim(),
    );

    emit(
      state.copyWith(
        submitting: false,
        successMessage: res.success ? res.message : null,
        error: res.success ? null : res.message,
      ),
    );
  }
}
