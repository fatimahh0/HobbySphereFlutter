// ===== Flutter 3.35.x =====
// BusinessHomeScreen — open Create/Edit via router

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
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/upcoming_activities_grid.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/widgets/cards/card_activity_business/index.dart';

// Bloc
import '../bloc/business_home_bloc.dart';
import '../bloc/business_home_event.dart';
import '../bloc/business_home_state.dart';

class BusinessHomeScreen extends StatelessWidget {
  final String token;
  final int businessId;
  final void Function(BuildContext context, int businessId)
  onCreate; // ✅ updated
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
      ),
    );
  }
}

class _BusinessHomeView extends StatelessWidget {
  final void Function(BuildContext context, int businessId)
  onCreate; // ✅ updated
  final String serverRoot;
  final Widget? bottomBar;
  final int businessId;

  const _BusinessHomeView({
    required this.onCreate,
    required this.serverRoot,
    this.bottomBar,
    required this.businessId,
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
          onOpenNotifications: () {},
          onOpenCreateActivity: () =>
              onCreate(context, businessId), // ✅ updated
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
          body: UpcomingActivitiesGrid(
            data: state.items
                // ✅ Filter: show only upcoming (not terminated)
                .where((a) => (a.status.toLowerCase() != 'terminated'))
                .map(
                  (a) => {
                    'id': a.id,
                    'title': a.name,
                    'type': a.type,
                    'startDate': a.startDate,
                    'participants': a.maxParticipants,
                    'price': a.price,
                    'status': a.status,
                    'imageUrl': a.imageUrl,
                  },
                )
                .toList(),
            loading: state.loading,
            refreshing: state.refreshing,
            onRefresh: () {
              final c = Completer<void>();
              context.read<BusinessHomeBloc>().add(
                BusinessHomeRefreshed(ack: c),
              );
              return c.future;
            },
            header: header,
            emptyText: t.activitiesEmpty,
            masonry: true,
            itemBuilder: (ctx, item) {
              final mq = MediaQuery.of(ctx);
              final clamped = mq.textScaleFactor.clamp(1.0, 1.35);
              return MediaQuery(
                data: mq.copyWith(textScaleFactor: clamped),
                child: CardActivityBusiness(
                  id: '${item['id']}',
                  title: (item['title'] ?? 'Unnamed').toString(),
                  subtitle: (item['type'] as String?)?.isEmpty == true
                      ? null
                      : item['type'] as String?,
                  startDate: item['startDate'] as DateTime?,
                  participants: (item['participants'] as int?) ?? 0,
                  price: (item['price'] as double?) ?? 0.0,
                  currency: state.currency,
                  status: (item['status'] ?? '').toString(),
                  imageUrl: item['imageUrl']?.toString(),
                  serverRoot: serverRoot,
                  onView: () => context.read<BusinessHomeBloc>().add(
                    BusinessHomeViewRequested(item['id'] as int),
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
                        itemId: item['id'] as int,
                        businessId: businessId,
                      ),
                    );
                  },
                  onDelete: () => _confirmDelete(ctx, item['id'] as int),
                  onReopen: null, // ❌ not in home, only in activities
                ),
              );
            },
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
