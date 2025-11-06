// Flutter 3.35.x
// Business profile events — simple and clean.

import 'package:equatable/equatable.dart'; // for value equality

// Base class for all events
abstract class BusinessProfileEvent extends Equatable {
  @override
  List<Object?> get props => []; // no props by default
}

// Load profile event
class LoadBusinessProfile extends BusinessProfileEvent {
  final String token; // auth token
  final int businessId; // business id to load
  LoadBusinessProfile(this.token, this.businessId); // ctor

  @override
  List<Object?> get props => [token, businessId]; // equality list
}

// Toggle public/private profile event
class ToggleVisibility extends BusinessProfileEvent {
  final String token; // auth token
  final int businessId; // business id
  final bool isPublic; // target visibility
  ToggleVisibility(this.token, this.businessId, this.isPublic); // ctor

  @override
  List<Object?> get props => [token, businessId, isPublic]; // equality list
}

// Change status (e.g., ACTIVE → INACTIVE) event
class ChangeStatus extends BusinessProfileEvent {
  final String token; // auth token
  final int businessId; // business id
  final String status; // target status
  final String? password; // optional password for INACTIVE
  ChangeStatus(
    this.token,
    this.businessId,
    this.status, {
    this.password,
  }); // ctor

  @override
  List<Object?> get props => [token, businessId, status, password]; // equality
}

// Delete business event
class DeleteBusinessEvent extends BusinessProfileEvent {
  final String token; // auth token
  final int businessId; // business id
  final String password; // password required by backend
  DeleteBusinessEvent(this.token, this.businessId, this.password); // ctor

  @override
  List<Object?> get props => [token, businessId, password]; // equality
}

// Check Stripe status event
class CheckStripeStatusEvent extends BusinessProfileEvent {
  final String token; // auth token
  final int businessId; // business id
  CheckStripeStatusEvent(this.token, this.businessId); // ctor

  @override
  List<Object?> get props => [token, businessId]; // equality
}

// NEW: user pressed "Register on Stripe"
class ConnectStripePressed extends BusinessProfileEvent {
  final String token; // auth token
  final int businessId; // business id
  ConnectStripePressed({required this.token, required this.businessId}); // ctor

  @override
  List<Object?> get props => [token, businessId]; // equality
}
