
import 'package:hobby_sphere/features/activities/user/userNotification/domain/entities/user_notification.dart';

class UserNotificationModel extends UserNotification {
  UserNotificationModel({
    required int id,
    required String message,
    required String typeCode,
    required String typeDescription,
    required DateTime createdAt,
    required bool read,
  }) : super(
         id: id,
         message: message,
         typeCode: typeCode,
         typeDescription: typeDescription,
         createdAt: createdAt,
         read: read,
       );

  factory UserNotificationModel.fromJson(Map<String, dynamic> json) {
    final rawId = json['id'];
    final id = rawId is num ? rawId.toInt() : int.tryParse('$rawId') ?? 0;

    // Some backends send nested notificationType; also accept flat keys
    final type = (json['notificationType'] as Map?) ?? const {};
    final typeCode = (type['code'] ?? json['typeCode'] ?? '').toString();
    final typeDescription =
        (type['description'] ?? json['typeDescription'] ?? '').toString();

    // createdAt: ISO or millis
    final rawCreated = json['createdAt'];
    DateTime createdAt;
    if (rawCreated is String) {
      createdAt =
          DateTime.tryParse(rawCreated) ??
          DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    } else if (rawCreated is num) {
      createdAt = DateTime.fromMillisecondsSinceEpoch(
        rawCreated.toInt(),
        isUtc: true,
      );
    } else {
      createdAt = DateTime.fromMillisecondsSinceEpoch(0, isUtc: true);
    }

    // read: bool | num | string
    final rawRead = json['read'];
    final read = switch (rawRead) {
      bool b => b,
      num n => n != 0,
      String s => s.toLowerCase() == 'true' || s == '1',
      _ => false,
    };

    return UserNotificationModel(
      id: id,
      message: (json['message'] ?? '').toString(),
      typeCode: typeCode,
      typeDescription: typeDescription,
      createdAt: createdAt,
      read: read,
    );
  }
}
