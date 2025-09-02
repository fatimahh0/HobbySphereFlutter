// ===== Flutter 3.35.x =====
// BusinessHomeScreen — open Edit via router (no bloc edit event)

import 'dart:async'; // Completer for pull-to-refresh

import 'package:flutter/material.dart'; // Flutter UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:hobby_sphere/app/router/router.dart'; // Routes + args
import 'package:hobby_sphere/core/network/globals.dart' as g; // server base
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/welcome_section.dart'; // header

// Domain wiring (list/view/delete usecases)
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart'; // get list
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart'; // get one (used by bloc view)
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart'; // delete

// Data layer for above usecases
import 'package:hobby_sphere/features/activities/Business/common/data/repositories/business_activity_repository_impl.dart'; // repo impl
import 'package:hobby_sphere/features/activities/Business/common/data/services/business_activity_service.dart'; // service

// UI widgets
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/header.dart'; // section header
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/upcoming_activities_grid.dart'; // grid
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // l10n
import 'package:hobby_sphere/shared/widgets/cards/card_activity_business/index.dart'; // card

// Bloc
import '../bloc/business_home_bloc.dart'; // bloc
import '../bloc/business_home_event.dart'; // events
import '../bloc/business_home_state.dart'; // state

class BusinessHomeScreen extends StatelessWidget {
  final String token; // auth token
  final int businessId; // business id
  final VoidCallback onCreate; // navigate to create
  final Widget? bottomBar; // optional bottom bar

  const BusinessHomeScreen({
    super.key, // super key
    required this.token, // inject token
    required this.businessId, // inject id
    required this.onCreate, // inject create action
    this.bottomBar, // optional
  });

  String _serverRoot() {
    final base = (g.appServerRoot ?? ''); // read server base
    return base.replaceFirst(RegExp(r'/api/?$'), ''); // strip /api
  }

  @override
  Widget build(BuildContext context) {
    // wire data layer here (keeps router simple)
    final service = BusinessActivityService(); // http service
    final repo = BusinessActivityRepositoryImpl(service); // repo
    final getList = GetBusinessActivities(repo); // usecase list
    final getOne = GetBusinessActivityById(repo); // usecase one (view)
    final deleteOne = DeleteBusinessActivity(repo); // usecase delete

    return BlocProvider(
      create: (_) => BusinessHomeBloc(
        getList: getList, // list usecase
        getOne: getOne, // view usecase
        deleteOne: deleteOne, // delete usecase
        token: token, // token
        businessId: businessId, // id
        optimisticDelete: false, // set true for instant UI delete
      )..add(const BusinessHomeStarted()), // load on start
      child: _BusinessHomeView(
        onCreate: onCreate,
        serverRoot: _serverRoot(),
        bottomBar: bottomBar,
        businessId: businessId, // 👈 new
      ),
    );
  }
}

class _BusinessHomeView extends StatelessWidget {
  final VoidCallback onCreate;
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
    final rootCtx = Navigator.of(
      context,
      rootNavigator: true,
    ).context; // root ctx
    showTopToast(
      rootCtx, // show on root navigator
      msg, // message
      type: error ? ToastType.error : ToastType.success, // type
      haptics: true, // haptics
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n
    final cs = Theme.of(context).colorScheme; // theme colors

    // top header section
    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start, // left align
      children: [
        WelcomeSection(
          token: context.read<BusinessHomeBloc>().token, // pass token
          onOpenNotifications: () {}, // TODO notifications
          onOpenCreateActivity: onCreate, // open create via router
        ),
        const HeaderWithBadge(), // small badge row
      ],
    );

