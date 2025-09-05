import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/entities/business.dart';

abstract class EditBusinessState extends Equatable {
  @override
  List<Object?> get props => [];
}

class EditBusinessInitial extends EditBusinessState {}

class EditBusinessLoading extends EditBusinessState {}

class EditBusinessLoaded extends EditBusinessState {
  final Business business;
  final bool updated; // default false

  EditBusinessLoaded(this.business, {this.updated = false});

  @override
  List<Object?> get props => [business, updated];
}

class EditBusinessError extends EditBusinessState {
  final String message;
  EditBusinessError(this.message);
  @override
  List<Object?> get props => [message];
}
