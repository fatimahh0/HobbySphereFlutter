// ===== Flutter 3.35.x =====

import 'dart:async'; // async utils
import 'package:flutter/material.dart'; // flutter ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/core/network/globals.dart' as g; // server helpers
import 'package:hobby_sphere/app/router/router.dart'; // routes + args
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/bloc/business_activities_bloc.dart'; // bloc
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/bloc/business_activities_event.dart'; // events
import 'package:hobby_sphere/features/activities/business/businessActivity/presentation/bloc/business_activities_state';

import 'package:hobby_sphere/features/activities/business/common/presentation/screen/ReopenItemPage.dart'; // reopen page
import 'package:hobby_sphere/app/router/legacy_nav.dart'; // legacy nav
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart'; // currency repo
import 'package:hobby_sphere/features/activities/common/data/repositories/item_type_repository_impl.dart'; // type repo
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart'; // currency api
import 'package:hobby_sphere/features/activities/common/data/services/item_types_service.dart'; // type api
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart'; // currency usecase
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_item_types.dart'; // type usecase
import 'package:hobby_sphere/features/activities/business/common/domain/usecases/get_business_activity_by_id.dart'; // details args

import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart'; // search bar
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // button
import 'package:hobby_sphere/shared/widgets/BusinessListItemCard.dart'; // list card
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

/// ensure image URLs are absolute
String? resolveApiImage(String? raw) {
  if (raw == null || raw.isEmpty) return null; // nothing
  if (raw.startsWith('http://') || raw.startsWith('https://'))
    return raw; // already absolute
  return '${g.serverRootNoApi()}$raw'; // prefix with host
}

class BusinessActivitiesScreen extends StatefulWidget {
  final String token; // auth token
  final int businessId; // business id

  const BusinessActivitiesScreen({
    super.key,
    required this.token, // require token
    required this.businessId, // require id
  });

  @override
  State<BusinessActivitiesScreen> createState() =>
      _BusinessActivitiesScreenState(); // state
}

class _BusinessActivitiesScreenState extends State<BusinessActivitiesScreen> {
  String _query = ''; // search text
  String _tab = 'Upcoming'; // current tab
  String _currency = ''; // currency code

  bool _bootstrapped = false; // guard to dispatch initial load once

