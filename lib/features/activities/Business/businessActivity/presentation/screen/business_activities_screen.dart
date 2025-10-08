// ===== Flutter 3.35.x =====
// BusinessActivitiesScreen — list of business activities with search, tabs, delete, edit, reopen

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_state';
import 'package:hobby_sphere/features/activities/Business/common/presentation/screen/ReopenItemPage.dart';
import 'package:hobby_sphere/app/router/legacy_nav.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/BusinessListItemCard.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

/// Helper: ensure image URLs are absolute
String? resolveApiImage(String? raw) {
  if (raw == null || raw.isEmpty) return null;
  if (raw.startsWith('http://') || raw.startsWith('https://')) return raw;
  return '${g.serverRootNoApi()}$raw';
}

class BusinessActivitiesScreen extends StatefulWidget {
  final String token;
  final int businessId;

  const BusinessActivitiesScreen({
    super.key,
    required this.token,
    required this.businessId,
  });

  @override
  State<BusinessActivitiesScreen> createState() =>
      _BusinessActivitiesScreenState();
}

class _BusinessActivitiesScreenState extends State<BusinessActivitiesScreen> {
  String _query = '';
  String _tab = 'Upcoming';
  String _currency = '';

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      final repo = CurrencyRepositoryImpl(CurrencyService());
      final usecase = GetCurrentCurrency(repo);
      final cur = await usecase(widget.token);
      setState(() {
        _currency = cur.code;
      });
    } catch (e) {
      debugPrint('Error loading currency: $e');
    }
  }

  void _toast(BuildContext context, String msg, {bool error = false}) {
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    showTopToast(
      rootCtx,
      msg,
      type: error ? ToastType.error : ToastType.success,
      haptics: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: AppSearchBar(
              hint: tr.searchPlaceholder,
              onQueryChanged: (q) => setState(() => _query = q),
              onClear: () => setState(() => _query = ''),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Tabs
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: tr.upcoming,
                    type: _tab == 'Upcoming'
                        ? AppButtonType.primary
                        : AppButtonType.outline,
                    expand: true,
                    onPressed: () => setState(() => _tab = 'Upcoming'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppButton(
                    label: tr.terminated,
                    type: _tab == 'Terminated'
                        ? AppButtonType.primary
                        : AppButtonType.outline,
                    expand: true,
                    onPressed: () => setState(() => _tab = 'Terminated'),
                  ),
                ),
              ],
            ),
          ),

          // List
          Expanded(
            child: BlocConsumer<BusinessActivitiesBloc, BusinessActivitiesState>(
              listenWhen: (p, c) =>
                  p is BusinessActivitiesError ||
                  (c is BusinessActivitiesError),
              listener: (context, state) {
                if (state is BusinessActivitiesError) {
                  _toast(context, state.message, error: true);
                }
              },
              builder: (context, state) {
                if (state is BusinessActivitiesLoading) {
                  return const Center(child: CircularProgressIndicator());
                }
                if (state is BusinessActivitiesLoaded) {
                  var list = state.activities;

                  // filter by tab
                  list = list.where((a) {
                    final isTerminated = a.status.toLowerCase() == 'terminated';
                    return _tab == 'Upcoming' ? !isTerminated : isTerminated;
                  }).toList();

                  // filter by query
                  if (_query.isNotEmpty) {
                    list = list
                        .where(
                          (a) => a.name.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                        )
                        .toList();
                  }

                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        tr.activitiesEmpty,
                        style: theme.textTheme.bodyMedium,
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BusinessActivitiesBloc>().add(
                        LoadBusinessActivities(
                          token: widget.token,
                          businessId: widget.businessId,
                        ),
                      );
                      return Future.value();
                    },
                    child: ListView.builder(
                      itemCount: list.length,
                      itemBuilder: (ctx, index) {
                        final a = list[index];
                        final imgUrl = resolveApiImage(a.imageUrl);

                        return BusinessListItemCard(
                          id: '${a.id}',
                          title: a.name,
                          startDate: a.startDate,
                          location: a.location,
                          imageUrl: imgUrl,
                          onView: () async {
                            final result = await LegacyNav.pushNamed(
                              context,
                              Routes.businessActivityDetails,
                              arguments: BusinessActivityDetailsRouteArgs(
                                token: widget.token,
                                activityId: a.id,
                              ),
                            );

                            if (result == true) {
                              context.read<BusinessActivitiesBloc>().add(
                                LoadBusinessActivities(
                                  token: widget.token,
                                  businessId: widget.businessId,
                                ),
                              );
                            }
                          },

                          onEdit: () {
                            LegacyNav.pushNamed(
                              context,
                              Routes.editBusinessActivity,
                              arguments: EditActivityRouteArgs(
                                itemId: a.id,
                                businessId: widget.businessId,
                              ),
                            );
                          },
                          onDelete: () {
                            context.read<BusinessActivitiesBloc>().add(
                              DeleteBusinessActivityEvent(
                                token: widget.token,
                                id: a.id,
                              ),
                            );
                          },
                          onReopen: a.status.toLowerCase() == 'terminated'
                              ? () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => ReopenItemPage(
                                        businessId: widget.businessId,
                                        oldItem:
                                            a, // pass the terminated activity
                                        getItemTypes: GetItemTypes(
                                          // create repo inside here
                                          ItemTypeRepositoryImpl(
                                            ItemTypesService(),
                                          ),
                                        ),
                                        getCurrentCurrency: GetCurrentCurrency(
                                          CurrencyRepositoryImpl(
                                            CurrencyService(),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null,
                        );
                      },
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
    );
  }
}
