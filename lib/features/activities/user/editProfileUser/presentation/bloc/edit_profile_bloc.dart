import 'package:dio/dio.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/delete_account_user.dart';
import 'package:hobby_sphere/features/activities/user/editProfileUser/domain/usecases/delete_edit_user_image.dart';
import '../../domain/usecases/get_edit_user.dart';
import '../../domain/usecases/update_edit_user.dart';

import 'edit_profile_event.dart';
import 'edit_profile_state.dart';

class EditProfileBloc extends Bloc<EditProfileEvent, EditProfileState> {
  final GetEditUser getUser;
  final UpdateEditUser updateUser;
  final DeleteEditUserImage deleteImage;
  final DeleteAccountUser deleteAccount;

  EditProfileBloc({
    required this.getUser,
    required this.updateUser,
    required this.deleteImage,
    required this.deleteAccount,
  }) : super(EditProfileLoading()) {
    on<LoadEditProfile>(_onLoad);
    on<SaveEditProfile>(_onSave);
    on<DeleteProfileImagePressed>(_onDeleteImage);
    on<DeleteAccountPressed>(_onDeleteAccount);
  }

  // ---------- Handlers ----------

  Future<void> _onLoad(
    LoadEditProfile e,
    Emitter<EditProfileState> emit,
  ) async {
    emit(EditProfileLoading());
    try {
      final u = await getUser(e.token, e.userId);
      emit(EditProfileLoaded(u));
    } catch (err) {
      emit(EditProfileError(_friendlyErr(err)));
      // keep a minimal safe state instead of a blank screen
      // (UI should already handle Error -> shows toast -> stays loaded from previous route)
    }
  }

  Future<void> _onSave(
    SaveEditProfile e,
    Emitter<EditProfileState> emit,
  ) async {
    final prev = state;
    try {
      await updateUser(
        token: e.token,
        userId: e.userId,
        firstName: e.firstName,
        lastName: e.lastName,
        username: e.username,
        email: e.email,
        phoneNumber: e.phoneNumber,
        newPassword: e.newPassword,
        imagePath: e.imagePath,
        removeImage: e.removeImage,
      );
      // re-fetch to reflect server truth
      final u = await getUser(e.token, e.userId);
      emit(EditProfileLoaded(u, updated: true));
    } catch (err) {
      emit(EditProfileError(_friendlyErr(err)));
      // keep screen usable
      if (prev is EditProfileLoaded) emit(prev);
    }
  }

  Future<void> _onDeleteImage(
    DeleteProfileImagePressed e,
    Emitter<EditProfileState> emit,
  ) async {
    final prev = state;
    if (prev is! EditProfileLoaded) return;
    try {
      await deleteImage(e.token, e.userId);
      // optimistic local update (no network re-fetch needed)
      final updatedUser = _copyUser(prev.user, profileImageUrl: null);
      emit(EditProfileLoaded(updatedUser, updated: true));
    } catch (err) {
      emit(EditProfileError(_friendlyErr(err)));
      // revert to previous loaded state so UI never collapses
      emit(prev);
    }
  }

  Future<void> _onDeleteAccount(
    DeleteAccountPressed e,
    Emitter<EditProfileState> emit,
  ) async {
    final prev = state;
    try {
      await deleteAccount(e.token, e.userId, e.password);
      // let caller navigate away; staying in Loading prevents user interaction
      emit(EditProfileLoading());
    } catch (err) {
      emit(EditProfileError(_friendlyErr(err)));
      if (prev is EditProfileLoaded) emit(prev);
    }
  }

  // ---------- Helpers ----------

  String _friendlyErr(Object err) {
    if (err is DioException) {
      final code = err.response?.statusCode;
      final data = err.response?.data;

      // Text response
      if (data is String && data.trim().isNotEmpty) {
        return data;
      }
      // JSON response with "message"/"error"
      if (data is Map) {
        final msg = (data['message'] ?? data['error'])?.toString();
        if (msg != null && msg.trim().isNotEmpty) return msg;
      }
      // Generic network message
      if (code != null) return 'Network error ($code)';
      return 'Network error';
    }
    return err.toString();
  }

  UserEntity _copyUser(
    UserEntity u, {
    String? username,
    String? firstName,
    String? lastName,
    String? email,
    String? phoneNumber,
    String? profileImageUrl,
    bool? isPublicProfile,
    String? status,
  }) {
    // If you already added a copyWith on UserEntity, replace this with u.copyWith(...)
    return UserEntity(
      id: u.id,
      username: username ?? u.username,
      firstName: firstName ?? u.firstName,
      lastName: lastName ?? u.lastName,
      email: email ?? u.email,
      phoneNumber: phoneNumber ?? u.phoneNumber,
      profileImageUrl: profileImageUrl ?? u.profileImageUrl,
      isPublicProfile: isPublicProfile ?? u.isPublicProfile,
      status: status ?? u.status,
    );
  }
}
