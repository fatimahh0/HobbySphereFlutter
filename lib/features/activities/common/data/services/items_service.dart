// ///// HTTP service for items filtered by type (guest endpoint)
import 'package:hobby_sphere/config/env.dart'; // <-- NEW
import 'package:hobby_sphere/core/network/api_fetch.dart' as net;
import 'package:hobby_sphere/core/network/api_methods.dart';

class ItemsService {
  final net.ApiFetch _fetch = net.ApiFetch();

  String get _oplIdStr {
    final raw = Env.ownerProjectLinkId.trim();
    assert(raw.isNotEmpty, 'OWNER_PROJECT_LINK_ID is required.');
    return raw;
  }

  Map<String, dynamic> _withOwner([Map<String, dynamic>? q]) =>
      <String, dynamic>{...?q, 'ownerProjectLinkId': _oplIdStr};

  Future<List<Map<String, dynamic>>> getByType(int typeId) async {
    final res = await _fetch.fetch(
      HttpMethod.get,
      '/items/by-type/$typeId',
      data: _withOwner(), // <-- inject
    );

    final data = res.data;
    if (data is List) {
      return data.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    }
    return <Map<String, dynamic>>[];
  }
}
