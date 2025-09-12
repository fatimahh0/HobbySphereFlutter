// ===== lib/features/activities/Business/BusinessActivityDetails/presentation/screen/business_activity_details_screen.dart
// Flutter 3.35.x — Fix: extract businessId safely and use it for Reopen.

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/common/presentation/screen/ReopenItemPage.dart';
import 'package:intl/intl.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // + add: to resolve absolute image URLs

// Bloc details
import 'package:hobby_sphere/features/activities/Business/BusinessActivityDetails/presentation/bloc/business_activity_details_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessActivityDetails/presentation/bloc/business_activity_details_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessActivityDetails/presentation/bloc/business_activity_details_state.dart';

// Domain
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart';

// Widgets
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/app/router/router.dart';

// For reopen deps
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';

class BusinessActivityDetailsScreen extends StatelessWidget {
  final int activityId; // activity id (given)
  final String token; // auth token (given)
  final GetBusinessActivityById getById; // use case to load details
  final GetCurrentCurrency getCurrency; // use case to load currency
  final DeleteBusinessActivity deleteActivity; // use case to delete

  const BusinessActivityDetailsScreen({
    super.key,
    required this.activityId,
    required this.token,
    required this.getById,
    required this.getCurrency,
    required this.deleteActivity,
  });

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          BusinessActivityDetailsBloc(
            getById: getById, // inject loader
            deleteActivity: deleteActivity, // inject delete
          )..add(
            BusinessActivityDetailsRequested(token: token, id: activityId),
          ), // fetch details
      child: Scaffold(
        appBar: AppBar(), // simple app bar
        body:
            BlocConsumer<
              BusinessActivityDetailsBloc,
              BusinessActivityDetailsState
            >(
              listener: (context, state) {
                if (state is BusinessActivityDetailsDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        AppLocalizations.of(
                          context,
                        )!.activityDetailsDeleteSuccess,
                      ),
                    ),
                  );
                  Navigator.pop(context, true); // go back with success
                } else if (state is BusinessActivityDetailsError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(state.message)),
                  ); // show error
                }
              },
              builder: (context, state) {
                if (state is BusinessActivityDetailsLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  ); // loading
                } else if (state is BusinessActivityDetailsLoaded) {
                  return FutureBuilder(
                    future: getCurrency(token), // load currency
                    builder: (context, snapshot) {
                      final currency =
                          snapshot.data?.code ?? ''; // currency code
                      return _DetailsView(
                        activity: state.activity, // pass item
                        currency: currency, // pass currency code
                        token: token, // pass token
                      );
                    },
                  );
                } else if (state is BusinessActivityDetailsError) {
                  return Center(child: Text(state.message)); // error view
                }
                return const SizedBox(); // empty
              },
            ),
      ),
    );
  }
}

// helper: make image URL absolute for display (handles "/uploads/..")
String _absolute(String? raw) {
  if (raw == null || raw.isEmpty) return '';
  if (raw.startsWith('http://') || raw.startsWith('https://'))
    return raw; // already absolute
  final base = g.serverRootNoApi(); // e.g. http://host:port
  final sep = raw.startsWith('/') ? '' : '/'; // single slash join
  return '$base$sep$raw'; // build absolute
}

// helper: extract a valid businessId from the entity (nested business or field), else 0
// helper: return a valid businessId from the entity (repo now fills it)
int _businessIdOf(BusinessActivity a) {
  return (a.businessId ?? 0); // simple & safe
}

class _DetailsView extends StatelessWidget {
  final BusinessActivity activity; // item data
  final String currency; // currency code
  final String token; // auth token

