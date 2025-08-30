import 'package:flutter/foundation.dart';
import '../../domain/entities/new_activity_input.dart';
import '../../domain/usecases/create_business_activity.dart';
import '../../domain/usecases/get_activity_types.dart';

class CreateBusinessActivityController extends ChangeNotifier {
  final CreateBusinessActivity createUsecase;
  final GetActivityTypes getTypesUsecase;

  CreateBusinessActivityController({
    required this.createUsecase,
    required this.getTypesUsecase,
  });

  // form fields
  String title = '';
  int? typeId;
  String description = '';
  String location = '';
  String status = 'ACTIVE';
  int maxParticipants = 1;
  double price = 0;

  double? latitude;
  double? longitude;
  DateTime? startAt;
  DateTime? endAt;
  String? imagePath;

  // ui state
  bool loading = false;
  String? error;
  Map<String, dynamic>? created;

  // dropdown data
  List<dynamic> activityTypes = [];
  bool loadingTypes = false;

  Future<void> loadTypes(String token) async {
    loadingTypes = true;
    error = null;
    notifyListeners();
    try {
      activityTypes = await getTypesUsecase(token: token);
      // if you want to preselect:
      if (activityTypes.isNotEmpty && typeId == null) {
        // assuming each type item has {id, name}
        final first = activityTypes.first;
        if (first is Map && first['id'] != null) {
          typeId = (first['id'] as num).toInt();
        }
      }
    } catch (e) {
      error = 'Failed to load types: ${e.toString()}';
    } finally {
      loadingTypes = false;
      notifyListeners();
    }
  }

  String? _validate() {
    if (title.trim().isEmpty) return 'Title required';
    if (typeId == null) return 'Type required';
    if (description.trim().isEmpty) return 'Description required';
    if (location.trim().isEmpty) return 'Location required';
    if (maxParticipants <= 0) return 'Max participants must be > 0';
    if (price < 0) return 'Price must be >= 0';
    if (startAt == null || endAt == null) return 'Start and end time required';
    if (!endAt!.isAfter(startAt!)) return 'End time must be after start time';
    return null;
  }

  Future<void> submit({required int businessId, required String token}) async {
    error = _validate();
    if (error != null) {
      notifyListeners();
      return;
    }

    loading = true;
    notifyListeners();

    try {
      final input = NewActivityInput(
        activityName: title.trim(),
        activityType: typeId!,
        description: description.trim(),
        location: location.trim(),
        status: status,
        maxParticipants: maxParticipants,
        price: price.toDouble(),
        startDatetime: startAt!.toUtc().toIso8601String(),
        endDatetime: endAt!.toUtc().toIso8601String(),
        imageUri: imagePath,
        latitude: latitude,
        longitude: longitude,
      );

      created = await createUsecase(
        input: input,
        businessId: businessId,
        token: token,
      );
    } catch (e) {
      error = e.toString();
    } finally {
      loading = false;
      notifyListeners();
    }
  }
}
