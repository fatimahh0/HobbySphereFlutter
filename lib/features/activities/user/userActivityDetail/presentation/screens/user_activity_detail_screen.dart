// flutter + bloc + intl + l10n + widgets
import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:intl/intl.dart'; // date fmt
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // button
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

// map + geo + launcher
import 'package:flutter_map/flutter_map.dart'; // map
import 'package:latlong2/latlong.dart'; // coords
import 'package:url_launcher/url_launcher.dart'; // launcher

// data / domain / bloc
import '../../data/repositories/user_activity_detail_repository_impl.dart'; // repo impl
import '../../data/services/user_activity_detail_service.dart'; // service
import '../../domain/usecases/get_user_activity_detail.dart'; // usecase
import '../../domain/usecases/check_user_availability.dart'; // usecase
import '../../domain/usecases/confirm_user_booking.dart'; // usecase
import '../bloc/user_activity_detail_bloc.dart'; // bloc
import '../bloc/user_activity_detail_event.dart'; // events
import '../bloc/user_activity_detail_state.dart'; // state
import '../widgets/business_header.dart'; // header
import '../widgets/price_chip.dart'; // price
import '../widgets/participants_stepper.dart'; // stepper

// ===== NEW: import the reusable Stripe button =====
import 'package:hobby_sphere/features/payments/stripe_payment/presentation/widgets/book_now_button_stripe.dart'; // book button

// Details screen for a user-visible activity
class UserActivityDetailScreen extends StatelessWidget {
  final int itemId; // item id to show
  final String? imageBaseUrl; // image base (server)
  final String? currencyCode; // currency code (USD/EUR/..)
  final String? bearerToken; // auth token "Bearer xxx"

  const UserActivityDetailScreen({
    super.key, // key
    required this.itemId, // set id
    this.imageBaseUrl, // set base
    this.currencyCode, // set currency
    this.bearerToken, // set token
  });

  // build absolute image URL if relative
  String? _absolute(String? u, String? base) {
    if (u == null || u.trim().isEmpty) return null; // no url
    if (u.startsWith('http')) return u; // already abs
    final b = (base ?? '').trim(); // base trim
    if (b.isEmpty) return null; // no base
    final bb = b.endsWith('/') ? b.substring(0, b.length - 1) : b; // trim /
    final p = u.startsWith('/') ? u : '/$u'; // ensure /
    return '$bb$p'; // join
  }

