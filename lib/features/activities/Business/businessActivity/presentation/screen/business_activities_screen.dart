// ===== Flutter 3.35.x =====
// BusinessActivitiesScreen — grid of business activities with search, tabs, delete, edit, reopen

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_state';
import 'package:hobby_sphere/features/activities/common/data/repositories/currency_repository_impl.dart';
import 'package:hobby_sphere/features/activities/common/data/services/currency_service.dart';
import 'package:hobby_sphere/features/activities/common/domain/usecases/get_current_currency.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/cards/card_activity_business/card_activity_business.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/upcoming_activities_grid.dart';

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
  String _currency = ''; // <-- store the currency code here

  @override
  void initState() {
    super.initState();
    _loadCurrency();
  }

  Future<void> _loadCurrency() async {
    try {
      // build repo + usecase (DI can be used if available)
      final repo = CurrencyRepositoryImpl(CurrencyService());
      final usecase = GetCurrentCurrency(repo);

      final cur = await usecase(widget.token);
      setState(() {
        _currency = cur.code; // e.g. "CAD"
      });
    } catch (e) {
      debugPrint('Error loading currency: $e');
    }
  }

  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
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
                    size: AppButtonSize.md,
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
                    size: AppButtonSize.md,
                    expand: true,
                    onPressed: () => setState(() => _tab = 'Terminated'),
                  ),
                ),
              ],
            ),
          ),

          // Grid
          Expanded(
            child:
                BlocConsumer<BusinessActivitiesBloc, BusinessActivitiesState>(
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
                        final isTerminated =
                            a.status.toLowerCase() == 'terminated';
                        return _tab == 'Upcoming'
                            ? !isTerminated
                            : isTerminated;
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

                      return UpcomingActivitiesGrid(
                        data: list
                            .map(
                              (a) => {
                                'id': a.id,
                                'title': a.name,
                                'type': a.description,
                                'startDate': a.startDate,
                                'participants': a.maxParticipants,
                                'price': a.price,
                                'status': a.status,
                                'imageUrl': a.imageUrl,
                              },
                            )
                            .toList(),
                        loading: false,
                        refreshing: false,
                        onRefresh: () async {
                          context.read<BusinessActivitiesBloc>().add(
                            LoadBusinessActivities(
                              token: widget.token,
                              businessId: widget.businessId,
                            ),
                          );
                          return Future.value();
                        },
                        header: const SizedBox.shrink(),
                        emptyText: tr.activitiesEmpty,
                        masonry: true,
                        itemBuilder: (ctx, item) {
                          final status = (item['status'] ?? '')
                              .toString()
                              .toLowerCase();

                          return CardActivityBusiness(
                            id: '${item['id']}',
                            title: (item['title'] ?? '').toString(),
                            subtitle: (item['type'] ?? '').toString(),
                            startDate: item['startDate'] as DateTime?,
                            participants: (item['participants'] as int?) ?? 0,
                            price: (item['price'] as double?) ?? 0.0,
                            currency: _currency, // <-- use loaded currency
                            status: (item['status'] ?? '').toString(),
                            imageUrl: item['imageUrl']?.toString(),
                            serverRoot: _serverRoot(),
                            onView: () {},
                            onEdit: () {
                              Navigator.pushNamed(
                                context,
                                Routes.editBusinessActivity,
                                arguments: EditActivityRouteArgs(
                                  itemId: item['id'] as int,
                                  businessId: widget.businessId,
                                ),
                              );
                            },
                            onDelete: () {
                              context.read<BusinessActivitiesBloc>().add(
                                DeleteBusinessActivityEvent(
                                  token: widget.token,
                                  id: item['id'] as int,
                                ),
                              );
                            },
                            onReopen: status == 'terminated'
                                ? () {
                                    _toast(
                                      ctx,
                                      'Reopen flow for #${item["id"]}',
                                    );
                                  }
                                : null,
                          );
                        },
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
