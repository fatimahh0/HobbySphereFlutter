// Entity: immutable data for UI
class UserBusinessMini {
  final int id;
  final String name;
  final String? logoUrl;
  final String? websiteUrl;
  final String? description;

  const UserBusinessMini({
    required this.id,
    required this.name,
    this.logoUrl,
    this.websiteUrl,
    this.description,
  });
}

class UserActivityDetailEntity {
  final int id;
  final String name;
  final String? description;
  final String typeName;
  final String? imageUrl;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime start;
  final DateTime end;
  final num price;
  final int maxParticipants;
  final String status;
  final UserBusinessMini business;

  const UserActivityDetailEntity({
    required this.id,
    required this.name,
    required this.description,
    required this.typeName,
    required this.imageUrl,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.start,
    required this.end,
    required this.price,
    required this.maxParticipants,
    required this.status,
    required this.business,
  });
}
