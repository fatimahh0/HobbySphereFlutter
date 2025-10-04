// import entity types used by the UI
import '../../domain/entities/user_activity_detail_entity.dart'; // entity classes

// DTO model that mirrors backend JSON for an item
class UserActivityDetailModel {
  final int id; // item id
  final String name; // item name
  final String? description; // item description
  final String itemTypeName; // type name
  final String? imageUrl; // image url (relative or absolute)
  final String location; // location text
  final double? latitude; // latitude (nullable)
  final double? longitude; // longitude (nullable)
  final DateTime startDatetime; // start datetime
  final DateTime endDatetime; // end datetime
  final num price; // price per person
  final int maxParticipants; // max seats
  final String status; // status text
  final Map<String, dynamic> business; // nested business map

  // model constructor
  UserActivityDetailModel({
    required this.id, // set id
    required this.name, // set name
    required this.description, // set desc
    required this.itemTypeName, // set type
    required this.imageUrl, // set img
    required this.location, // set location
    required this.latitude, // set lat
    required this.longitude, // set lng
    required this.startDatetime, // set start
    required this.endDatetime, // set end
    required this.price, // set price
    required this.maxParticipants, // set max
    required this.status, // set status
    required this.business, // set business map
  });

  // factory to build model from JSON
  factory UserActivityDetailModel.fromJson(Map<String, dynamic> j) {
    DateTime _dt(v) => DateTime.parse('$v'); // parse date
    double? _d(v) => v == null
        ? null // parse double?
        : (v is num ? v.toDouble() : double.tryParse('$v')); // try cast

    return UserActivityDetailModel(
      id: (j['id'] as num).toInt(), // id
      name: '${j['name'] ?? ''}', // name
      description: j['description'] as String?, // desc
      itemTypeName: '${j['itemTypeName'] ?? ''}', // type
      imageUrl: j['imageUrl'] as String?, // img
      location: '${j['location'] ?? ''}', // location
      latitude: _d(j['latitude']), // lat
      longitude: _d(j['longitude']), // lng
      startDatetime: _dt(j['startDatetime']), // start
      endDatetime: _dt(j['endDatetime']), // end
      price: (j['price'] as num), // price
      maxParticipants: (j['maxParticipants'] as num).toInt(), // max
      status: '${j['status'] ?? ''}', // status
      business:
          (j['business'] as Map?)?.cast<String, dynamic>() ?? {}, // business
    );
  }

  // convert model to UI entity (immutable classes for presentation)
  UserActivityDetailEntity toEntity() {
    final b = business; // alias
    return UserActivityDetailEntity(
      id: id, // id
      name: name, // name
      description: description, // desc
      typeName: itemTypeName, // type
      imageUrl: imageUrl, // img
      location: location, // loc
      latitude: latitude, // lat
      longitude: longitude, // lng
      start: startDatetime, // start
      end: endDatetime, // end
      price: price, // price
      maxParticipants: maxParticipants, // max
      status: status, // status
      business: UserBusinessMini(
        id: (b['id'] ?? 0) is num ? (b['id'] as num).toInt() : 0, // biz id
        name: '${b['businessName'] ?? ''}', // biz name
        logoUrl: b['businessLogoUrl'] as String?, // biz logo
        websiteUrl: b['websiteUrl'] as String?, // biz site
        description: b['description'] as String?, // biz desc
        stripeAccountId:
            b['stripeAccountId']
                as String?, // << NEW: connected account id for Stripe
      ),
    );
  }
}