    return BlocConsumer<BusinessHomeBloc, BusinessHomeState>(
      listenWhen: (p, c) =>
          p.message != c.message ||
          p.error != c.error, // only on feedback change
      listener: (context, state) {
        if (state.message != null && state.message!.isNotEmpty) {
          _toast(context, state.message!); // success toast
          context.read<BusinessHomeBloc>().add(
            const BusinessHomeFeedbackCleared(),
          ); // clear msg
        } else if (state.error != null && state.error!.isNotEmpty) {
          _toast(context, state.error!, error: true); // error toast
          context.read<BusinessHomeBloc>().add(
            const BusinessHomeFeedbackCleared(),
          ); // clear error
        }
      },
      builder: (context, state) {
        return Scaffold(
          backgroundColor: cs.background, // themed background
          body: UpcomingActivitiesGrid(
            data: state
                .items // map domain model → card data map
                .map(
                  (a) => {
                    'id': a.id, // id
                    'title': a.name, // title
                    'type': a.type, // type label
                    'startDate': a.startDate, // date
                    'participants': a.maxParticipants, // max
                    'price': a.price, // price
                    'status': a.status, // status
                    'imageUrl': a.imageUrl, // cover
                  },
                )
                .toList(),
            loading: state.loading, // initial loading
            refreshing: state.refreshing, // pull-to-refresh spinner
            // RefreshIndicator waits for bloc refresh to finish
            onRefresh: () {
              final c = Completer<void>(); // future to await
              context.read<BusinessHomeBloc>().add(
                BusinessHomeRefreshed(ack: c),
              ); // ask bloc to refresh
              return c.future; // complete when bloc done
            },

            header: header, // header widget
            emptyText: t.activitiesEmpty, // l10n empty text
            masonry: true, // masonry grid
            // build each grid item
            itemBuilder: (ctx, item) {
              final mq = MediaQuery.of(ctx); // local media
              final clamped = mq.textScaleFactor.clamp(
                1.0,
                1.35,
              ); // clamp scale
              return MediaQuery(
                data: mq.copyWith(textScaleFactor: clamped), // apply clamp
                child: CardActivityBusiness(
                  id: '${item['id']}', // string id
                  title: (item['title'] ?? 'Unnamed').toString(), // title
                  subtitle: (item['type'] as String?)?.isEmpty == true
                      ? null
                      : item['type'] as String?, // optional subtitle
                  startDate: item['startDate'] as DateTime?, // date
                  participants:
                      (item['participants'] as int?) ?? 0, // participants
                  price: (item['price'] as double?) ?? 0.0, // price
                  currency: state.currency, // currency code
                  status: (item['status'] ?? '').toString(), // status
                  imageUrl: item['imageUrl']?.toString(), // image
                  serverRoot: serverRoot, // server root
                  // view details via bloc event (if you have a details sheet)
                  onView: () => context.read<BusinessHomeBloc>().add(
                    BusinessHomeViewRequested(item['id'] as int),
                  ),

                  // EDIT: navigate using router (no bloc edit event)
                  onEdit: () async {
                    final rootCtx = Navigator.of(
                      context,
                      rootNavigator: true,
                    ).context;

                    final updated = await Navigator.pushNamed(
                      rootCtx,
                      Routes.editBusinessActivity,
                      arguments: EditActivityRouteArgs(
                        itemId: item['id'] as int,
                        businessId: businessId,
                      ),
                    );

                    if (updated == true && context.mounted) {
                      context.read<BusinessHomeBloc>().add(
                        const BusinessHomeRefreshed(),
                      );
                    }
                  },

                  // delete with confirm
                  onDelete: () => _confirmDelete(
                    ctx,
                    item['id'] as int,
                  ), // confirm + delete
                  // optional reopen button visible for terminated
                  onReopen:
                      ((item['status'] ?? '').toString().toLowerCase() ==
                          'terminated')
                      ? () =>
                            _toast(
                              ctx,
                              'Reopen flow for #${item["id"]}',
                            ) // TODO: implement reopen
                      : null, // hide otherwise
                ),
              );
            },
          ),
          bottomNavigationBar: bottomBar, // optional bar
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, int id) async {
    // ask user to confirm delete
    final ok = await showDialog<bool>(
      context: context, // context
      builder: (ctx) => AlertDialog(
        title: const Text('Delete?'), // title
        content: const Text(
          'Are you sure you want to delete this activity?',
        ), // body
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // cancel
            child: const Text('Cancel'), // label
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true), // confirm
            child: const Text('Delete'), // label
          ),
        ],
      ),
    );
    if (ok == true) {
      // dispatch delete request
      context.read<BusinessHomeBloc>().add(
        BusinessHomeDeleteRequested(id),
      ); // delete
    }
  }
}
