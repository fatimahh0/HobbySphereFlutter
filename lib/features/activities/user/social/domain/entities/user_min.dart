// A very small user model used by lists (id + names + avatar).
class UserMin {
  final int id; // user id
  final String firstName; // first name
  final String lastName; // last name
  final String? profileImageUrl; // optional avatar

  const UserMin({
    required this.id, // require id
    required this.firstName, // require first name
    required this.lastName, // require last name
    this.profileImageUrl, // optional avatar
  });

  // convenience getter → "First Last"
  String get fullName => '$firstName $lastName';

  // --- robust mapping (handles many backend shapes) ---
  factory UserMin.fromMap(Map<String, dynamic> m) {
    // 1) id under many keys
    final rawId = (m['id'] ?? m['userId'] ?? m['uid'] ?? 0) as num;

    // 2) first/last may be split or one "name"
    final rawFirst = (m['firstName'] ?? m['firstname'] ?? m['first_name']);
    final rawLast = (m['lastName'] ?? m['lastname'] ?? m['last_name']);
    final rawName = m['name']?.toString(); // whole name if provided

    // 3) if only "name" exists, split it
    String first = (rawFirst ?? '').toString();
    String last = (rawLast ?? '').toString();
    if (first.isEmpty &&
        last.isEmpty &&
        rawName != null &&
        rawName.isNotEmpty) {
      final parts = rawName.trim().split(RegExp(r'\s+')); // split by spaces
      first = parts.isNotEmpty ? parts.first : ''; // first word
      last = parts.length > 1 ? parts.sublist(1).join(' ') : ''; // rest
    }

    // 4) image key under many names
    final img =
        (m['profileImageUrl'] ??
                m['profilePhotoUrl'] ??
                m['photoUrl'] ??
                m['imageUrl'] ??
                m['avatar'] ??
                m['avatarUrl'] ??
                m['picture'])
            ?.toString(); // convert to string if present

    // 5) build object
    return UserMin(
      id: rawId.toInt(), // cast to int
      firstName: first, // safe first
      lastName: last, // safe last
      profileImageUrl: img, // any image key
    );
  }
}
