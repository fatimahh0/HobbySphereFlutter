import 'package:hobby_sphere/features/activities/common/domain/entities/item_details.dart';

abstract class InterestState {
  const InterestState();
}

class InterestInitial extends InterestState {
  const InterestInitial();
}

class InterestLoading extends InterestState {
  const InterestLoading();
}

class InterestLoaded extends InterestState {
  final List<ItemDetailsEntity> items;
  const InterestLoaded(this.items);
}

class InterestError extends InterestState {
  final String message;
  const InterestError(this.message);
}
