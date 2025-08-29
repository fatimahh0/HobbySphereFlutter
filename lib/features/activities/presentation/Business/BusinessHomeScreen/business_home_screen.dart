// ===== Flutter 3.35.x =====
// Business Home — Welcome, header, masonry grid of CardActivityBusiness.
import 'package:flutter/material.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/data/services/business/business_activity_service.dart';

// widgets (keep your current paths for these three)
import 'package:hobby_sphere/features/activities/presentation/Business/BusinessHomeScreen/widgets/header.dart';
import 'package:hobby_sphere/features/activities/presentation/Business/BusinessHomeScreen/widgets/upcoming_activities_grid.dart';
import 'package:hobby_sphere/features/activities/presentation/Business/BusinessHomeScreen/widgets/welcome_section.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;

// ✅ NEW: use the split card barrel export
import 'package:hobby_sphere/shared/widgets/cards/card_activity_business/index.dart';

typedef Json = Map<String, dynamic>;

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
  final _service = BusinessActivityService();
  List<Json> _items = [];
  bool _loading = true;
  bool _refreshing = false; // optional spinner flag
  String _currency = 'CAD';

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final list = await _service.getActivitiesByBusiness(
        businessId: widget.businessId,
        token: widget.token,
      );
      setState(() {
        _items = list.map<Json>((e) => Map<String, dynamic>.from(e)).toList();
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      if (!mounted) return;
      _toast('Load error: $e');
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true);
    await _load();
    if (mounted) setState(() => _refreshing = false);
  }

  DateTime? _parseDate(dynamic v) {
    if (v == null) return null;
    if (v is String) return DateTime.tryParse(v);
    if (v is num) return DateTime.fromMillisecondsSinceEpoch(v.toInt());
    return null;
  }

  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  void _toast(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _openDetails(int id) async {
    try {
      await _service.getBusinessActivityById(widget.token, id);
      _toast('Open details #$id'); // TODO: Navigator.pushNamed(...)
    } catch (e) {
      _toast('Details error: $e');
    }
  }

  Future<void> _openEdit(int id) async {
    try {
      await _service.getBusinessActivityById(widget.token, id);
      _toast('Open edit #$id'); // TODO: Navigator.pushNamed(...)
    } catch (e) {
      _toast('Edit error: $e');
    }
  }

  Future<void> _confirmDelete(int id) async {
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
    if (ok != true) return;
    try {
      await _service.deleteBusinessActivity(widget.token, id);
      _toast('Deleted');
      _load();
    } catch (e) {
      _toast('Delete error: $e');
    }
  }

  Future<void> _reopen(int id) async {
    try {
      await _service.getBusinessActivityById(widget.token, id);
      _toast('Reopen flow for #$id'); // TODO: Navigator to reopen flow
      await _load();
    } catch (e) {
      _toast('Reopen error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    final header = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        WelcomeSection(
          token: widget.token,
          onOpenNotifications: () {
            // Navigator.pushNamed(context, '/business/notifications');
          },
          onOpenCreateActivity: widget.onCreate,
        ),
        const HeaderWithBadge(),
      ],
    );

    return Scaffold(
      backgroundColor: cs.background,
      body: UpcomingActivitiesGrid(
        data: _items,
        loading: _loading,
        refreshing: _refreshing,
        onRefresh: _onRefresh,
        header: header,
        emptyText: t.activitiesEmpty,
        masonry: true, // ✅ auto-height grid
        itemBuilder: (ctx, item) {
          // Optional: clamp extreme accessibility font sizes per card
          final mq = MediaQuery.of(ctx);
          final clamped = mq.textScaleFactor.clamp(1.0, 1.35);

          return MediaQuery(
            data: mq.copyWith(textScaleFactor: clamped),
            child: CardActivityBusiness(
              id: '${item['id']}',
              title: (item['itemName'] ?? 'Unnamed').toString(),
              subtitle: item['itemType']?['activity_type']?.toString(),
              startDate: _parseDate(item['startDatetime']),
              participants: (item['maxParticipants'] ?? 0) as int,
              price: (item['price'] as num?)?.toDouble() ?? 0.0,
              currency: _currency,
              status: (item['status'] ?? '').toString(),
              imageUrl: item['imageUrl']?.toString(),
              serverRoot: _serverRoot(),
              onView: () => _openDetails(item['id'] as int),
              onEdit: () => _openEdit(item['id'] as int),
              onDelete: () => _confirmDelete(item['id'] as int),
              onReopen:
                  (item['status']?.toString().toLowerCase() == 'terminated')
                  ? () => _reopen(item['id'] as int)
                  : null,
              // If you added an i18n key:
              // participantsLabel: t.participantsLabel,
            ),
          );
        },
      ),
      bottomNavigationBar: widget.bottomBar,
    );
  }
}
