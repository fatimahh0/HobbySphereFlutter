// lib/features/activities/user/social/presentation/bloc/unread/unread_cubit.dart
// Flutter 3.35.x — Unread counter Cubit.
// Holds { userId : unreadCount } and provides simple methods.

import 'package:flutter_bloc/flutter_bloc.dart'; // Cubit base

// Loader signature: return a map like { userId : count } from backend.
typedef UnreadLoader = Future<Map<int, int>> Function(); // function type

class UnreadCubit extends Cubit<Map<int, int>> {
  final UnreadLoader loadAll; // function to pull all unread counts

  UnreadCubit({required this.loadAll})
    : super(const {}); // start with empty state

  Future<void> refresh() async {
    // load unread counts from backend/repo
    final map = await loadAll(); // { userId : count }
    emit(Map<int, int>.from(map)); // emit new map
  }

  void setFor(int userId, int count) {
    // set a specific user's count
    final m = Map<int, int>.from(state); // copy
    if (count <= 0) {
      m.remove(userId); // zero → remove
    } else {
      m[userId] = count; // update
    }
    emit(m); // emit
  }

  void incFor(int userId, {int by = 1}) {
    // increment a user's count (realtime)
    final m = Map<int, int>.from(state); // copy
    m[userId] = (m[userId] ?? 0) + by; // add
    emit(m); // emit
  }

  void clearFor(int userId) {
    // clear when opening the chat
    final m = Map<int, int>.from(state)..remove(userId); // remove
    emit(m); // emit
  }
}
