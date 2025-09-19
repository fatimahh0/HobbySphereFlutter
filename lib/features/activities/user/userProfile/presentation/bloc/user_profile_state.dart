// === BLoC states ===
import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart'; // entity

abstract class UserProfileState {
  const UserProfileState();
} // base

class UserProfileLoading extends UserProfileState {
  const UserProfileLoading();
} // spinner

class UserProfileError extends UserProfileState {
  // error
  final String message; // text
  const UserProfileError(this.message); // ctor
}

class UserProfileLoaded extends UserProfileState {
  // data
  final UserEntity user; // domain entity
  const UserProfileLoaded(this.user); // ctor

  UserProfileLoaded copyWith({UserEntity? user}) => // immutability helper
      UserProfileLoaded(user ?? this.user);
}
