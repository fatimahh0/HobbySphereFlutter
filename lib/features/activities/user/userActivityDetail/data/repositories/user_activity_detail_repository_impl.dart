import '../../domain/entities/user_activity_detail_entity.dart';
import '../../domain/repositories/user_activity_detail_repository.dart';
import '../models/user_activity_detail_model.dart';
import '../services/user_activity_detail_service.dart';

class UserActivityDetailRepositoryImpl implements UserActivityDetailRepository {
  final UserActivityDetailService svc;
  UserActivityDetailRepositoryImpl(this.svc);

  @override
  Future<UserActivityDetailEntity> getById(int id) async {
    final json = await svc.getById(id);
    return UserActivityDetailModel.fromJson(json).toEntity();
  }

  @override
  Future<bool> checkAvailability({
    required int itemId,
    required int participants,
    required String bearerToken,
  }) {
    return svc.checkAvailability(
      itemId: itemId,
      participants: participants,
      bearerToken: bearerToken,
    );
  }

  @override
  Future<int> confirmBooking({
    required int itemId,
    required int participants,
    required String stripePaymentId,
    required String bearerToken,
  }) {
    return svc.confirmBooking(
      itemId: itemId,
      participants: participants,
      stripePaymentId: stripePaymentId,
      bearerToken: bearerToken,
    );
  }
}
