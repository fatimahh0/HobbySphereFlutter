import 'package:hobby_sphere/features/activities/common/domain/entities/item_details.dart';

abstract class UpcomingState {
  const UpcomingState();
}

class UpcomingInitial extends UpcomingState {
  const UpcomingInitial();
}

class UpcomingLoading extends UpcomingState {
  const UpcomingLoading();
}

class UpcomingLoaded extends UpcomingState {
  final List<ItemDetailsEntity> items;
  const UpcomingLoaded(this.items);
}

class UpcomingError extends UpcomingState {
  final String message;
  const UpcomingError(this.message);
}
