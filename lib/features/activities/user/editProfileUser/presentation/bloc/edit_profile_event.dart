import 'package:equatable/equatable.dart';

abstract class EditProfileEvent extends Equatable {
  const EditProfileEvent();
  @override
  List<Object?> get props => [];
}

class LoadEditProfile extends EditProfileEvent {
  final String token;
  final int userId;
  const LoadEditProfile(this.token, this.userId); // <-- positional
}


class SaveEditProfile extends EditProfileEvent {
  final String token;
  final int userId;
  final String firstName;
  final String lastName;
  final String? username;
  final String? email;
  final String? phoneNumber;
  final String? newPassword;
  final String? imagePath;
  final bool removeImage;
  const SaveEditProfile({
    required this.token,
    required this.userId,
    required this.firstName,
    required this.lastName,
    this.username,
    this.email,
    this.phoneNumber,
    this.newPassword,
    this.imagePath,
    this.removeImage = false,
  });
}

class DeleteProfileImagePressed extends EditProfileEvent {
  final String token;
  final int userId;
  const DeleteProfileImagePressed(this.token, this.userId);
}

class DeleteAccountPressed extends EditProfileEvent {
  final String token;
  final int userId;
  final String password;
  const DeleteAccountPressed(this.token, this.userId, this.password);
}
