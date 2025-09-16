abstract class ExploreItemsEvent {
  const ExploreItemsEvent();
}

class ExploreItemsLoadAll extends ExploreItemsEvent {
  const ExploreItemsLoadAll();
}

class ExploreItemsLoadByType extends ExploreItemsEvent {
  final int typeId;
  const ExploreItemsLoadByType(this.typeId);
}

class ExploreItemsRefresh extends ExploreItemsEvent {
  const ExploreItemsRefresh();
}
