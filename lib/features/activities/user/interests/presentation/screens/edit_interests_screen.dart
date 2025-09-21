// ===== Edit Interests (pro, responsive) =====
// - uses your old GetActivityTypes + ActivityType + InterestsGridRemote
// - loads user-selected interests (names), maps to ids, preselects
// - saves by POST (replace)
// - no overflow: scrollable, max content width, SafeArea
// - responsive: looks good on phones, tablets, desktop

import 'package:flutter/material.dart'; // UI widgets
import 'package:dio/dio.dart'; // HTTP client
import 'package:flutter/services.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/get_activity_types.dart';
import 'package:hobby_sphere/features/authentication/presentation/register/widgets/interests_grid.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n strings
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // top toast

// === old domain/usecase/entities (adjust paths to your project) ===
import 'package:hobby_sphere/features/authentication/domain/entities/activity_type.dart'; // entity

// === tiny API wrapper for user interests (we made earlier) ===
import 'package:hobby_sphere/features/activities/user/interests/data/services/user_interests_api.dart';

// === optional shared Dio (fallback to new Dio) ===
import 'package:hobby_sphere/core/network/globals.dart' as g;

class EditInterestsScreen extends StatefulWidget {
  final String token; // user token
  final int userId; // user id
  final GetActivityTypes getTypes; // usecase (get all)

  const EditInterestsScreen({
    super.key, // key
    required this.token, // pass token
    required this.userId, // pass id
    required this.getTypes, // inject usecase
  });

  @override
  State<EditInterestsScreen> createState() => _EditInterestsScreenState(); // state
}

class _EditInterestsScreenState extends State<EditInterestsScreen> {
  // --- networking helpers ---
  late final Dio _dio = g.appDio ?? Dio(); // shared/new Dio
  late final UserInterestsApi _api = UserInterestsApi(_dio); // small API

  // --- UI state ---
  bool _loading = true; // initial spinner
  bool _saving = false; // save in progress
  bool _showAll = true; // show all grid items
  List<ActivityType> _items = <ActivityType>[]; // all types
  Set<int> _selected = <int>{}; // selected ids
  String? _error; // error message

  @override
  void initState() {
    super.initState(); // lifecycle
    _bootstrap(); // load data
  }

  Future<void> _bootstrap() async {
    // loads: all types + user's selected names, then maps to ids
    setState(() {
      _loading = true;
      _error = null;
    }); // show spinner
    try {
      final all = await widget.getTypes(); // fetch all types
      final names = await _api.getUserInterestNames(
        // fetch names
        widget.token, // token
        widget.userId, // id
      );
      final nameSet =
          names // normalize
              .map((e) => e.toLowerCase().trim())
              .toSet();
      final selectedIds =
          all // map names->ids
              .where((t) => nameSet.contains(t.name.toLowerCase().trim()))
              .map((t) => t.id)
              .toSet();
      setState(() {
        _items = all; // store all
        _selected = selectedIds; // store selected
        _loading = false; // stop spinner
      });
    } catch (e) {
      setState(() {
        // on error
        _loading = false; // stop spinner
        _error = e.toString(); // keep message
      });
    }
  }

