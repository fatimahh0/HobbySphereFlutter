import '../../domain/entities/activity_type.dart'; // domain entity

// raw DTO from API
class ActivityTypeModel {
  final int id; // id
  final String name; // name
  final String iconLib; // lib
  final String icon; // icon

  ActivityTypeModel({
    required this.id, // ctor
    required this.name,
    required this.iconLib,
    required this.icon,
  });

  // parse from json map
  factory ActivityTypeModel.fromJson(Map<String, dynamic> json) {
    return ActivityTypeModel(
      id: (json['id'] as num).toInt(), // ensure int
      name: json['name'] as String, // name
      iconLib: (json['iconLib'] as String?) ?? 'Icons', // default lib
      icon: (json['icon'] as String?) ?? 'star', // default icon
    );
  }

  // map to domain
  ActivityType toDomain() => ActivityType(
    id: id, // id
    name: name, // name
    iconLib: iconLib, // lib
    icon: icon, // icon
  );
}
