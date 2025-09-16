import 'package:hobby_sphere/features/activities/common/domain/entities/item_details.dart';

abstract class ExploreItemsState {
  const ExploreItemsState();
}

class ExploreItemsInitial extends ExploreItemsState {
  const ExploreItemsInitial();
}

class ExploreItemsLoading extends ExploreItemsState {
  final int? selectedTypeId;
  const ExploreItemsLoading({this.selectedTypeId});
}

class ExploreItemsLoaded extends ExploreItemsState {
  final List<ItemDetailsEntity> items;
  final int? selectedTypeId; // null = "All"
  const ExploreItemsLoaded(this.items, {this.selectedTypeId});
}

class ExploreItemsError extends ExploreItemsState {
  final String message;
  final int? selectedTypeId;
  const ExploreItemsError(this.message, {this.selectedTypeId});
}
