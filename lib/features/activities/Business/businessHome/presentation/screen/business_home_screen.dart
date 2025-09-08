// ===== Flutter 3.35.x =====
// BusinessHomeScreen — open Create/Edit via router, list-only version

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/welcome_section.dart';

// Domain
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';

// Data
import 'package:hobby_sphere/features/activities/Business/common/data/repositories/business_activity_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/services/business_activity_service.dart';

// UI widgets
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/header.dart';
import 'package:hobby_sphere/shared/widgets/BusinessListItemCard.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;

// Bloc
import '../bloc/business_home_bloc.dart';
import '../bloc/business_home_event.dart';
import '../bloc/business_home_state.dart';

class BusinessHomeScreen extends StatelessWidget {
  final String token;
  final int businessId;
  final void Function(BuildContext context, int businessId) onCreate;
  final Widget? bottomBar;

  const BusinessHomeScreen({
    super.key,
    required this.token,
    required this.businessId,
    required this.onCreate,
    this.bottomBar,
  });

  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final service = BusinessActivityService();
    final repo = BusinessActivityRepositoryImpl(service);
    final getList = GetBusinessActivities(repo);
    final getOne = GetBusinessActivityById(repo);
    final deleteOne = DeleteBusinessActivity(repo);

    return BlocProvider(
      create: (_) => BusinessHomeBloc(
        getList: getList,
        getOne: getOne,
        deleteOne: deleteOne,
        token: token,
        businessId: businessId,
        optimisticDelete: false,
      )..add(const BusinessHomeStarted()),
      child: _BusinessHomeView(
        onCreate: onCreate,
        serverRoot: _serverRoot(),
        bottomBar: bottomBar,
        businessId: businessId,
        token: token,
      ),
    );
  }
}

class _BusinessHomeView extends StatelessWidget {
  final void Function(BuildContext context, int businessId) onCreate;
  final String serverRoot;
  final Widget? bottomBar;
  final int businessId;
  final String token;

  const _BusinessHomeView({
    required this.onCreate,
    required this.serverRoot,
    this.bottomBar,
    required this.businessId,
    required this.token,
  });

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
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WelcomeSection(
          token: context.read<BusinessHomeBloc>().token,
          onOpenNotifications: () {
            Navigator.pushNamed(
              context,
              Routes.businessNotifications,
              arguments: BusinessNotificationsRouteArgs(
                token: token,
                businessId: businessId,
              ),
            );
          },
          onOpenCreateActivity: () => onCreate(context, businessId),
        ),
        const HeaderWithBadge(),
      ],
    );

    return BlocConsumer<BusinessHomeBloc, BusinessHomeState>(
      listenWhen: (p, c) => p.message != c.message || p.error != c.error,
      listener: (context, state) {
        if (state.message != null && state.message!.isNotEmpty) {
          _toast(context, state.message!);
          context.read<BusinessHomeBloc>().add(
            const BusinessHomeFeedbackCleared(),
          );
        } else if (state.error != null && state.error!.isNotEmpty) {
          _toast(context, state.error!, error: true);
          context.read<BusinessHomeBloc>().add(
            const BusinessHomeFeedbackCleared(),
          );
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cs.background,
          body: RefreshIndicator(
            onRefresh: () {
              final c = Completer<void>();
              context.read<BusinessHomeBloc>().add(
                BusinessHomeRefreshed(ack: c),
              );
              return c.future;
            },
            child: CustomScrollView(
              slivers: [
                SliverToBoxAdapter(child: header),
                if (state.items.isEmpty && !state.loading)
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Center(
                      child: Text(
                        t.activitiesEmpty,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  )
                else
                  SliverList(
                    delegate: SliverChildBuilderDelegate((ctx, index) {
                      final a = state.items[index];
                      if (a.status.toLowerCase() == 'terminated') {
                        return const SizedBox();
                      }
                      return BusinessListItemCard(
                        id: '${a.id}',
                        title: a.name,
                        startDate: a.startDate,
                        location: a.location,
                        imageUrl: a.imageUrl,
                        onView: () => context.read<BusinessHomeBloc>().add(
                          BusinessHomeViewRequested(a.id),
                        ),
                        onEdit: () {
                          final rootCtx = Navigator.of(
                            context,
                            rootNavigator: true,
                          ).context;
                          Navigator.pushNamed(
                            rootCtx,
                            Routes.editBusinessActivity,
                            arguments: EditActivityRouteArgs(
                              itemId: a.id,
                              businessId: businessId,
                            ),
                          );
                        },
                        onDelete: () => _confirmDelete(ctx, a.id),
                      );
                    }, childCount: state.items.length),
                  ),
              ],
            ),
          ),
          bottomNavigationBar: bottomBar,
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete?'),
        content: const Text('Are you sure you want to delete this activity?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (ok == true) {
      context.read<BusinessHomeBloc>().add(BusinessHomeDeleteRequested(id));
    }
  }
}
