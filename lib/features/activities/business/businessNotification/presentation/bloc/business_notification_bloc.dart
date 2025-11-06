// Flutter 3.35.x
// BusinessNotificationBloc — load list + unread, mark read, delete, realtime refresh.

import 'dart:async'; // StreamSubscription for realtime
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc base

// domain + repo + event/state
import 'package:hobby_sphere/features/activities/business/businessNotification/domain/entities/business_notification.dart'; // entity
import 'package:hobby_sphere/features/activities/business/businessNotification/domain/usecases/get_business_notifications.dart'; // use case
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_event.dart'; // events
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_state.dart'; // state
import 'package:hobby_sphere/features/activities/business/businessNotification/data/repositories/business_notification_repository_impl.dart'; // repo

// realtime bus
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // global bus
import 'package:hobby_sphere/core/realtime/event_models.dart'; // RealtimeEvent + Domain

class BusinessNotificationBloc
    extends Bloc<BusinessNotificationEvent, BusinessNotificationState> {
  final GetBusinessNotifications getBusinessNotifications; // load list
  final BusinessNotificationRepositoryImpl repository; // mark/delete/count
  final String token; // backend token

  StreamSubscription<RealtimeEvent>? _rtSub; // subscription holder

  BusinessNotificationBloc({
    required this.getBusinessNotifications, // inject loader
    required this.repository, // inject repo
    required this.token, // inject token
  }) : super(const BusinessNotificationState()) {
    // initial state
    // load all notifications
    on<LoadBusinessNotifications>((event, emit) async {
      emit(state.copyWith(isLoading: true, error: null)); // show loader
      try {
        final data = await getBusinessNotifications(token); // backend fetch
        final list = data
            .map((e) => e as BusinessNotification) // cast items
            .toList(growable: false); // make list
        final unread = list.where((n) => !n.read).length; // count unread
        emit(
          state.copyWith(
            notifications: list, // set list
            isLoading: false, // stop loader
            unreadCount: unread, // set unread
          ),
        );
      } catch (e) {
        emit(state.copyWith(isLoading: false, error: e.toString())); // error
      }
    });

    // load unread count only
    on<LoadUnreadCount>((event, emit) async {
      try {
        final count = await repository.getUnreadCount(event.token); // backend
        emit(state.copyWith(unreadCount: count)); // set count
      } catch (e) {
        emit(state.copyWith(error: e.toString())); // error
      }
    });

    // mark one as read
    on<MarkBusinessNotificationRead>((event, emit) async {
      try {
        await repository.markAsRead(token, event.id); // backend
        final updated = state.notifications.map((n) {
          if (n.id == event.id) return n.copyWith(read: true); // update one
          return n; // keep others
        }).toList();
        final unread = updated.where((n) => !n.read).length; // recount
        emit(
          state.copyWith(notifications: updated, unreadCount: unread),
        ); // push
      } catch (e) {
        emit(state.copyWith(error: e.toString())); // error
      }
    });

    // delete one
    on<DeleteBusinessNotification>((event, emit) async {
      try {
        await repository.deleteNotification(token, event.id); // backend
        final updated = state.notifications
            .where((n) => n.id != event.id) // remove one
            .toList();
        final unread = updated.where((n) => !n.read).length; // recount
        emit(
          state.copyWith(notifications: updated, unreadCount: unread),
        ); // push
      } catch (e) {
        emit(state.copyWith(error: e.toString())); // error
      }
    });

    // realtime: on notification domain → reload list + unread
    _rtSub = RealtimeBus.I.stream.listen((e) {
      if (e.domain == Domain.notification) {
        // only notifications
        add(LoadBusinessNotifications()); // reload list
        add(LoadUnreadCount(token)); // ✅ positional (fix)
      }
    });
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // stop realtime
    return super.close(); // finish close
  }
}