  const _DetailsView({
    required this.activity,
    required this.currency,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // texts
    final df = DateFormat.yMMMd().add_jm(); // date format

    final headerImage = _absolute(
      activity.imageUrl,
    ); // absolute header image url

    final bid = _businessIdOf(activity); // ✅ resolve businessId safely
    // small guard: if still 0, show a toast and disable Reopen
    final canReopen =
        activity.status.toLowerCase() == "terminated" &&
        bid > 0; // allow only when valid

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (headerImage.isNotEmpty) // show cover image if exists
            Image.network(
              headerImage, // absolute url
              width: double.infinity,
              height: 220,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 220,
                color: Colors.grey.shade200,
                child: const Icon(
                  Icons.broken_image,
                  size: 64,
                  color: Colors.grey,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16), // page padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: tt.headlineSmall?.copyWith(color: cs.primary),
                ), // title
                const SizedBox(height: 8),

                // Location
                Row(
                  children: [
                    const Icon(Icons.location_on, size: 18),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(activity.location, style: tt.bodyMedium),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Dates
                if (activity.startDate != null && activity.endDate != null)
                  Row(
                    children: [
                      const Icon(Icons.calendar_today, size: 18),
                      const SizedBox(width: 6),
                      Text(
                        "${df.format(activity.startDate!)} - ${df.format(activity.endDate!)}",
                        style: tt.bodyMedium,
                      ),
                    ],
                  ),
                const SizedBox(height: 6),

                // Participants
                Row(
                  children: [
                    const Icon(Icons.people, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "${activity.maxParticipants} ${t.activityDetailsParticipants}",
                      style: tt.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                // Price
                Row(
                  children: [
                    const Icon(Icons.sell, size: 18),
                    const SizedBox(width: 6),
                    Text(
                      "${activity.price} $currency",
                      style: tt.bodyMedium?.copyWith(color: cs.primary),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Description
                Text(t.activityDetailsDescription, style: tt.titleMedium),
                const SizedBox(height: 4),
                Text(activity.description, style: tt.bodyMedium),
                const SizedBox(height: 16),

                // Status
                Text(
                  "${t.activityDetailsStatus}: ${activity.status}",
                  style: tt.bodyMedium?.copyWith(
                    color: activity.status.toLowerCase() == "upcoming"
                        ? Colors.green
                        : Colors.red,
                  ),
                ),

                const SizedBox(height: 24),

                // === Actions (Edit / Insights) ===
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: t.activityDetailsEdit, // edit
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.editBusinessActivity,
                            arguments: EditActivityRouteArgs(
                              itemId: activity.id, // pass id
                              businessId: bid, // ✅ use resolved business id
                            ),
                          );
                        },
                        type: AppButtonType.primary,
                        expand: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: AppButton(
                        label: t.activityDetailsViewInsights, // insights
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.businessInsights,
                            arguments: BusinessInsightsRouteArgs(
                              token: token, // token
                              businessId: bid, // ✅ resolved id
                              itemId: activity.id, // item id
                            ),
                          );
                        },
                        type: AppButtonType.outline,
                        expand: true,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Delete
                AppButton(
                  label: t.activityDetailsDelete, // delete
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(t.activityDetailsDelete), // title
                        content: Text(t.activityDetailsDeletePrompt), // prompt
                        actions: [
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(ctx, false), // cancel
                            child: Text(t.activityDetailsCancel),
                          ),
                          TextButton(
                            onPressed: () =>
                                Navigator.pop(ctx, true), // confirm
                            child: Text(t.activityDetailsConfirmDelete),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      context.read<BusinessActivityDetailsBloc>().add(
                        BusinessActivityDetailsDeleteRequested(
                          token: token, // token
                          activityId: activity.id, // id
                        ),
                      );
                    }
                  },
                  type: AppButtonType.outline,
                  expand: true,
                ),
                const SizedBox(height: 12),

                // Reopen (only when terminated AND we have a valid businessId)
                if (activity.status.toLowerCase() == "terminated")
                  AppButton(
                    label: "Reopen", // TODO: add l10n key
                    onPressed: canReopen
                        ? () {
                            // debug print to verify the id used
                            // ignore: avoid_print
                            print(
                              'Reopen with businessId = $bid, itemId = ${activity.id}',
                            );
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => ReopenItemPage(
                                  businessId:
                                      bid, // ✅ FIX: pass real businessId
                                  oldItem:
                                      activity, // pass the existing activity
                                  getItemTypes: GetItemTypes(
                                    // inject types use case
                                    ItemTypeRepositoryImpl(ItemTypesService()),
                                  ),
                                  getCurrentCurrency: GetCurrentCurrency(
                                    // inject currency use case
                                    CurrencyRepositoryImpl(CurrencyService()),
                                  ),
                                ),
                              ),
                            );
                          }
                        : null, // disabled if id invalid
                    type: AppButtonType.secondary,
                    expand: true,
                  ),
                if (!canReopen && activity.status.toLowerCase() == "terminated")
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      "Cannot reopen: missing business id.", // small hint if disabled
                      style: tt.bodySmall?.copyWith(color: cs.error),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
