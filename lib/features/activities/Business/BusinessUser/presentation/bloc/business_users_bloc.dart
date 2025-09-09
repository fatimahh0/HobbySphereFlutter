import 'package:flutter_bloc/flutter_bloc.dart';
import 'business_users_event.dart';
import 'business_users_state.dart';
import '../../domain/usecases/get_business_users.dart';
import '../../domain/usecases/create_business_user.dart';
import '../../domain/usecases/book_cash.dart';

class BusinessUsersBloc extends Bloc<BusinessUsersEvent, BusinessUsersState> {
  final GetBusinessUsers getUsers;
  final CreateBusinessUser createUser;
  final BookCash bookCash; // 👈 add use case

  BusinessUsersBloc({
    required this.getUsers,
    required this.createUser,
    required this.bookCash,
  }) : super(BusinessUsersInitial()) {
    on<LoadBusinessUsers>(_onLoad);
    on<CreateBusinessUserEvent>(_onCreate);
    on<BookCashEvent>(_onBookCash); // 👈 handle booking
  }

  Future<void> _onLoad(
    LoadBusinessUsers event,
    Emitter<BusinessUsersState> emit,
  ) async {
    emit(BusinessUsersLoading());
    try {
      final users = await getUsers(event.token);
      emit(BusinessUsersLoaded(users));
    } catch (e) {
      emit(BusinessUsersError(e.toString()));
    }
  }

  Future<void> _onCreate(
    CreateBusinessUserEvent event,
    Emitter<BusinessUsersState> emit,
  ) async {
    try {
      final current = state is BusinessUsersLoaded
          ? (state as BusinessUsersLoaded).users
          : [];
      final newUser = await createUser(
        event.token,
        firstname: event.firstname,
        lastname: event.lastname,
        email: event.email,
        phoneNumber: event.phoneNumber,
      );
      emit(BusinessUsersLoaded([...current, newUser]));
    } catch (e) {
      emit(BusinessUsersError(e.toString()));
    }
  }

  Future<void> _onBookCash(
    BookCashEvent event,
    Emitter<BusinessUsersState> emit,
  ) async {
    try {
      emit(BusinessUsersBooking()); // 👈 show loading state
      final result = await bookCash(
        event.token,
        itemId: event.itemId,
        businessUserId: event.businessUserId,
        participants: event.participants,
        wasPaid: event.wasPaid,
      );
      emit(BusinessUserBookingSuccess(result));
    } catch (e) {
      emit(BusinessUsersError("Booking failed: ${e.toString()}"));
    }
  }
}
