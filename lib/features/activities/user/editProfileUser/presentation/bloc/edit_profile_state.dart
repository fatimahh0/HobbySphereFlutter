import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart';

abstract class EditProfileState extends Equatable {
  const EditProfileState();
  @override
  List<Object?> get props => [];
}

class EditProfileLoading extends EditProfileState {}

class EditProfileLoaded extends EditProfileState {
  final UserEntity user;
  final bool updated;
  const EditProfileLoaded(this.user, {this.updated = false});
  @override
  List<Object?> get props => [user, updated];
}

class EditProfileError extends EditProfileState {
  final String message;
  const EditProfileError(this.message);
}
