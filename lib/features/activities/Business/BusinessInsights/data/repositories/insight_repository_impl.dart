import '../../domain/entities/insight_booking.dart';
import '../../domain/repositories/insight_repository.dart';
import '../services/insight_service.dart';

class InsightRepositoryImpl implements InsightRepository {
  final InsightService service;
  InsightRepositoryImpl(this.service);

  @override
  Future<List<InsightBooking>> getBookings(String token, int itemId) async {
    final res = await service.fetchBusinessBookings(token, itemId: itemId);
    final List data = res.data;

    return data.map((json) {
      final user = json["user"];
      final item = json["item"];
      return InsightBooking(
        id: json["id"],
        businessUserId: json["businessUserId"], // 👈 from backend
        clientName: user != null
            ? "${user["firstName"] ?? ""} ${user["lastName"] ?? ""}".trim()
            : json["bookedByName"] ?? "Unknown",
        itemName: item?["itemName"] ?? "N/A",
        wasPaid: json["wasPaid"] ?? false,
      );
    }).toList();
  }

  @override
  Future<void> markBookingPaid(String token, int bookingId) async {
    await service.markBookingPaid(token, bookingId);
  }
}
