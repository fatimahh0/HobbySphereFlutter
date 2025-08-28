// Flutter 3.35.x
import 'package:flutter/material.dart'; // UI widgets
import 'package:hobby_sphere/features/presentation/pages/Business/BusinessHomeScreen/widgets/header.dart';
import 'package:hobby_sphere/features/presentation/pages/Business/BusinessHomeScreen/widgets/upcoming_activities_grid.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/core/services/business_activity_service.dart'; // API service

import 'package:hobby_sphere/ui/widgets/card_activity_business.dart'; // activity card

typedef Json = Map<String, dynamic>; // simple JSON alias

class BusinessHomeScreen extends StatefulWidget {
  final String token; // JWT token to call backend
  final int businessId; // current business id
  final VoidCallback onCreate; // navigate to create activity
  final Widget? bottomBar; // your existing bottom nav (optional)

  const BusinessHomeScreen({
    super.key, // widget key
    required this.token, // required token
    required this.businessId, // required business id
    required this.onCreate, // required create handler
    this.bottomBar, // optional bottom bar
  });

  @override
  State<BusinessHomeScreen> createState() => _BusinessHomeScreenState(); // state builder
}

class _BusinessHomeScreenState extends State<BusinessHomeScreen> {
  final _service = BusinessActivityService(); // api client instance
  List<Json> _items = []; // activities list
  bool _loading = true; // first-load spinner flag
  bool _refreshing = false; // pull-to-refresh flag

  @override
  void initState() {
    super.initState(); // base init
    _load(); // fetch data once
  }

  Future<void> _load() async {
    try {
      final list = await _service.getActivitiesByBusiness(
        businessId: widget.businessId, // pass id
        token: widget.token, // pass auth
      ); // GET /items/business/{id}
      setState(() {
        _items = list
            .map<Json>((e) => Map<String, dynamic>.from(e))
            .toList(); // normalize
        _loading = false; // stop first spinner
      }); // update UI
    } catch (e) {
      setState(() => _loading = false); // stop spinner on error
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Load error: $e')), // quick feedback
        ); // snack
      }
    }
  }

  Future<void> _onRefresh() async {
    setState(() => _refreshing = true); // show pull-to-refresh
    await _load(); // re-fetch
    setState(() => _refreshing = false); // hide pull-to-refresh
  }

  Widget _buildWelcomeHeader() {
    final t = AppLocalizations.of(context)!; // strings
    final scheme = Theme.of(context).colorScheme; // colors
    final text = Theme.of(context).textTheme; // fonts

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start, // left alignment
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8), // outer spacing
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, // left alignment
            children: [
              Text(
                t.businessWelcomeTitle, // "Welcome to your dashboard!"
                style: text.headlineSmall?.copyWith(
                  color: scheme.primary, // brand color
                  fontWeight: FontWeight.w700, // bold
                ), // style
              ), // title
              const SizedBox(height: 6), // small gap
              Text(
                t.businessWelcomeSubtitle, // "Manage your activities..."
                style: text.bodyMedium?.copyWith(
                  color: scheme.onSurface.withOpacity(0.75), // muted
                ), // style
              ), // subtitle
              const SizedBox(height: 12), // gap
              SizedBox(
                width: double.infinity, // full width
                child: ElevatedButton.icon(
                  onPressed: widget.onCreate, // go to create screen
                  icon: const Icon(Icons.add_circle_outline), // plus icon
                  label: Text(t.createNewActivity), // i18n button text
                  style: ElevatedButton.styleFrom(
                    backgroundColor: scheme.primary, // bg color
                    foregroundColor: scheme.onPrimary, // text/icon color
                    padding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ), // padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24), // pill
                    ), // shape
                    textStyle: text.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600, // semi-bold
                    ), // text style
                  ), // style
                ), // button
              ), // sized
            ],
          ), // column
        ), // padding

        const HeaderWithBadge(), // "Your Activities" row you gave
      ],
    ); // column
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background, // bg color
      body: UpcomingActivitiesGrid(
        data: _items, // list to show
        loading: _loading, // first load flag
        refreshing: _refreshing, // pull flag
        onRefresh: _onRefresh, // handler
        header: _buildWelcomeHeader(), // welcome + header
        emptyText: t.activitiesEmpty, // "No activities yet" (from ARB)
        itemBuilder: (ctx, item) {
          return CardActivityBusiness(
            item: item, // current activity json
            token: widget.token, // auth token
            onOpenDetails: (fresh) {
              // TODO: navigate to details page with `fresh`
              // Navigator.pushNamed(context, '/business/activity/details', arguments: fresh);
            }, // details callback
            onOpenEdit: (fresh) {
              // TODO: navigate to edit page with `fresh`
              // Navigator.pushNamed(context, '/business/activity/edit', arguments: fresh);
            }, // edit callback
            onOpenReopen: (fresh) {
              // TODO: navigate to reopen flow with `fresh`
              // Navigator.pushNamed(context, '/business/activity/reopen', arguments: fresh);
            }, // reopen callback
            onDeleted: _load, // after delete -> refresh list
          ); // card
        }, // builder
      ), // grid wrapper
      bottomNavigationBar: widget.bottomBar, // your bottom bar (don’t forget)
    ); // scaffold
  }
}
