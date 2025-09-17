// Full user activity details screen                                  // file role
import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:intl/intl.dart'; // dates
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // button
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

import '../../data/repositories/user_activity_detail_repository_impl.dart'; // repo
import '../../data/services/user_activity_detail_service.dart'; // service
import '../../domain/usecases/get_user_activity_detail.dart'; // usecase
import '../../domain/usecases/check_user_availability.dart'; // usecase
import '../../domain/usecases/confirm_user_booking.dart'; // usecase
import '../bloc/user_activity_detail_bloc.dart'; // bloc
import '../bloc/user_activity_detail_event.dart'; // events
import '../bloc/user_activity_detail_state.dart'; // state
import '../widgets/business_header.dart'; // biz card
import '../widgets/price_chip.dart'; // price ui
import '../widgets/participants_stepper.dart'; // qty ui

class UserActivityDetailScreen extends StatelessWidget {
  // screen
  final int itemId; // item id
  final String? imageBaseUrl; // server base for images
  final String? currencyCode; // currency code (e.g. CAD)
  final String? bearerToken; // auth token

  const UserActivityDetailScreen({
    // ctor
    super.key,
    required this.itemId, // set id
    this.imageBaseUrl, // optional
    this.currencyCode, // optional
    this.bearerToken, // optional
  });

  String? _absolute(String? u, String? base) {
    // make absolute url
    if (u == null || u.trim().isEmpty) return null; // guard
    if (u.startsWith('http')) return u; // already abs
    final b = (base ?? '').trim(); // base
    if (b.isEmpty) return null; // no base
    final bb = b.endsWith('/') ? b.substring(0, b.length - 1) : b; // trim /
    final p = u.startsWith('/') ? u : '/$u'; // ensure /
    return '$bb$p'; // join
  }

  @override
  Widget build(BuildContext context) {
    // Wire minimal DI locally (replace with your DI if you have).     // note
    final repo = UserActivityDetailRepositoryImpl(
      // repo impl
      UserActivityDetailService(), // service
    );
    final bloc =
        UserActivityDetailBloc(
          // bloc
          getItem: GetUserActivityDetail(repo), // usecase
          check: CheckUserAvailability(repo), // usecase
          confirm: ConfirmUserBooking(repo), // usecase
        )..add(
          UserActivityDetailStarted(itemId, imageBaseUrl: imageBaseUrl),
        ); // load

    final tt = Theme.of(context).textTheme; // text
    final cs = Theme.of(context).colorScheme; // colors

    return BlocProvider(
      // provide bloc
      create: (_) => bloc, // create
      child: BlocConsumer<UserActivityDetailBloc, UserActivityDetailState>(
        // listen + build
        listener: (ctx, st) {
          // side effects
          if (st.error != null && st.error!.isNotEmpty) {
            // error?
            showTopToast(ctx, st.error!, type: ToastType.error); // toast
          }
          if (st.canBook && !st.booking && !st.checking) {
            // ok
            showTopToast(
              ctx,
              'Ready to book',
              type: ToastType.success,
            ); // toast
          }
        },
        builder: (ctx, st) {
          if (st.loading || st.item == null) {
            // waiting?
            return const Scaffold(
              // shell
              body: Center(child: CircularProgressIndicator()), // spinner
            );
          }

          final item = st.item!; // data
          final img = _absolute(item.imageUrl, st.imageBaseUrl); // image url
          final range = // time range text
              '${DateFormat('M/d/yyyy, h:mm a').format(item.start)} - ${DateFormat('h:mm a').format(item.end)}';

          return Scaffold(
            appBar: AppBar(title: Text('')), // title
            body: ListView(
              padding: const EdgeInsets.all(16), // space
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16), // round
                  child:
                      img ==
                          null // show image
                      ? Container(
                          height: 180, // size
                          color: Colors.black12, // bg
                          child: const Icon(
                            Icons.image,
                            size: 40,
                          ), // placeholder
                        )
                      : Image.network(
                          img,
                          height: 200,
                          fit: BoxFit.cover,
                        ), // image
                ),
                const SizedBox(height: 12), // gap

                Text(item.name, style: tt.headlineSmall), // title
                const SizedBox(height: 6), // gap
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: Colors.grey,
                    ), // icon
                    const SizedBox(width: 6), // gap
                    Text(
                      range,
                      style: tt.bodyMedium?.copyWith(color: Colors.grey),
                    ), // time text
                  ],
                ),
                const SizedBox(height: 6), // gap
                Row(
                  children: [
                    const Icon(
                      Icons.group_outlined,
                      size: 16,
                      color: Colors.grey,
                    ), // icon
                    const SizedBox(width: 6), // gap
                    Text(
                      'Max ${item.maxParticipants} participants', // max text
                      style: tt.bodyMedium?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
                const SizedBox(height: 12), // gap

                BusinessHeader(
                  biz: item.business,
                  imageBaseUrl: st.imageBaseUrl,
                ), // biz card
                const SizedBox(height: 16), // gap

                Text('About', style: tt.titleMedium), // section
                const SizedBox(height: 6), // gap
                Text(
                  item.description ?? '-',
                  style: tt.bodyMedium,
                ), // about text
                const SizedBox(height: 16), // gap

                Text('Location', style: tt.titleMedium), // section
                const SizedBox(height: 6), // gap
                Text(item.location, style: tt.bodyMedium), // address
                const SizedBox(height: 16), // gap

                PriceChip(
                  price: item.price,
                  currencyCode: currencyCode,
                ), // price
                const SizedBox(height: 24), // gap

                Text(
                  'Number of Participants',
                  style: tt.titleMedium,
                ), // qty title
                const SizedBox(height: 10), // gap
                ParticipantsStepper(
                  // qty widget
                  value: st.participants, // current
                  onChanged: (v) =>
                      ctx // emit change
                          .read<UserActivityDetailBloc>()
                          .add(UserParticipantsChanged(v)),
                ),
                const SizedBox(height: 24), // gap
              ],
            ),

            bottomNavigationBar: SafeArea(
              // keep padding around the button
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16,
                ), // outside space
                child: SizedBox(
                  height: 56, // <-- FIX: set a fixed height (52–58 is good)
                  child: AppButton(
                    expand: true, // full width only
                    label: st.booking
                        ? 'Booking...' // text when booking
                        : st.checking
                        ? 'Checking...' // text when checking
                        : 'Book Now', // normal text
                    isBusy: st.booking || st.checking, // show spinner if busy
                    onPressed: () {
                      final token = bearerToken ?? ''; // read token
                      if (token.isEmpty) {
                        // guest?
                        showTopToast(
                          context,
                          'Please login first',
                          type: ToastType.info,
                        );
                        return; // stop here
                      }
                      context // ask API: is there space?
                          .read<UserActivityDetailBloc>()
                          .add(UserCheckAvailabilityPressed(token));

                      // After Stripe payment success, call:
                      // context.read<UserActivityDetailBloc>().add(
                      //   UserConfirmBookingPressed(token, stripePaymentId),
                      // );
                    },
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
