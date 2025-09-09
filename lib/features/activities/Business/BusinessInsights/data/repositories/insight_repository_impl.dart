import '../../domain/entities/insight_booking.dart';
import '../../domain/repositories/insight_repository.dart';
import '../services/insight_service.dart';

class InsightRepositoryImpl implements InsightRepository {
  final InsightService service;
  InsightRepositoryImpl(this.service);

  @override
  Future<List<InsightBooking>> getBusinessBookings(String token) async {
    final res = await service.fetchBusinessBookings(token);
    final List data = res.data;
    return data.map((json) {
      final user = json["user"];
      final item = json["item"];
      return InsightBooking(
        id: json["id"],
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
