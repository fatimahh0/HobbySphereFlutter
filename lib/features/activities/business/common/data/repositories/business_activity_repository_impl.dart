import 'package:flutter/material.dart'; // debug only (ok to keep)
import 'package:hobby_sphere/core/network/globals.dart' as g; // base url
import 'package:hobby_sphere/features/activities/business/common/domain/entities/business_activity.dart';
import 'package:hobby_sphere/features/activities/business/common/domain/repositories/business_activity_repository.dart';
import '../services/business_activity_service.dart';

/// Make image URL absolute for display
String? resolveApiImage(String? raw) {
  if (raw == null || raw.isEmpty) return null; // no url
  if (raw.startsWith('http://') ||
      raw.startsWith('https://')) // already absolute
    return raw;
  return '${g.serverRootNoApi()}$raw'; // prepend server root
}

class BusinessActivityRepositoryImpl implements BusinessActivityRepository {
  final BusinessActivityService service; // network service
  BusinessActivityRepositoryImpl(this.service); // inject

  BusinessActivity _map(Map<String, dynamic> e) {
    final id = (e['id'] as num?)?.toInt() ?? 0; // item id
    final name = (e['itemName'] ?? 'Unnamed').toString(); // title
    final description = (e['description'] ?? '').toString(); // description

    // ✅ robust status: accept either "Upcoming" string or {name: "Upcoming"}
    final status = (e['status'] is Map)
        ? (e['status']?['name'] ?? '').toString()
        : (e['status'] ?? '').toString();

    // ✅ businessId: accept flat "businessId" or nested "business.id"
    final businessId =
        (e['businessId'] as num?)?.toInt() ??
        (e['business']?['id'] as num?)?.toInt();

    // image url (absolute for UI)
    final imageUrl = resolveApiImage(e['imageUrl']?.toString());

    // item type id (for dropdown preselect)
    final itemTypeId =
        (e['itemType']?['id'] as num?)?.toInt() ??
        (e['itemTypeId'] as num?)?.toInt();

    // numbers
    final maxParticipants = (e['maxParticipants'] as num?)?.toInt() ?? 0; // max
    final price = (e['price'] as num?)?.toDouble() ?? 0.0; // price

    // dates
    DateTime? startDate;
    final sd = e['startDatetime'];
    if (sd is String) startDate = DateTime.tryParse(sd);
    DateTime? endDate;
    final ed = e['endDatetime'];
    if (ed is String) endDate = DateTime.tryParse(ed);

    // geo + address
    final lat = (e['latitude'] as num?)?.toDouble() ?? 0.0; // latitude
    final lng = (e['longitude'] as num?)?.toDouble() ?? 0.0; // longitude
    final address = (e['location'] ?? '').toString(); // address

    // ✅ return with businessId included
    return BusinessActivity(
      id: id, // id
      name: name, // title
      description: description, // description
      itemTypeId: itemTypeId, // type id
      status: status, // status
      imageUrl: imageUrl, // absolute url (for display)
      location: address, // address
      latitude: lat, // lat
      longitude: lng, // lng
      startDate: startDate, // start
      endDate: endDate, // end
      maxParticipants: maxParticipants, // max
      price: price, // price
      businessId: businessId, // ✅ the critical fix
    );
  }

  @override
  Future<List<BusinessActivity>> getActivitiesByBusiness({
    required int businessId,
    required String token,
  }) async {
    final list = await service.getActivitiesByBusiness(
      businessId: businessId, // call service
      token: token, // auth
    );
    return list
        .map<Map<String, dynamic>>(
          (e) => Map<String, dynamic>.from(e),
        ) // cast map
        .map(_map) // map to entity
        .toList(); // list of entity
  }

  @override
  Future<BusinessActivity> getById({
    required String token,
    required int id,
  }) async {
    final raw = await service.getBusinessActivityById(token, id); // load one
    return _map(Map<String, dynamic>.from(raw)); // map to entity
  }

  @override
  Future<void> delete({required String token, required int id}) {
    return service.deleteBusinessActivity(token, id); // delete
  }
}
