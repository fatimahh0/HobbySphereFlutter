import "package:flutter/material.dart";
import "package:hobby_sphere/app/router/router.dart";
import "package:hobby_sphere/core/network/globals.dart" as g;

// Domain & data wiring
import "package:hobby_sphere/features/activities/Business/common/domain/entities/business_activity.dart";
import "package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart";
import "package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart";
import "package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart";
import "package:hobby_sphere/features/activities/Business/common/data/repositories/business_activity_repository_impl.dart";
import "package:hobby_sphere/features/activities/Business/common/data/services/business_activity_service.dart";

// Presentation widgets
import "package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/header.dart";
import "package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/upcoming_activities_grid.dart";
import "package:hobby_sphere/features/activities/Business/businessHome/presentation/widgets/welcome_section.dart";
import "package:hobby_sphere/shared/widgets/top_toast.dart";

// Local state controller
import "../state/business_home_controller.dart";

// i18n & card
import "package:hobby_sphere/l10n/app_localizations.dart" show AppLocalizations;
import "package:hobby_sphere/shared/widgets/cards/card_activity_business/index.dart";

class BusinessHomeScreen extends StatefulWidget {
  final String token;
  final int businessId;
  final VoidCallback onCreate;
  final Widget? bottomBar;

  const BusinessHomeScreen({
    super.key,
    required this.token,
    required this.businessId,
    required this.onCreate,
    this.bottomBar,
  });

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState();
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  late final BusinessHomeController _ctrl;

  String _serverRoot() {
    final base = (g.appServerRoot ?? "");
    return base.replaceFirst(RegExp(r"/api/?$"), "");
  }

  void _toast(String msg, {bool error = false}) {
    if (!mounted) return;
    final rootCtx = Navigator.of(context, rootNavigator: true).context;
    showTopToast(
      rootCtx,
      msg,
      type: error ? ToastType.error : ToastType.success,
      haptics: true,
    );
  }

  @override
  void initState() {
    super.initState();

    // Build the usecase chain (wiring only)
    final service = BusinessActivityService();
    final repo = BusinessActivityRepositoryImpl(service);
    final getList = GetBusinessActivities(repo);
    final getOne = GetBusinessActivityById(repo);
    final deleteOne = DeleteBusinessActivity(repo);

    // Create controller with session context
    _ctrl = BusinessHomeController(
      getList: getList,
      getOne: getOne,
      deleteOne: deleteOne,
      token: widget.token,
      businessId: widget.businessId,
    );

    _ctrl.onInfo = (m) => _toast(m);
    _ctrl.onError = (m) => _toast(m, error: true);

    _ctrl.load();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start, // align left
      children: [
        WelcomeSection(
          token: widget.token, // pass token to header if needed
          onOpenNotifications: () {}, // keep your notifications action
          onOpenCreateActivity: () {
            // when button is pressed
            Navigator.pushNamed(
              // push a named route
              context, // current context
              '/business/activity/create', // route name for create screen
              arguments: CreateActivityRouteArgs(
                // pass typed arguments
                businessId: widget.businessId, // pass the current business id
              ),
            );
          },
        ),
        const HeaderWithBadge(), // keep your header badge
      ],
    );

    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final state = _ctrl.state;

        return Scaffold(
          backgroundColor: cs.background,
          body: UpcomingActivitiesGrid(
            data: state.items
                .map(
                  (a) => {
                    "id": a.id,
                    "title": a.name,
                    "type": a.type,
                    "startDate": a.startDate,
                    "participants": a.maxParticipants,
                    "price": a.price,
                    "status": a.status,
                    "imageUrl": a.imageUrl,
                  },
                )
                .toList(),
            loading: state.loading,
            refreshing: state.refreshing,
            onRefresh: _ctrl.refresh,
            header: header,
            emptyText: t.activitiesEmpty,
            masonry: true,
            itemBuilder: (ctx, item) {
              final mq = MediaQuery.of(ctx);
              final clamped = mq.textScaleFactor.clamp(1.0, 1.35);

              return MediaQuery(
                data: mq.copyWith(textScaleFactor: clamped),
                child: CardActivityBusiness(
                  id: "${item["id"]}",
                  title: (item["title"] ?? "Unnamed").toString(),
                  subtitle: (item["type"] as String?)?.isEmpty == true
                      ? null
                      : item["type"] as String?,
                  startDate: item["startDate"] as DateTime?,
                  participants: (item["participants"] as int?) ?? 0,
                  price: (item["price"] as double?) ?? 0.0,
                  currency: state.currency,
                  status: (item["status"] ?? "").toString(),
                  imageUrl: item["imageUrl"]?.toString(),
                  serverRoot: _serverRoot(),
                  onView: () => _ctrl.openDetails(item["id"] as int),
                  onEdit: () => _ctrl.openEdit(item["id"] as int),
                  onDelete: () => _confirmDelete(item["id"] as int),
                  onReopen:
                      ((item["status"] ?? "").toString().toLowerCase() ==
                          "terminated")
                      ? () => _toast("Reopen flow for #${item["id"]}")
                      : null,
                ),
              );
            },
          ),
          bottomNavigationBar: widget.bottomBar,
        );
      },
    );
  }

  Future<void> _confirmDelete(int id) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Delete?"),
        content: const Text("Are you sure you want to delete this activity?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );
    if (ok == true) {
      await _ctrl.deleteActivity(id);
    }
  }
}
