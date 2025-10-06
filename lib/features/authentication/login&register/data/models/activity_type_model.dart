// activity_type_model.dart
// Flutter 3.35.x — now maps Category JSON to your domain ActivityType.

import 'package:hobby_sphere/features/authentication/login&register/domain/entities/activity_type.dart';

class ActivityTypeModel {
  final int id; // category id
  final String name; // category name (e.g., "SPORTS")
  final String iconLib; // icon library (e.g., "Ionicons")
  final String icon; // icon key (e.g., "basketball")

  ActivityTypeModel({
    required this.id, // set id
    required this.name, // set name
    required this.iconLib, // set lib
    required this.icon, // set icon
  });

  // Build from Category JSON
  factory ActivityTypeModel.fromJson(Map<String, dynamic> json) {
    return ActivityTypeModel(
      id: (json['id'] as num).toInt(), // parse id
      name: (json['name'] as String?)?.trim() ?? '', // parse name
      iconLib:
          (json['iconLibrary'] as String?) // parse library
              ?.trim() ??
          'Ionicons',
      icon:
          (json['iconName'] as String?) // parse icon name
              ?.trim() ??
          'star',
    );
  }

  // Convert to domain entity used by your UI
  ActivityType toDomain() => ActivityType(
    id: id, // id
    name: name, // name
    iconLib: iconLib, // lib
    icon: icon, // icon
  );
}