  @override
  void initState() {
    super.initState(); // base
    _loadCurrency(); // load currency once

    // === FIX #1: dispatch initial load after first frame ===
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_bootstrapped) return; // already dispatched
      _bootstrapped = true; // mark dispatched
      context.read<BusinessActivitiesBloc>().add(
        LoadBusinessActivities(
          token: widget.token, // pass token
          businessId: widget.businessId, // pass id
        ),
      );
    });
  }

  Future<void> _loadCurrency() async {
    try {
      final repo = CurrencyRepositoryImpl(CurrencyService()); // build repo
      final usecase = GetCurrentCurrency(repo); // build usecase
      final cur = await usecase(widget.token); // call with token
      setState(() => _currency = cur.code); // save code
    } catch (e) {
      debugPrint('Error loading currency: $e'); // log only
    }
  }

  void _toast(BuildContext context, String msg, {bool error = false}) {
    final rootCtx = Navigator.of(
      context,
      rootNavigator: true,
    ).context; // overlay ctx
    showTopToast(
      rootCtx, // where to show
      msg, // text
      type: error ? ToastType.error : ToastType.success, // style
      haptics: true, // vibration
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // i18n
    final theme = Theme.of(context); // theme

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // bg
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(72), // height
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // spacing
            child: AppSearchBar(
              hint: tr.searchPlaceholder, // hint
              onQueryChanged: (q) =>
                  setState(() => _query = q), // update search
              onClear: () => setState(() => _query = ''), // clear search
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // ===== Tabs (Upcoming / Terminated) =====
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 8,
            ), // spacing
            child: Row(
              children: [
                Expanded(
                  child: AppButton(
                    label: tr.upcoming, // text
                    type: _tab == 'Upcoming'
                        ? AppButtonType.primary
                        : AppButtonType.outline, // style
                    expand: true, // full width
                    onPressed: () =>
                        setState(() => _tab = 'Upcoming'), // switch
                  ),
                ),
                const SizedBox(width: 12), // gap
                Expanded(
                  child: AppButton(
                    label: tr.terminated, // text
                    type: _tab == 'Terminated'
                        ? AppButtonType.primary
                        : AppButtonType.outline, // style
                    expand: true, // full width
                    onPressed: () =>
                        setState(() => _tab = 'Terminated'), // switch
                  ),
                ),
              ],
            ),
          ),

          // ===== List / Empty / Error / Loading =====
          Expanded(
            child: BlocConsumer<BusinessActivitiesBloc, BusinessActivitiesState>(
              listenWhen: (p, c) =>
                  p is BusinessActivitiesError ||
                  c is BusinessActivitiesError, // only errors
              listener: (context, state) {
                if (state is BusinessActivitiesError) {
                  _toast(
                    context,
                    state.message,
                    error: true,
                  ); // show toast on error
                }
              },
              builder: (context, state) {
                // Loading → spinner (only while fetching)
                if (state is BusinessActivitiesLoading) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  ); // spinner
                }

                // Loaded → render list or empty
                if (state is BusinessActivitiesLoaded) {
                  var list = state.activities; // copy list

                  // filter by tab (terminated vs upcoming)
                  list = list.where((a) {
                    final isTerminated =
                        a.status.toLowerCase() == 'terminated'; // status
                    return _tab == 'Upcoming'
                        ? !isTerminated
                        : isTerminated; // keep
                  }).toList();

                  // filter by query (name contains)
                  if (_query.isNotEmpty) {
                    list = list
                        .where(
                          (a) => a.name.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                        ) // match
                        .toList();
                  }

                  // empty after filters → empty message (no loading)
                  if (list.isEmpty) {
                    return Center(
                      child: Text(
                        tr.activitiesEmpty, // “No activities yet”
                        style: theme.textTheme.bodyMedium, // style
                      ),
                    );
                  }

                  // normal list + pull to refresh
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<BusinessActivitiesBloc>().add(
                        LoadBusinessActivities(
                          token: widget.token, // token
                          businessId: widget.businessId, // id
                        ),
                      );
                    },
                    child: ListView.builder(
                      itemCount: list.length, // count
                      itemBuilder: (ctx, index) {
                        final a = list[index]; // item
                        final imgUrl = resolveApiImage(a.imageUrl); // cover

                        return BusinessListItemCard(
                          id: '${a.id}', // id
                          title: a.name, // title
                          startDate: a.startDate, // start date
                          location: a.location, // location
                          imageUrl: imgUrl, // image
                          onView: () async {
                            // open details
                            final result = await LegacyNav.pushNamed(
                              context, // ctx
                              Routes.businessActivityDetails, // route
                              arguments: BusinessActivityDetailsRouteArgs(
                                token: widget.token, // token
                                activityId: a.id, // id
                              ),
                            );
                            // if details modified → reload
                            if (result == true) {
                              context.read<BusinessActivitiesBloc>().add(
                                LoadBusinessActivities(
                                  token: widget.token, // token
                                  businessId: widget.businessId, // id
                                ),
                              );
                            }
                          },
                          onEdit: () {
                            // go to edit
                            LegacyNav.pushNamed(
                              context, // ctx
                              Routes.editBusinessActivity, // route
                              arguments: EditActivityRouteArgs(
                                itemId: a.id, // item id
                                businessId: widget.businessId, // business id
                              ),
                            );
                          },
                          onDelete: () {
                            // dispatch delete
                            context.read<BusinessActivitiesBloc>().add(
                              DeleteBusinessActivityEvent(
                                token: widget.token, // token
                                id: a.id, // id
                              ),
                            );
                          },
                          onReopen: a.status.toLowerCase() == 'terminated'
                              ? () {
                                  // open reopen page
                                  Navigator.push(
                                    context, // ctx
                                    MaterialPageRoute(
                                      builder: (_) => ReopenItemPage(
                                        businessId: widget.businessId, // id
                                        oldItem: a, // pass item
                                        getItemTypes: GetItemTypes(
                                          ItemTypeRepositoryImpl(
                                            ItemTypesService(),
                                          ), // types
                                        ),
                                        getCurrentCurrency: GetCurrentCurrency(
                                          CurrencyRepositoryImpl(
                                            CurrencyService(),
                                          ), // currency
                                        ),
                                      ),
                                    ),
                                  );
                                }
                              : null, // only for terminated
                        );
                      },
                    ),
                  );
                }

                // Error → detect "no data" and show empty (no spinner)
                if (state is BusinessActivitiesError) {
                  final msg = state.message.toLowerCase(); // normalize
                  final looksLikeEmpty =
                      msg.contains('404') ||
                      msg.contains('not found') ||
                      msg.contains('no activities'); // simple heuristics

                  if (looksLikeEmpty) {
                    // === FIX #2: treat 404/no-data as empty, not loading ===
                    return Center(
                      child: Text(
                        tr.activitiesEmpty, // empty message
                        style: theme.textTheme.bodyMedium, // style
                      ),
                    );
                  }

                  // unknown error → simple retry ui (optional)
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // compact
                      children: [
                        Text(
                          tr.somethingWentWrong,
                          style: theme.textTheme.titleMedium,
                        ), // title
                        const SizedBox(height: 8), // gap
                        Text(
                          state.message,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodySmall,
                        ), // details
                        const SizedBox(height: 12), // gap
                        AppButton(
                          label: tr.retry, // retry text
                          type: AppButtonType.primary, // primary
                          onPressed: () {
                            // retry load
                            context.read<BusinessActivitiesBloc>().add(
                              LoadBusinessActivities(
                                token: widget.token, // token
                                businessId: widget.businessId, // id
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }

                // Initial/other → calm empty placeholder (no spinner)
                return Center(
                  child: Text(
                    tr.activitiesEmpty, // empty
                    style: theme.textTheme.bodyMedium, // style
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
