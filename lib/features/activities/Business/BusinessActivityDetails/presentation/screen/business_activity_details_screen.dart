// lib/features/activities/Business/businessActivity/presentation/screen/business_activity_details_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

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
import 'package:hobby_sphere/features/activities/Business/common/presentation/screen/ReopenItemPage.dart';

// For reopen
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';

class BusinessActivityDetailsScreen extends StatelessWidget {
  final int activityId;
  final String token;
  final GetBusinessActivityById getById;
  final GetCurrentCurrency getCurrency;
  final DeleteBusinessActivity deleteActivity;

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
      create: (_) => BusinessActivityDetailsBloc(
        getById: getById,
        deleteActivity: deleteActivity,
      )..add(BusinessActivityDetailsRequested(token: token, id: activityId)),
      child: Scaffold(
        appBar: AppBar(),
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
                  Navigator.pop(context, true);
                } else if (state is BusinessActivityDetailsError) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text(state.message)));
                }
              },
              builder: (context, state) {
                if (state is BusinessActivityDetailsLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is BusinessActivityDetailsLoaded) {
                  return FutureBuilder(
                    future: getCurrency(token),
                    builder: (context, snapshot) {
                      final currency = snapshot.data?.code ?? '';
                      return _DetailsView(
                        activity: state.activity,
                        currency: currency,
                        token: token,
                      );
                    },
                  );
                } else if (state is BusinessActivityDetailsError) {
                  return Center(child: Text(state.message));
                }
                return const SizedBox();
              },
            ),
      ),
    );
  }
}

class _DetailsView extends StatelessWidget {
  final BusinessActivity activity;
  final String currency;
  final String token;

  const _DetailsView({
    required this.activity,
    required this.currency,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;
    final df = DateFormat.yMMMd().add_jm();

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activity.imageUrl != null)
            Image.network(
              activity.imageUrl!,
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
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.name,
                  style: tt.headlineSmall?.copyWith(color: cs.primary),
                ),
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

                // === Actions ===
                Row(
                  children: [
                    Expanded(
                      child: AppButton(
                        label: t.activityDetailsEdit,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.editBusinessActivity,
                            arguments: EditActivityRouteArgs(
                              itemId: activity.id,
                              businessId: activity.businessId ?? 0,
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
                        label: t.activityDetailsViewInsights,
                        onPressed: () {
                          Navigator.pushNamed(
                            context,
                            Routes.businessInsights,
                            arguments: BusinessInsightsRouteArgs(
                              token: token,
                              businessId: activity.businessId ?? 0,
                              itemId: activity.id,
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
                  label: t.activityDetailsDelete,
                  onPressed: () async {
                    final confirm = await showDialog<bool>(
                      context: context,
                      builder: (ctx) => AlertDialog(
                        title: Text(t.activityDetailsDelete),
                        content: Text(t.activityDetailsDeletePrompt),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, false),
                            child: Text(t.activityDetailsCancel),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pop(ctx, true),
                            child: Text(t.activityDetailsConfirmDelete),
                          ),
                        ],
                      ),
                    );
                    if (confirm == true) {
                      context.read<BusinessActivityDetailsBloc>().add(
                        BusinessActivityDetailsDeleteRequested(
                          token: token,
                          activityId: activity.id,
                        ),
                      );
                    }
                  },
                  type: AppButtonType.outline,
                  expand: true,
                ),
                const SizedBox(height: 12),

                // Reopen only if terminated
                if (activity.status.toLowerCase() == "terminated")
                  AppButton(
                    label: "Reopen", // TODO add l10n
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ReopenItemPage(
                            businessId: activity.businessId ?? 0,
                            oldItem: activity,
                            getItemTypes: GetItemTypes(
                              ItemTypeRepositoryImpl(ItemTypesService()),
                            ),
                            getCurrentCurrency: GetCurrentCurrency(
                              CurrencyRepositoryImpl(CurrencyService()),
                            ),
                          ),
                        ),
                      );
                    },
                    type: AppButtonType.secondary,
                    expand: true,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
