import 'package:flutter/foundation.dart'; // @immutable

// one interest/activity from backend
@immutable
class ActivityType {
  final int id; // unique id
  final String name; // display name (e.g., SPORTS)
  final String iconLib; // icon library (e.g., Ionicons)
  final String icon; // icon key (e.g., basketball)

  const ActivityType({
    required this.id, // set id
    required this.name, // set name
    required this.iconLib, // set lib
    required this.icon, // set icon
  });
}
