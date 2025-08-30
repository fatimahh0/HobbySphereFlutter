// DTO for create activity form
class NewActivityInput {
  final String activityName;
  final int activityType;
  final String description;
  final String location;
  final String status;
  final int maxParticipants;
  final double price;
  final String startDatetime; // ISO 8601 UTC
  final String endDatetime; // ISO 8601 UTC
  final String? imageUri;
  final double? latitude;
  final double? longitude;

  const NewActivityInput({
    required this.activityName,
    required this.activityType,
    required this.description,
    required this.location,
    required this.status,
    required this.maxParticipants,
    required this.price,
    required this.startDatetime,
    required this.endDatetime,
    this.imageUri,
    this.latitude,
    this.longitude,
  });

  Map<String, dynamic> toMap() => {
    'activityName': activityName,
    'activityType': activityType,
    'description': description,
    'location': location,
    'status': status,
    'maxParticipants': maxParticipants,
    'price': price,
    'startDatetime': startDatetime,
    'endDatetime': endDatetime,
    'imageUri': imageUri,
    'latitude': latitude,
    'longitude': longitude,
  };
}
