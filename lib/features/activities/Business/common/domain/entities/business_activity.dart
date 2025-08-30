class BusinessActivity {
  final int id;
  final String name;
  final String type;
  final DateTime? startDate;
  final int maxParticipants;
  final double price;
  final String status;
  final String? imageUrl;

  const BusinessActivity({
    required this.id,
    required this.name,
    required this.type,
    required this.startDate,
    required this.maxParticipants,
    required this.price,
    required this.status,
    required this.imageUrl,
  });
}
