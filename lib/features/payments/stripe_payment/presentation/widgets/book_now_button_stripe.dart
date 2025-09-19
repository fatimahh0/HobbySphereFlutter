import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import '../../domain/usecases/create_payment_intent.dart';
import '../../data/services/stripe_payment_service.dart';
import '../../data/repositories/stripe_payment_repository_impl.dart';
import '../bloc/stripe_payment_bloc.dart';
import '../bloc/stripe_payment_event.dart';
import '../bloc/stripe_payment_state.dart';

// Convert app currency to Stripe code (lowercase).
String _toStripeCurrency(String? appCurrency) {
  final c = (appCurrency ?? '').toUpperCase().trim();
  if (c == 'USD' || c == 'DOLLAR' || c == '\$') return 'usd';
  if (c == 'EUR' || c == '€') return 'eur';
  if (c == 'CAD' || c == 'C\$') return 'cad';
  return c.isEmpty ? 'usd' : c.toLowerCase();
}

/// Ready-to-use "Book Now" button:
/// 1) checkAvailability()
/// 2) create PI + present sheet
/// 3) confirmBooking(paymentIntentId)
class BookNowButtonStripe extends StatelessWidget {
  final num price; // price per person
  final int participants; // quantity
  final String? currencyCode; // "USD" / "CAD" / ...
  final String stripeAccountId; // connected account id (or '')
  final String bearerToken; // not used here directly but handy
  final Future<bool> Function() checkAvailability;
  final Future<void> Function(String stripePaymentId) confirmBooking;

  const BookNowButtonStripe({
    super.key,
    required this.price,
    required this.participants,
    required this.currencyCode,
    required this.stripeAccountId,
    required this.bearerToken,
    required this.checkAvailability,
    required this.confirmBooking,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final bloc = StripePaymentBloc(
      create: CreatePaymentIntent(
        StripePaymentRepositoryImpl(StripePaymentService()),
      ),
    );

    final total = (price * participants);
    final stripeCurrency = _toStripeCurrency(currencyCode);

    return BlocProvider(
      create: (_) => bloc,
      child: BlocConsumer<StripePaymentBloc, StripePaymentState>(
        listener: (ctx, st) {
          if ((st.error ?? '').isNotEmpty) {
            showTopToast(ctx, st.error!, type: ToastType.error);
          }
        },
        builder: (ctx, st) {
          return SizedBox(
            height: 56,
            child: AppButton(
              expand: true,
              label: st.loading ? t.bookingBooking : t.bookingBookNow,
              isBusy: st.loading,
              onPressed: () async {
                // Step 1: availability
                final ok = await checkAvailability();
                if (!ok) {
                  showTopToast(
                    context,
                    t.bookingNotAvailable,
                    type: ToastType.info,
                  );
                  return;
                }

                // Step 2: Stripe flow
                ctx.read<StripePaymentBloc>().add(
                  StripeCreateAndPayPressed(
                    amount: total,
                    currency: stripeCurrency,
                    accountId: stripeAccountId,
                    onPaymentSucceeded: (pid) async {
                      // Step 3: confirm booking with your backend
                      await confirmBooking(pid);
                      showTopToast(
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
