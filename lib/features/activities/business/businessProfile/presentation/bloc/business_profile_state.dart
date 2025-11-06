// Flutter 3.35.x
// Business profile states — compact and clear.

import 'package:equatable/equatable.dart'; // for equality
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/entities/business.dart'; // business entity

// Base state
abstract class BusinessProfileState extends Equatable {
  @override
  List<Object?> get props => []; // no props by default
}

// Initial state (nothing loaded yet)
class BusinessProfileInitial extends BusinessProfileState {}

// Loading state (show spinner)
class BusinessProfileLoading extends BusinessProfileState {}

// Loaded state (data + optional Stripe flag)
class BusinessProfileLoaded extends BusinessProfileState {
  final Business business; // business data
  final bool? stripeConnected; // Stripe connected flag (optional)
  BusinessProfileLoaded(this.business, {this.stripeConnected}); // ctor

  @override
  List<Object?> get props => [business, stripeConnected ?? '']; // equality
}

// Error state (show message)
class BusinessProfileError extends BusinessProfileState {
  final String message; // error text
  BusinessProfileError(this.message); // ctor

  @override
  List<Object?> get props => [message]; // equality
}