  // open device maps to given point
  Future<void> _openMaps({
    required BuildContext context, // ctx
    required double lat, // lat
    required double lng, // lng
    required String label, // label
  }) async {
    final t = AppLocalizations.of(context)!; // l10n
    final uri = Uri.parse(
      'https://www.google.com/maps/search/?api=1&query=$lat,$lng&query_place_id=${Uri.encodeComponent(label)}',
    ); // url
    if (await canLaunchUrl(uri)) {
      // can open?
      await launchUrl(uri, mode: LaunchMode.externalApplication); // open
    } else {
      showTopToast(context, t.globalError, type: ToastType.error); // error
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n
    final repo = UserActivityDetailRepositoryImpl(
      // repo
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

    final tt = Theme.of(context).textTheme; // text theme
    final cs = Theme.of(context).colorScheme; // color scheme

    // localized date/time formats
    final dateRangeFmtStart = DateFormat.yMd(
      t.localeName,
    ).add_jm(); // date+time
    final timeOnlyFmt = DateFormat.jm(t.localeName); // time only

    return BlocProvider(
      create: (_) => bloc, // provide bloc
      child: BlocConsumer<UserActivityDetailBloc, UserActivityDetailState>(
        listener: (ctx, st) {
          // side effects
          if ((st.error ?? '').isNotEmpty) {
            // has error?
            showTopToast(ctx, st.error!, type: ToastType.error); // toast
          }
          if (st.canBook && !st.booking && !st.checking) {
            // ok flag
            showTopToast(
              ctx,
              t.globalSuccess,
              type: ToastType.success,
            ); // toast
          }
        },
        builder: (ctx, st) {
          // UI
          if (st.loading || st.item == null) {
            // loading?
            return Scaffold(
              appBar: AppBar(), // appbar
              body: Center(
                child: CircularProgressIndicator(color: cs.primary), // spinner
              ),
            );
          }

          final item = st.item!; // data
          final img = _absolute(item.imageUrl, st.imageBaseUrl); // image url
          final range =
              '${dateRangeFmtStart.format(item.start)} - ${timeOnlyFmt.format(item.end)}'; // time range

          final LatLng? point =
              (item.latitude != null && item.longitude != null)
              ? LatLng(item.latitude!, item.longitude!) // map point
              : null; // none

          return Scaffold(
            appBar: AppBar(title: Text(item.name)), // title
            body: ListView(
              padding: const EdgeInsets.all(16), // padding
              children: [
                // header image
                ClipRRect(
                  borderRadius: BorderRadius.circular(16), // round
                  child: img == null
                      ? Container(
                          height: 180, // height
                          color: cs.surfaceContainer, // bg
                          alignment: Alignment.center, // center
                          child: Icon(
                            Icons.image,
                            size: 40,
                            color: cs.outline,
                          ), // icon
                        )
                      : Image.network(
                          img,
                          height: 200,
                          fit: BoxFit.cover,
                        ), // image
                ),
                const SizedBox(height: 12), // space

                Text(item.name, style: tt.headlineSmall), // title
                const SizedBox(height: 6), // space

                Row(
                  children: [
                    Icon(
                      Icons.calendar_today_outlined,
                      size: 16,
                      color: cs.outline,
                    ), // icon
                    const SizedBox(width: 6), // space
                    Text(
                      range,
                      style: tt.bodyMedium?.copyWith(color: cs.outline),
                    ), // text
                  ],
                ),
                const SizedBox(height: 6), // space

                Row(
                  children: [
                    Icon(
                      Icons.group_outlined,
                      size: 16,
                      color: cs.outline,
                    ), // icon
                    const SizedBox(width: 6), // space
                    Text(
                      t.bookingMaxParticipants(item.maxParticipants),
                      style: tt.bodyMedium?.copyWith(color: cs.outline),
                    ), // text
                  ],
                ),
                const SizedBox(height: 12), // space

                BusinessHeader(
                  biz: item.business,
                  imageBaseUrl: st.imageBaseUrl,
                ), // business card
                const SizedBox(height: 16), // space

                Text(t.bookingAbout, style: tt.titleMedium), // section title
                const SizedBox(height: 6), // space
                Text(
                  item.description ?? '-',
                  style: tt.bodyMedium,
                ), // description
                const SizedBox(height: 16), // space

                Text(t.bookingLocation, style: tt.titleMedium), // section title
                const SizedBox(height: 6), // space
                Text(item.location, style: tt.bodyMedium), // location text

                if (point != null) ...[
                  // map if point
                  const SizedBox(height: 10), // space
                  ClipRRect(
                    borderRadius: BorderRadius.circular(14), // round
                    child: Container(
                      height: 220, // height
                      color: cs.surface, // bg
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: point, // center
                          initialZoom: 15, // zoom
                          interactionOptions: const InteractionOptions(
                            flags:
                                InteractiveFlag.pinchZoom |
                                InteractiveFlag.drag, // gestures
                          ),
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', // tiles
                            subdomains: const ['a', 'b', 'c'], // subdomains
                            userAgentPackageName: 'com.hobbysphere.app', // ua
                          ),
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: point, // pos
                                width: 44, // w
                                height: 44, // h
                                child: Icon(
                                  Icons.location_on,
                                  size: 36,
                                  color: cs.error,
                                ), // marker
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8), // space
                  Align(
                    alignment: Alignment.centerRight, // right
                    child: TextButton.icon(
                      onPressed: () => _openMaps(
                        // open maps
                        context: context,
                        lat: point.latitude,
                        lng: point.longitude,
                        label: item.name,
                      ),
                      icon: const Icon(Icons.map_outlined), // icon
                      label: Text(t.mapOpen), // label
                      style: TextButton.styleFrom(
                        foregroundColor: cs.primary,
                      ), // color
                    ),
                  ),
                ],

                const SizedBox(height: 16), // space

                PriceChip(
                  price: item.price,
                  currencyCode: currencyCode,
                ), // price
                const SizedBox(height: 24), // space

                ParticipantsStepper(
                  // qty stepper
                  value: st.participants, // value
                  onChanged: (v) => ctx.read<UserActivityDetailBloc>().add(
                    UserParticipantsChanged(v), // event
                  ),
                ),
                const SizedBox(height: 24), // space
              ],
            ),

            // ======= UPDATED: Stripe "Book now" button bottom bar =======
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16,
                  8,
                  16,
                  16,
                ), // outer padding
                child: Builder(
                  builder: (ctx) {
                    // 1) read token from param OR global store
                    final raw = (bearerToken ?? g.readAuthToken())
                        .trim(); // fallback to saved token

                    // 2) standardize to "Bearer ..." format for the server
                    final headerToken = raw.isEmpty
                        ? ''
                        : (raw.startsWith('Bearer ') ? raw : 'Bearer $raw');

                    // 3) if still empty → show login message
                    if (headerToken.isEmpty) {
                      return SizedBox(
                        height: 56, // button height
                        child: AppButton(
                          expand: true, // full width
                          label: t.authNotLoggedInMessage, // l10n message
                          onPressed: () {
                            showTopToast(
                              context,
                              t.authNotLoggedInMessage,
                              type: ToastType.info,
                            );
                            // TODO: LegacyNav.pushNamed(context, Routes.login);
                          },
                        ),
                      );
                    }

                    // 4) optional: if the business has no connected Stripe account → disable
                    final accountId = item.business.stripeAccountId ?? '';
                    if (accountId.isEmpty) {
                      return SizedBox(
                        height: 56,
                        child: AppButton(
                          expand: true,
                          label: t.bookingProcessing, // or a dedicated message
                          onPressed: () => showTopToast(
                            context,
                            'Payment temporarily unavailable for this activity.',
                            type: ToastType.info,
                          ),
                        ),
                      );
                    }

                    // 5) logged-in flow: use the reusable Stripe button
                    return BookNowButtonStripe(
                      price: item.price, // unit price
                      participants: st.participants, // quantity
                      currencyCode: currencyCode, // currency
                      stripeAccountId: accountId, // connected account id
                      bearerToken: headerToken, // ALWAYS "Bearer <jwt>"
                      // step 1: availability check (server)
                      checkAvailability: () async {
                        try {
                          return await CheckUserAvailability(
                            UserActivityDetailRepositoryImpl(
                              UserActivityDetailService(),
                            ),
                          )(
                            itemId: item.id,
                            participants: st.participants,
                            bearerToken: headerToken, // pass header token
                          );
                        } catch (e) {
                          showTopToast(context, '$e', type: ToastType.error);
                          return false;
                        }
                      },

                      // step 3: confirm booking (server) after Stripe success
                      confirmBooking: (stripePaymentId) async {
                        await ConfirmUserBooking(
                          UserActivityDetailRepositoryImpl(
                            UserActivityDetailService(),
                          ),
                        )(
                          itemId: item.id,
                          participants: st.participants,
                          stripePaymentId: stripePaymentId,
                          bearerToken: headerToken, // pass header token
                        );
                      },
                    );
                  },
                ),
              ),
            ),

            // ============================================================
          );
        },
      ),
    );
  }
}
