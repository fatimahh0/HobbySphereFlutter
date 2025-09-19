// UI business mini info (immutable)
class UserBusinessMini {
  final int id; // business id
  final String name; // business name
  final String? logoUrl; // logo url
  final String? websiteUrl; // website url
  final String? description; // description
  final String? stripeAccountId; // << NEW: Stripe connected account id

  const UserBusinessMini({
    required this.id, // set id
    required this.name, // set name
    this.logoUrl, // opt logo
    this.websiteUrl, // opt website
    this.description, // opt description
    this.stripeAccountId, // opt stripe account
  });
}

// UI entity for the full item details (immutable)
class UserActivityDetailEntity {
  final int id; // item id
  final String name; // item name
  final String? description; // description
  final String typeName; // type name
  final String? imageUrl; // image url
  final String location; // location
  final double? latitude; // lat
  final double? longitude; // lng
  final DateTime start; // start datetime
  final DateTime end; // end datetime
  final num price; // price per person
  final int maxParticipants; // max seats
  final String status; // status
  final UserBusinessMini business; // business mini

  const UserActivityDetailEntity({
    required this.id, // set id
    required this.name, // set name
    required this.description, // set desc
    required this.typeName, // set type
    required this.imageUrl, // set img
    required this.location, // set loc
    required this.latitude, // set lat
    required this.longitude, // set lng
    required this.start, // set start
    required this.end, // set end
    required this.price, // set price
    required this.maxParticipants, // set max
    required this.status, // set status
    required this.business, // set business
  });
}
