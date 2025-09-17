import '../../domain/entities/user_activity_detail_entity.dart';

class UserActivityDetailModel {
  final int id;
  final String itemName;
  final String? description;
  final String itemTypeName;
  final String? imageUrl;
  final String location;
  final double? latitude;
  final double? longitude;
  final DateTime startDatetime;
  final DateTime endDatetime;
  final num price;
  final int maxParticipants;
  final String status;
  final Map<String, dynamic> business;

  UserActivityDetailModel({
    required this.id,
    required this.itemName,
    required this.description,
    required this.itemTypeName,
    required this.imageUrl,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.startDatetime,
    required this.endDatetime,
    required this.price,
    required this.maxParticipants,
    required this.status,
    required this.business,
  });

  factory UserActivityDetailModel.fromJson(Map<String, dynamic> j) {
    DateTime _dt(v) => DateTime.parse('$v');
    double? _d(v) =>
        v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

    return UserActivityDetailModel(
      id: (j['id'] as num).toInt(),
      itemName: '${j['itemName'] ?? ''}',
      description: j['description'] as String?,
      itemTypeName: '${j['itemTypeName'] ?? ''}',
      imageUrl: j['imageUrl'] as String?,
      location: '${j['location'] ?? ''}',
      latitude: _d(j['latitude']),
      longitude: _d(j['longitude']),
      startDatetime: _dt(j['startDatetime']),
      endDatetime: _dt(j['endDatetime']),
      price: (j['price'] as num),
      maxParticipants: (j['maxParticipants'] as num).toInt(),
      status: '${j['status'] ?? ''}',
      business: (j['business'] as Map?)?.cast<String, dynamic>() ?? {},
    );
  }

  UserActivityDetailEntity toEntity() {
    final b = business;
    return UserActivityDetailEntity(
      id: id,
      name: itemName,
      description: description,
      typeName: itemTypeName,
      imageUrl: imageUrl,
      location: location,
      latitude: latitude,
      longitude: longitude,
      start: startDatetime,
      end: endDatetime,
      price: price,
      maxParticipants: maxParticipants,
      status: status,
      business: UserBusinessMini(
        id: (b['id'] ?? 0) is num ? (b['id'] as num).toInt() : 0,
        name: '${b['businessName'] ?? ''}',
        logoUrl: b['businessLogoUrl'] as String?,
        websiteUrl: b['websiteUrl'] as String?,
        description: b['description'] as String?,
      ),
    );
  }
}
