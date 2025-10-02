// user_min.dart — robust mapping for many possible image keys
class UserMin {
  final int id;
  final String firstName;
  final String lastName;
  final String? profileImageUrl;

  const UserMin({
    required this.id,
    required this.firstName,
    required this.lastName,
    this.profileImageUrl,
  });

  String get fullName => '$firstName $lastName';

  // Helper: normalize string and drop empty/"null"
  static String? _cleanStr(dynamic v) {
    if (v == null) return null;
    final s = v.toString().trim();
    if (s.isEmpty || s.toLowerCase() == 'null') return null;
    return s;
  }

  factory UserMin.fromMap(Map<String, dynamic> m) {
    // --- id ---
    final rawId = (m['id'] ?? m['userId'] ?? m['uid'] ?? 0) as num;

    // --- names ---
    final rawFirst = _cleanStr(
      m['firstName'] ?? m['firstname'] ?? m['first_name'],
    );
    final rawLast = _cleanStr(m['lastName'] ?? m['lastname'] ?? m['last_name']);
    final rawName = _cleanStr(m['name']);

    String first = rawFirst ?? '';
    String last = rawLast ?? '';
    if (first.isEmpty && last.isEmpty && rawName != null) {
      final parts = rawName.split(RegExp(r'\s+'));
      first = parts.isNotEmpty ? parts.first : '';
      last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    // --- image URL (support many backend variants) ---
    final img = _cleanStr(
      m['profileImageUrl'] ??
          m['profilePictureUrl'] ?? // ✅ NEW: common in friends/requests
          m['profilePicUrl'] ?? // ✅ extra
          m['profilePhotoUrl'] ??
          m['photoUrl'] ??
          m['imageUrl'] ??
          m['imageURL'] ?? // extra capitalization
          m['imagePath'] ?? // backend sometimes returns paths
          m['image'] ??
          m['avatar'] ??
          m['avatarUrl'] ??
          m['picture'] ??
          (m['user'] is Map
              ? (m['user'] as Map)['profilePictureUrl']
              : null), // nested
    );

    return UserMin(
      id: rawId.toInt(),
      firstName: first,
      lastName: last,
      profileImageUrl: img,
    );
  }

  @override
  String toString() =>
      'UserMin(id: $id, firstName: $firstName, lastName: $lastName, profileImageUrl: $profileImageUrl)';
}