  Future<void> _save() async {
    // saves selected ids using replace endpoint
    setState(() => _saving = true); // lock UI
    try {
      await _api.replaceUserInterests(
        // call API
        widget.token, // token
        widget.userId, // id
        _selected.toList(), // ids
      );
      if (!mounted) return; // guard
      showTopToast(
        // success toast
        context,
        AppLocalizations.of(context)!.interestSaved,
        type: ToastType.success,
        haptics: true,
      );
      Navigator.of(context).pop(); // close screen
    } catch (e) {
      if (!mounted) return; // guard
      showTopToast(context, '$e', type: ToastType.error); // error toast
    } finally {
      if (mounted) setState(() => _saving = false); // unlock UI
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // strings
    final cs = Theme.of(context).colorScheme; // colors
    final tt = Theme.of(context).textTheme; // typography

    // --- AppBar with subtle actions (no clutter) ---
    final appBar = AppBar(
      title: Text(t.editInterestsTitle), // title
      actions: [
        // small reset button (clears selection)
        IconButton(
          tooltip: t.cancel, // hint
          onPressed: _saving
              ? null
              : () {
                  // disable if saving
                  HapticFeedback.selectionClick(); // haptic
                  setState(() => _selected.clear()); // clear all
                },
          icon: const Icon(Icons.refresh_rounded), // icon
        ),
      ],
    );

    // --- Loading state (full screen, centered) ---
    if (_loading) {
      return Scaffold(
        appBar: appBar, // app bar
        body: const Center(child: CircularProgressIndicator()), // spinner
      );
    }

    // --- Error state (retry UI, no overflow) ---
    if (_error != null) {
      return Scaffold(
        appBar: appBar, // app bar
        body: Center(
          // center card
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420), // max width
            child: Padding(
              padding: const EdgeInsets.all(16), // padding
              child: Card(
                elevation: 0, // flat card
                color: cs.errorContainer, // error bg
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16), // round
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16), // inner pad
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // wrap content
                    children: [
                      Text(
                        t.somethingWentWrong, // generic text
                        style: tt.titleMedium?.copyWith(
                          color: cs.onErrorContainer, // contrast
                          fontWeight: FontWeight.w700, // bold
                        ),
                        textAlign: TextAlign.center, // center
                      ),
                      const SizedBox(height: 8), // space
                      Text(
                        _error!, // error body
                        style: tt.bodyMedium?.copyWith(
                          color: cs.onErrorContainer, // contrast
                        ),
                        textAlign: TextAlign.center, // center
                      ),
                      const SizedBox(height: 12), // space
                      FilledButton.tonalIcon(
                        onPressed: _bootstrap, // retry
                        icon: const Icon(Icons.refresh_rounded), // icon
                        label: Text(t.retry), // label
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // --- Main content (scrollable + responsive container) ---
    return Scaffold(
      appBar: appBar, // app bar
      body: SafeArea(
        // respect notches
        child: LayoutBuilder(
          // responsive
          builder: (context, constraints) {
            final maxW = constraints.maxWidth; // screen width
            final contentWidth = maxW.clamp(0, 900.0); // cap width
            return Center(
              // center on wide
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  // max width
                  maxWidth: 900, // desktop cap
                ),
                child: ScrollConfiguration(
                  // smooth scroll
                  behavior: const _NoGlow(), // remove glow
                  child: SingleChildScrollView(
                    // avoid overflow
                    padding: const EdgeInsets.symmetric(
                      // page padding
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.stretch, // full width
                      children: [
                        // subtle header text (kept minimal)
                        Text(
                          t.interestTitle, // e.g. "What are you into?"
                          textAlign: TextAlign.center, // center text
                          style: tt.titleLarge?.copyWith(
                            fontWeight: FontWeight.w800, // bold
                          ),
                        ),
                        const SizedBox(height: 12), // space
                        // card container for grid (visual grouping)
                        Card(
                          elevation: 0, // flat
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16), // round
                            side: BorderSide(
                              color: Theme.of(context).dividerColor, // border
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12), // inner pad
                            child: InterestsGridRemote(
                              // your grid widget
                              items: _items, // all types
                              selected: _selected, // selected ids
                              showAll: _showAll, // show all?
                              onToggleShow: () {
                                // expand/collapse
                                HapticFeedback.selectionClick(); // haptic
                                setState(() => _showAll = !_showAll); // flip
                              },
                              onToggle: (id) {
                                // toggle one
                                HapticFeedback.selectionClick(); // haptic
                                setState(() {
                                  _selected.contains(id) // if selected
                                      ? _selected.remove(id) // remove
                                      : _selected.add(id); // add
                                });
                              },
                              onSubmit: _saving
                                  ? () {}
                                  : _save, // bottom CTA (compat)
                            ),
                          ),
                        ),

                        const SizedBox(height: 16), // space
                        // tips / count (helps user understand selection)
                        Row(
                          mainAxisAlignment:
                              MainAxisAlignment.center, // center row
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: cs.secondary,
                            ), // info icon
                            const SizedBox(width: 6), // space
                            Text(
                              '${_selected.length} ${t.selected}', // "N selected"
                              style: tt.bodyMedium?.copyWith(
                                color: cs.secondary, // muted
                                fontWeight: FontWeight.w600, // semi-bold
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 88), // spacer to bottom bar
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),

      // --- Bottom action bar (safe, sticky, responsive) ---
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.fromLTRB(16, 8, 16, 16), // padding
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900), // match body cap
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  // cancel button
                  onPressed: _saving
                      ? null // disable when saving
                      : () => Navigator.of(context).pop(), // go back
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14), // height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28), // pill
                    ),
                  ),
                  child: Text(AppLocalizations.of(context)!.cancel), // "Cancel"
                ),
              ),
              const SizedBox(width: 12), // space
              Expanded(
                child: FilledButton(
                  // save button
                  onPressed: _saving ? null : _save, // save action
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14), // height
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28), // pill
                    ),
                  ),
                  child:
                      _saving // dynamic child
                      ? const SizedBox(
                          height: 20,
                          width: 20, // spinner size
                          child: CircularProgressIndicator(
                            // saving spinner
                            strokeWidth: 2, // thin
                          ),
                        )
                      : Text(AppLocalizations.of(context)!.save), // "Save"
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// === small scroll behavior to remove overscroll glow (polish) ===
class _NoGlow extends ScrollBehavior {
  const _NoGlow(); // ctor
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child; // no glow
  }
}
