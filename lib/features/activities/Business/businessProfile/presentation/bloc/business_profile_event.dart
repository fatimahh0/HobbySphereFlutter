import 'package:equatable/equatable.dart';

abstract class BusinessProfileEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class LoadBusinessProfile extends BusinessProfileEvent {
  final String token;
  final int businessId;
  LoadBusinessProfile(this.token, this.businessId);

  @override
  List<Object?> get props => [token, businessId];
}

class ToggleVisibility extends BusinessProfileEvent {
  final String token;
  final int businessId;
  final bool isPublic;

  ToggleVisibility(this.token, this.businessId, this.isPublic);

  @override
  List<Object?> get props => [token, businessId, isPublic];
}

class ChangeStatus extends BusinessProfileEvent {
  final String token;
  final int businessId;
  final String status;
  final String? password;

  ChangeStatus(this.token, this.businessId, this.status, {this.password});

  @override
  List<Object?> get props => [token, businessId, status, password];
}

class DeleteBusinessEvent extends BusinessProfileEvent {
  final String token;
  final int businessId;
  final String password;

  DeleteBusinessEvent(this.token, this.businessId, this.password);

  @override
  List<Object?> get props => [token, businessId, password];
}


class CheckStripeStatusEvent extends BusinessProfileEvent {
  final String token;
  final int businessId;

  CheckStripeStatusEvent(this.token, this.businessId);

  @override
  List<Object?> get props => [token, businessId];
}
