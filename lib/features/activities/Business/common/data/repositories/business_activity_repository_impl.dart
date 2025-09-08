import 'package:flutter/material.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/repositories/business_activity_repository.dart';
import '../services/business_activity_service.dart';

/// Helper: ensure image URLs are absolute
String? resolveApiImage(String? raw) {
  if (raw == null || raw.isEmpty) return null;

  // Already absolute (http/https)
  if (raw.startsWith('http://') || raw.startsWith('https://')) {
    return raw;
  }

  // Otherwise prepend server root (remove /api if present)
  return '${g.serverRootNoApi()}$raw';
}

class BusinessActivityRepositoryImpl implements BusinessActivityRepository {
  final BusinessActivityService service;
  BusinessActivityRepositoryImpl(this.service);

  BusinessActivity _map(Map<String, dynamic> e) {
    final id = (e['id'] as num?)?.toInt() ?? 0;
    final name = (e['itemName'] ?? 'Unnamed').toString();
    final status = (e['status'] ?? '').toString();

    // ✅ Fix image URL
    final imageUrl = resolveApiImage(e['imageUrl']?.toString());

    // item type id (used in dropdown preselection)
    final itemTypeId =
        (e['itemType']?['id'] as num?)?.toInt() ?? // nested
        (e['itemTypeId'] as num?)?.toInt();

    final description = (e['description'] ?? '').toString();
    final maxParticipants = (e['maxParticipants'] as num?)?.toInt() ?? 0;
    final price = (e['price'] as num?)?.toDouble() ?? 0.0;

    // Dates
    DateTime? startDate;
    final sd = e['startDatetime'];
    if (sd is String) startDate = DateTime.tryParse(sd);

    DateTime? endDate;
    final ed = e['endDatetime'];
    if (ed is String) endDate = DateTime.tryParse(ed);

    // Lat / Lng
    final lat = (e['latitude'] as num?)?.toDouble() ?? 0.0;
    final lng = (e['longitude'] as num?)?.toDouble() ?? 0.0;
    final address = (e['location'] ?? '').toString();

    return BusinessActivity(
      id: id,
      name: name,
      description: description,
      itemTypeId: itemTypeId,
      status: status,
      imageUrl: imageUrl, // ✅ always absolute
      location: address,
      latitude: lat,
      longitude: lng,
      startDate: startDate,
      endDate: endDate,
      maxParticipants: maxParticipants,
      price: price,
    );
  }

  @override
  Future<List<BusinessActivity>> getActivitiesByBusiness({
    required int businessId,
    required String token,
  }) async {
    final list = await service.getActivitiesByBusiness(
      businessId: businessId,
      token: token,
    );
    return list
        .map<Map<String, dynamic>>((e) => Map<String, dynamic>.from(e))
        .map(_map)
        .toList();
  }

  @override
  Future<BusinessActivity> getById({
    required String token,
    required int id,
  }) async {
    final raw = await service.getBusinessActivityById(token, id);
    return _map(Map<String, dynamic>.from(raw));
  }

  @override
  Future<void> delete({required String token, required int id}) {
    return service.deleteBusinessActivity(token, id);
  }
}
