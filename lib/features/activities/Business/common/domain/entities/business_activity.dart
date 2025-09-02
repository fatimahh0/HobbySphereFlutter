// Flutter 3.35.x
// BusinessActivity — robust entity used by Home + Edit.

class BusinessActivity {
  final int id;
  final int? itemTypeId;
  final int? businessId;

  final String name;
  final String description;
  final String? type;

  final String location;
  final double latitude;
  final double longitude;

  final int maxParticipants;
  final double price;

  final DateTime? startDate;
  final DateTime? endDate;

  final String status;
  final String? imageUrl;

  const BusinessActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.location,
    required this.latitude,
    required this.longitude,
    required this.maxParticipants,
    required this.price,
    required this.status,
    this.itemTypeId,
    this.businessId,
    this.type,
    this.imageUrl,
    this.startDate,
    this.endDate,
  });

  // --- helpers ---------------------------------------------------------------
  static double _toD(dynamic v) {
    if (v == null) return 0.0;
    if (v is num) return v.toDouble();
    if (v is String) return double.tryParse(v.trim()) ?? 0.0;
    return 0.0;
  }

  static int _toI(dynamic v) {
    if (v == null) return 0;
    if (v is num) return v.toInt();
    if (v is String) return int.tryParse(v.trim()) ?? 0;
    return 0;
  }

  static DateTime? _toDt(dynamic v) {
    if (v == null) return null;
    if (v is DateTime) return v;
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    if (v is String) return DateTime.tryParse(v.trim());
    return null;
  }

  // --- factory ---------------------------------------------------------------
  factory BusinessActivity.fromMap(Map<String, dynamic> m) {
    final int id = _toI(m['id']);

    final int? bizId =
        (m['businessId'] as num?)?.toInt() ??
        (m['business']?['id'] as num?)?.toInt();

    final int? typeId =
        (m['itemTypeId'] as num?)?.toInt() ??
        (m['itemType']?['id'] as num?)?.toInt();

    final String? typeName =
        m['itemType']?['activity_type']?.toString() ??
        m['itemTypeName']?.toString();

    final String title = (m['itemName'] ?? m['name'] ?? 'Unnamed').toString();
    final String desc = (m['description'] ?? '').toString();
    final String loc = (m['location'] ?? '').toString();

    final double lat = _toD(m['latitude']);
    final double lng = _toD(m['longitude']);

    final int max = _toI(m['maxParticipants']);
    final double price = _toD(m['price']);

    final DateTime? start = _toDt(m['startDatetime']);
    final DateTime? end = _toDt(m['endDatetime']);

    return BusinessActivity(
      id: id,
      name: title,
      description: desc,
      location: loc,
      latitude: lat,
      longitude: lng,
      maxParticipants: max,
      price: price,
      status: (m['status']?['name'] ?? m['status'] ?? 'ACTIVE').toString(),
      imageUrl: m['imageUrl']?.toString(),
      startDate: start,
      endDate: end,
      itemTypeId: typeId,
      businessId: bizId,
      type: typeName,
    );
  }
}
