import 'package:equatable/equatable.dart';

abstract class BusinessUsersEvent extends Equatable {
  const BusinessUsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadBusinessUsers extends BusinessUsersEvent {
  final String token;
  const LoadBusinessUsers(this.token);

  @override
  List<Object?> get props => [token];
}

class CreateBusinessUserEvent extends BusinessUsersEvent {
  final String token;
  final String firstname;
  final String lastname;
  final String? email;
  final String? phoneNumber;

  const CreateBusinessUserEvent({
    required this.token,
    required this.firstname,
    required this.lastname,
    this.email,
    this.phoneNumber,
  });

  @override
  List<Object?> get props => [token, firstname, lastname, email, phoneNumber];
}

/// 👇 New event for manual booking
class BookCashEvent extends BusinessUsersEvent {
  final String token;
  final int itemId;
  final int businessUserId;
  final int participants;
  final bool wasPaid;

  const BookCashEvent({
    required this.token,
    required this.itemId,
    required this.businessUserId,
    required this.participants,
    required this.wasPaid,
  });

  @override
  List<Object?> get props => [
    token,
    itemId,
    businessUserId,
    participants,
    wasPaid,
  ];
}
