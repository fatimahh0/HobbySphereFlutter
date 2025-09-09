import 'package:equatable/equatable.dart';
import '../../domain/entities/business_user.dart';

abstract class BusinessUsersState extends Equatable {
  const BusinessUsersState();

  @override
  List<Object?> get props => [];
}

class BusinessUsersInitial extends BusinessUsersState {}

class BusinessUsersLoading extends BusinessUsersState {}

class BusinessUsersLoaded extends BusinessUsersState {
  final List<BusinessUser> users;
  const BusinessUsersLoaded(this.users);

  @override
  List<Object?> get props => [users];
}

class BusinessUsersError extends BusinessUsersState {
  final String message;
  const BusinessUsersError(this.message);

  @override
  List<Object?> get props => [message];
}

/// 👇 State when booking is in progress
class BusinessUsersBooking extends BusinessUsersState {}

/// 👇 State when booking succeeds
class BusinessUserBookingSuccess extends BusinessUsersState {
  final Map<String, dynamic> booking;
  const BusinessUserBookingSuccess(this.booking);

  @override
  List<Object?> get props => [booking];
}
