import 'dart:async';
import 'package:equatable/equatable.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/entities/business_activity.dart';

abstract class BusinessHomeEvent extends Equatable {
  const BusinessHomeEvent();
  @override
  List<Object?> get props => [];
}

/// Initial load.
class BusinessHomeStarted extends BusinessHomeEvent {
  const BusinessHomeStarted();
}

/// Pull-to-refresh. Pass a completer so the UI can await until done.
class BusinessHomeRefreshed extends BusinessHomeEvent {
  final Completer<void>? ack; // complete when refresh finishes
  const BusinessHomeRefreshed({this.ack});

  @override
  List<Object?> get props => [ack];
}

/// User taps “view”.
class BusinessHomeViewRequested extends BusinessHomeEvent {
  final int id;
  const BusinessHomeViewRequested(this.id);
  @override
  List<Object?> get props => [id];
}

/// User taps “edit”.
class BusinessHomeEditRequested extends BusinessHomeEvent {
  final int id;
  const BusinessHomeEditRequested(this.id);
  @override
  List<Object?> get props => [id];
}

/// User taps “delete”.
class BusinessHomeDeleteRequested extends BusinessHomeEvent {
  final int id;
  const BusinessHomeDeleteRequested(this.id);
  @override
  List<Object?> get props => [id];
}

/// Clear one-off messages/errors after the UI shows a toast/snack.
class BusinessHomeFeedbackCleared extends BusinessHomeEvent {
  const BusinessHomeFeedbackCleared();
}

/// ===== External feed → home list instant updates =====
/// These are dispatched internally by the bloc when it receives a bus event.

class BusinessHomeExternalCreated extends BusinessHomeEvent {
  final BusinessActivity activity;
  const BusinessHomeExternalCreated(this.activity);
  @override
  List<Object?> get props => [activity];
}

class BusinessHomeExternalUpdated extends BusinessHomeEvent {
  final BusinessActivity activity;
  const BusinessHomeExternalUpdated(this.activity);
  @override
  List<Object?> get props => [activity];
}

class BusinessHomeExternalDeleted extends BusinessHomeEvent {
  final int id;
  const BusinessHomeExternalDeleted(this.id);
  @override
  List<Object?> get props => [id];
}
