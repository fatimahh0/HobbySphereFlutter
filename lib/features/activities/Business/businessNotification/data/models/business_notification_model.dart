import '../../domain/entities/business_notification.dart';

// Model maps JSON <-> Entity
class BusinessNotificationModel extends BusinessNotification {
  BusinessNotificationModel({
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

  factory BusinessNotificationModel.fromJson(Map<String, dynamic> json) {
    return BusinessNotificationModel(
      id: json['id'] as int,
      message: json['message'] ?? '',
      typeCode: json['notificationType']?['code'] ?? '',
      typeDescription: json['notificationType']?['description'] ?? '',
      createdAt: DateTime.parse(json['createdAt']),
      read: json['read'] ?? false,
    );
  }
}
