// BLoC: orchestrates create-intent -> open sheet -> callback
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc base
import '../../../stripe_payment/domain/usecases/create_payment_intent.dart'; // UC
import '../../../stripe_payment/domain/entities/payment_intent_result.dart'; // entity
import '../helpers/stripe_sheet.dart'; // sheet helper
import 'stripe_payment_event.dart'; // events
import 'stripe_payment_state.dart'; // state

class StripePaymentBloc extends Bloc<StripePaymentEvent, StripePaymentState> {
  final CreatePaymentIntent create; // dependency

  StripePaymentBloc({required this.create})
    : super(const StripePaymentState()) {
    // init state
    on<StripeCreateAndPayPressed>(_onCreateAndPay); // bind handler
  }

  Future<void> _onCreateAndPay(
    StripeCreateAndPayPressed e, // incoming event
    Emitter<StripePaymentState> emit, // state emitter
  ) async {
    emit(state.copyWith(loading: true, error: null)); // start busy
    try {
      // ask backend to create PI
      final PaymentIntentResult r = await create(
        amount: e.amount, // pass amount
        currency: e.currency, // pass currency
        accountId: e.accountId, // pass account
        bearerToken: e.bearerToken, // pass token
      );

      // present the Stripe sheet
      final ok = await StripeSheet.present(
        clientSecret: r.clientSecret,
      ); // open

      if (ok) {
        // user paid
        await e.onPaymentSucceeded(r.paymentIntentId); // callback
        emit(state.copyWith(loading: false)); // done
      } else {
        // canceled/fail
        emit(
          state.copyWith(
            loading: false, // stop busy
            error: 'Payment was cancelled or failed to open.', // message
          ),
        );
      }
    } catch (err) {
      // show any error (backend/stripe/init)
      emit(state.copyWith(loading: false, error: '$err')); // error out
    }
  }
}
