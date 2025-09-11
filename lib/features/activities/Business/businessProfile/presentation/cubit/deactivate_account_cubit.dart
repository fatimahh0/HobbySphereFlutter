// presentation/cubit/deactivate_account_cubit.dart
import 'package:dio/dio.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart';


sealed class DeactivateState extends Equatable {
  @override
  List<Object?> get props => [];
}

class DeactivateIdle extends DeactivateState {}

class DeactivateSubmitting extends DeactivateState {}

class DeactivateSuccess extends DeactivateState {}

class DeactivateFailure extends DeactivateState {
  final String message;
  DeactivateFailure(this.message);
  @override
  List<Object?> get props => [message];
}

class DeactivateAccountCubit extends Cubit<DeactivateState> {
  final UpdateBusinessStatus updateStatus;
  DeactivateAccountCubit(this.updateStatus) : super(DeactivateIdle());

  Future<void> submit({
    required String token,
    required int businessId,
    required String password,
  }) async {
    emit(DeactivateSubmitting());
    try {
      await updateStatus(token, businessId, 'INACTIVE', password: password);
      emit(DeactivateSuccess());
    } on DioException catch (e) {
      final data = e.response?.data;
      final msg = (data is Map && data['error'] != null)
          ? data['error'].toString()
          : (data is Map && data['message'] != null)
          ? data['message'].toString()
          : (e.message ?? 'Network error');
      emit(DeactivateFailure(msg));
    } catch (e) {
      emit(DeactivateFailure(e.toString()));
    }
  }
}
