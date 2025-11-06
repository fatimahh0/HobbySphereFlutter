import 'dart:async';
import 'package:hobby_sphere/features/activities/business/common/domain/entities/business_activity.dart';

/// Base type for business feed events.
abstract class BusinessEvent {}

/// Emitted when a new activity is created.
class BusinessActivityCreated extends BusinessEvent {
  final BusinessActivity activity;
  BusinessActivityCreated(this.activity);
}

/// Emitted when an existing activity is updated.
class BusinessActivityUpdated extends BusinessEvent {
  final BusinessActivity activity;
  BusinessActivityUpdated(this.activity);
}

/// Emitted when an activity is deleted.
class BusinessActivityDeleted extends BusinessEvent {
  final int id;
  BusinessActivityDeleted(this.id);
}

/// Very small singleton event bus (broadcast Stream).
class BusinessFeed {
  BusinessFeed._();
  static final BusinessFeed _i = BusinessFeed._();
  factory BusinessFeed() => _i;

  final _ctrl = StreamController<BusinessEvent>.broadcast();

  Stream<BusinessEvent> get stream => _ctrl.stream;
  void emit(BusinessEvent e) => _ctrl.add(e);

  void dispose() => _ctrl.close();
}
