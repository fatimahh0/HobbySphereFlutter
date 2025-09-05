import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_banner.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_business.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/delete_logo.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/get_business_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/editBusinessProfile/domain/usecases/update_business.dart';

import 'edit_business_event.dart';
import 'edit_business_state.dart';

class EditBusinessBloc extends Bloc<EditBusinessEvent, EditBusinessState> {
  final GetBusinessById getBusinessById;
  final UpdateBusiness updateBusiness;
  final DeleteBusiness deleteBusiness;
  final DeleteLogo deleteLogo;
  final DeleteBanner deleteBanner;

  EditBusinessBloc({
    required this.getBusinessById,
    required this.updateBusiness,
    required this.deleteBusiness,
    required this.deleteLogo,
    required this.deleteBanner,
  }) : super(EditBusinessInitial()) {
    on<LoadBusiness>(_onLoad);
    on<SaveBusiness>(_onSave);
    on<RemoveLogo>(_onRemoveLogo);
    on<RemoveBanner>(_onRemoveBanner);
    on<DeleteBusinessEvent>(_onDeleteBusiness);
  }

  Future<void> _onLoad(LoadBusiness e, Emitter emit) async {
    emit(EditBusinessLoading());
    try {
      final business = await getBusinessById(e.token, e.id);
      emit(EditBusinessLoaded(business));
    } catch (err) {
      emit(EditBusinessError(err.toString()));
    }
  }

  Future<void> _onSave(SaveBusiness e, Emitter emit) async {
    emit(EditBusinessLoading());
    try {
      await updateBusiness(e.token, e.id, e.body, withImages: e.withImages);
      final business = await getBusinessById(e.token, e.id);
      emit(EditBusinessLoaded(business, updated: true)); // 👈
    } catch (err) {
      emit(EditBusinessError(err.toString()));
    }
  }

  Future<void> _onRemoveLogo(RemoveLogo e, Emitter emit) async {
    emit(EditBusinessLoading());
    try {
      await deleteLogo(e.token, e.id);
      final business = await getBusinessById(e.token, e.id);
      emit(EditBusinessLoaded(business, updated: true)); // 👈
    } catch (err) {
      emit(EditBusinessError(err.toString()));
    }
  }

  Future<void> _onRemoveBanner(RemoveBanner e, Emitter emit) async {
    emit(EditBusinessLoading());
    try {
      await deleteBanner(e.token, e.id);
      final business = await getBusinessById(e.token, e.id);
      emit(EditBusinessLoaded(business, updated: true)); // 👈
    } catch (err) {
      emit(EditBusinessError(err.toString()));
    }
  }

  Future<void> _onDeleteBusiness(DeleteBusinessEvent e, Emitter emit) async {
    emit(EditBusinessLoading());
    try {
      await deleteBusiness(e.token, e.id, e.password);
      emit(EditBusinessInitial());
    } catch (err) {
      emit(EditBusinessError(err.toString()));
    }
  }
}
