// reusable "Book Now with Stripe" button
import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // button
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

import '../../domain/usecases/create_payment_intent.dart'; // UC
import '../../data/services/stripe_payment_service.dart'; // service
import '../../data/repositories/stripe_payment_repository_impl.dart'; // repo
import '../bloc/stripe_payment_bloc.dart'; // bloc
import '../bloc/stripe_payment_event.dart'; // event
import '../bloc/stripe_payment_state.dart'; // state

// map any app currency to Stripe lowercase code
String _toStripeCurrency(String? appCurrency) {
  final c = (appCurrency ?? '').toUpperCase().trim(); // normalize
  if (c == 'USD' || c == 'DOLLAR' || c == '\$') return 'usd'; // usd
  if (c == 'EUR' || c == '€') return 'eur'; // eur
  if (c == 'CAD' || c == 'C\$') return 'cad'; // cad
  return c.isEmpty ? 'usd' : c.toLowerCase(); // fallback
}

class BookNowButtonStripe extends StatelessWidget {
  final num price; // unit price
  final int participants; // qty selected
  final String? currencyCode; // 'USD' etc.
  final String stripeAccountId; // acct_...
  final String bearerToken; // "Bearer xxx"
  final Future<bool> Function() checkAvailability; // check step
  final Future<void> Function(String stripePaymentId) confirmBooking; // confirm

  const BookNowButtonStripe({
    super.key, // widget key
    required this.price, // set price
    required this.participants, // set qty
    required this.currencyCode, // set currency
    required this.stripeAccountId, // set account
    required this.bearerToken, // set token
    required this.checkAvailability, // set checker
    required this.confirmBooking, // set confirmer
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n

    final bloc = StripePaymentBloc(
      // create bloc
      create: CreatePaymentIntent(
        // inject UC
        StripePaymentRepositoryImpl(StripePaymentService()), // repo+svc
      ),
    );

    // compute total = price * participants (clamp ≥ 1 for safety)
    final qty = participants < 1 ? 1 : participants; // never below 1
    final total = (price * qty); // total amount
    final stripeCurrency = _toStripeCurrency(currencyCode); // 'usd' etc.

    return BlocProvider(
      create: (_) => bloc, // provide bloc
      child: BlocConsumer<StripePaymentBloc, StripePaymentState>(
        listener: (ctx, st) {
          if ((st.error ?? '').isNotEmpty) {
            // any error?
            showTopToast(ctx, st.error!, type: ToastType.error); // show toast
          }
        },
        builder: (ctx, st) {
          return SizedBox(
            height: 56, // fixed height
            child: AppButton(
              expand: true, // full width
              label: st.loading ? t.bookingBooking : t.bookingBookNow, // text
              isBusy: st.loading, // spinner
              onPressed: () async {
                // Step 1: availability (server)
                final ok = await checkAvailability().catchError((e) {
                  // safe call
                  showTopToast(context, '$e', type: ToastType.error); // reason
                  return false; // stop
                });
                if (!ok) {
                  showTopToast(
                    // info toast
                    context,
                    t.bookingNotAvailable,
                    type: ToastType.info,
                  );
                  return; // stop
                }

                // Step 2: Stripe flow (create intent + present)
                ctx.read<StripePaymentBloc>().add(
                  // send event
                  StripeCreateAndPayPressed(
                    amount: total, // total
                    currency: stripeCurrency, // code
                    accountId: stripeAccountId, // acct_...
                    bearerToken: bearerToken, // send token
                    onPaymentSucceeded: (pid) async {
                      // callback
                      // Step 3: confirm booking (server)
                      await confirmBooking(pid); // confirm
                      showTopToast(
                        // success
                        context,
                        t.globalSuccess,
                        type: ToastType.success,
                      );
                    },
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
