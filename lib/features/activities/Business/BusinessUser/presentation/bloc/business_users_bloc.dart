// Flutter 3.35.x
// BusinessUsersBloc — load users, create user, book cash, realtime refresh.

import 'dart:async'; // StreamSubscription
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc base

import 'business_users_event.dart'; // events (positional constructors)
import 'business_users_state.dart'; // state
import '../../domain/usecases/get_business_users.dart'; // load users
import '../../domain/usecases/create_business_user.dart'; // create
import '../../domain/usecases/book_cash.dart'; // book cash

// realtime
import 'package:hobby_sphere/core/realtime/realtime_bus.dart'; // bus
import 'package:hobby_sphere/core/realtime/event_models.dart'; // Domain

class BusinessUsersBloc extends Bloc<BusinessUsersEvent, BusinessUsersState> {
  final GetBusinessUsers getUsers; // use case
  final CreateBusinessUser createUser; // use case
  final BookCash bookCash; // use case

  String? _token; // remember token for realtime reload
  StreamSubscription<RealtimeEvent>? _rtSub; // subscription holder

  BusinessUsersBloc({
    required this.getUsers, // inject loader
    required this.createUser, // inject create
    required this.bookCash, // inject book cash
  }) : super(BusinessUsersInitial()) {
    on<LoadBusinessUsers>(_onLoad); // load handler
    on<CreateBusinessUserEvent>(_onCreate); // create handler
    on<BookCashEvent>(_onBookCash); // book handler

    // realtime: user domain → reload list (if we know token)
    _rtSub = RealtimeBus.I.stream.listen((e) {
      if (e.domain == Domain.user && _token != null) {
        // only user events
        add(LoadBusinessUsers(_token!)); // ✅ positional (fix)
      }
    });
  }

  Future<void> _onLoad(
    LoadBusinessUsers event,
    Emitter<BusinessUsersState> emit,
  ) async {
    emit(BusinessUsersLoading()); // show loader
    try {
      _token = event.token; // remember token
      final users = await getUsers(event.token); // backend fetch
      emit(BusinessUsersLoaded(users)); // show data
    } catch (e) {
      emit(BusinessUsersError(e.toString())); // error
    }
  }

  Future<void> _onCreate(
    CreateBusinessUserEvent event,
    Emitter<BusinessUsersState> emit,
  ) async {
    try {
      final current = state is BusinessUsersLoaded
          ? (state as BusinessUsersLoaded)
                .users // current list
          : []; // or empty
      final newUser = await createUser(
        // backend create
        event.token,
        firstname: event.firstname,
        lastname: event.lastname,
        email: event.email,
        phoneNumber: event.phoneNumber,
      );
      emit(BusinessUsersLoaded([...current, newUser])); // append
    } catch (e) {
      emit(BusinessUsersError(e.toString())); // error
    }
  }

  Future<void> _onBookCash(
    BookCashEvent event,
    Emitter<BusinessUsersState> emit,
  ) async {
    try {
      emit(BusinessUsersBooking()); // show booking loader
      final result = await bookCash(
        // backend call
        event.token,
        itemId: event.itemId,
        businessUserId: event.businessUserId,
        participants: event.participants,
        wasPaid: event.wasPaid,
      );
      emit(BusinessUserBookingSuccess(result)); // success
    } catch (e) {
      emit(BusinessUsersError("Booking failed: ${e.toString()}")); // error
    }
  }

  @override
  Future<void> close() async {
    await _rtSub?.cancel(); // stop realtime
    return super.close(); // finish close
  }
}
