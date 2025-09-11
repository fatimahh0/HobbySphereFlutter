import 'package:equatable/equatable.dart';

class ManagerInviteResult extends Equatable {
  final bool success;
  final String message;

  const ManagerInviteResult({required this.success, required this.message});

  @override
  List<Object?> get props => [success, message];
}
