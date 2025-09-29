// #️⃣ Contact counters for conversation lists.
class ContactCount {
  final int contactId; // other user id
  final int count; // number

  const ContactCount({required this.contactId, required this.count}); // ctor

  factory ContactCount.fromMap(Map<String, dynamic> m) => ContactCount(
    contactId: (m['contactId'] as num).toInt(), // id
    count: (m['count'] as num).toInt(), // cnt
  );

  factory ContactCount.fromArray(List a) => ContactCount(
    contactId: (a[0] as num).toInt(), // id
    count: (a[1] as num).toInt(), // cnt
  );
}
