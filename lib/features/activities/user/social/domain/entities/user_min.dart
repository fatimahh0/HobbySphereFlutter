// user_min.dart — extend image key detection
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

  factory UserMin.fromMap(Map<String, dynamic> m) {
    final rawId = (m['id'] ?? m['userId'] ?? m['uid'] ?? 0) as num;

    final rawFirst = (m['firstName'] ?? m['firstname'] ?? m['first_name']);
    final rawLast = (m['lastName'] ?? m['lastname'] ?? m['last_name']);
    final rawName = m['name']?.toString();

    String first = (rawFirst ?? '').toString();
    String last = (rawLast ?? '').toString();
    if (first.isEmpty &&
        last.isEmpty &&
        rawName != null &&
        rawName.isNotEmpty) {
      final parts = rawName.trim().split(RegExp(r'\s+'));
      first = parts.isNotEmpty ? parts.first : '';
      last = parts.length > 1 ? parts.sublist(1).join(' ') : '';
    }

    final img =
        (m['profileImageUrl'] ??
                m['profileImage'] ?? // ✅ new
                m['profilePhotoUrl'] ??
                m['photoUrl'] ??
                m['imageUrl'] ??
                m['imagePath'] ?? // ✅ new
                m['image'] ?? // ✅ new
                m['avatar'] ??
                m['avatarUrl'] ??
                m['picture'])
            ?.toString();

    return UserMin(
      id: rawId.toInt(),
      firstName: first,
      lastName: last,
      profileImageUrl: img,
    );
  }
}
