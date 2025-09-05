import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/entities/business.dart';

abstract class BusinessProfileState extends Equatable {
  @override
  List<Object?> get props => [];
}

class BusinessProfileInitial extends BusinessProfileState {}

class BusinessProfileLoading extends BusinessProfileState {}

class BusinessProfileLoaded extends BusinessProfileState {
  final Business business;
  final bool? stripeConnected;

  BusinessProfileLoaded(this.business, {this.stripeConnected});

  @override
  List<Object?> get props => [business, stripeConnected ?? ''];
}

class BusinessProfileError extends BusinessProfileState {
  final String message;
  BusinessProfileError(this.message);

  @override
  List<Object?> get props => [message];
}
