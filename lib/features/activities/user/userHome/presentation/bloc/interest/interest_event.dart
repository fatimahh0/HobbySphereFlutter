abstract class InterestEvent {}

class InterestLoadRequested extends InterestEvent {
  final String token;
  final int userId;
  InterestLoadRequested({required this.token, required this.userId});
}
