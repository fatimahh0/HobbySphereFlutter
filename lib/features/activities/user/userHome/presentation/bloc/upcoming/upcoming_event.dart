abstract class UpcomingEvent {}

class UpcomingLoadRequested extends UpcomingEvent {
  final int? typeId;
  UpcomingLoadRequested({this.typeId});
}
