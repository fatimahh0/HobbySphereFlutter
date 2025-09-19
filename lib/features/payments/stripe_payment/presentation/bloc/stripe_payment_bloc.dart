import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../stripe_payment/domain/usecases/create_payment_intent.dart';
import '../../../stripe_payment/domain/entities/payment_intent_result.dart';
import '../helpers/stripe_sheet.dart';
import 'stripe_payment_event.dart';
import 'stripe_payment_state.dart';

class StripePaymentBloc extends Bloc<StripePaymentEvent, StripePaymentState> {
  final CreatePaymentIntent create;

  StripePaymentBloc({required this.create})
    : super(const StripePaymentState()) {
    on<StripeCreateAndPayPressed>(_onCreateAndPay);
  }

  Future<void> _onCreateAndPay(
    StripeCreateAndPayPressed e,
    Emitter<StripePaymentState> emit,
  ) async {
    emit(state.copyWith(loading: true, error: null));
    try {
      final PaymentIntentResult r = await create(
        amount: e.amount,
        currency: e.currency,
        accountId: e.accountId,
      );

      final ok = await StripeSheet.present(clientSecret: r.clientSecret);

      if (ok) {
        await e.onPaymentSucceeded(r.paymentIntentId);
        emit(state.copyWith(loading: false));
      } else {
        // <- tell UI something happened (cancel or failure)
        emit(
          state.copyWith(
            loading: false,
            error: 'Payment was cancelled or failed to open.',
          ),
        );
      }
    } catch (err) {
      emit(state.copyWith(loading: false, error: '$err'));
    }
  }
}
