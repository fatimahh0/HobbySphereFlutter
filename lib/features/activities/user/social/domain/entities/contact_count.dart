// A small DTO for counts like /count/by-contact and /unread/by-contact.
class ContactCount {
  final int contactId; // user id of the other contact
  final int count; // number of messages

  const ContactCount({required this.contactId, required this.count});

  factory ContactCount.fromMap(Map<String, dynamic> m) => ContactCount(
    contactId: (m['contactId'] as num).toInt(), // server returns id
    count: (m['count'] as num).toInt(), // server returns count
  );

  // Some endpoints return a 2-item array [contactId, count], handle it too.
  factory ContactCount.fromArray(List a) => ContactCount(
    contactId: (a[0] as num).toInt(),
    count: (a[1] as num).toInt(),
  );
}
