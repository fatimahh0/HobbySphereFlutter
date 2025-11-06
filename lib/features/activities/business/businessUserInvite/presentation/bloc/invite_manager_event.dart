import 'package:equatable/equatable.dart';

abstract class InviteManagerEvent extends Equatable {
  const InviteManagerEvent();
  @override
  List<Object?> get props => [];
}

class InviteEmailChanged extends InviteManagerEvent {
  final String email;
  const InviteEmailChanged(this.email);
  @override
  List<Object?> get props => [email];
}

class InviteSubmitted extends InviteManagerEvent {
  final String token;
  final int businessId;
  const InviteSubmitted({required this.token, required this.businessId});
}
