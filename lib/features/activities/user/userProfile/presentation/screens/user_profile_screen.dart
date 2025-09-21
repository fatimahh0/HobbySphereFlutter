// === Screen: User profile (header + menu) ===
import 'package:dio/dio.dart';
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/user/tickets/data/models/booking_model.dart';
import 'package:hobby_sphere/features/activities/user/tickets/data/services/tickets_service.dart';
import 'package:shared_preferences/shared_preferences.dart'; // logout
import 'package:hobby_sphere/app/router/router.dart'; // routes
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n

import '../bloc/user_profile_bloc.dart'; // bloc
import '../bloc/user_profile_state.dart'; // state
import '../bloc/user_profile_event.dart'; // event
import '../widgets/user_profile_header.dart'; // header
import '../widgets/deactivate_user_dialog.dart'; // dialog
import '../../domain/usecases/update_user_status.dart'; // usecase for dialog

class UserProfileScreen extends StatelessWidget {
  final String token; // bearer token
  final int userId; // id
  final void Function(Locale) onChangeLocale; // change lang

  const UserProfileScreen({
    super.key,
    required this.token,
    required this.userId,
    required this.onChangeLocale,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // translator

    return BlocBuilder<UserProfileBloc, UserProfileState>(
      // listen bloc
      builder: (context, state) {
        if (state is UserProfileLoading) {
          // spinner
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is UserProfileError) {
          // error
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is UserProfileLoaded) {
          // data
          return _buildLoaded(context, tr, state); // build UI
        }
        return const SizedBox.shrink(); // fallback
      },
    );
  }

  Widget _buildLoaded(
    BuildContext context,
    AppLocalizations tr,
    UserProfileLoaded state,
  ) {
    final user = state.user; // entity
    final theme = Theme.of(context); // theme

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // bg
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // pad
          children: [
            UserProfileHeader(user: user), // avatar+name+status
            const SizedBox(height: 16), // spacing
            Center(
              child: Text(
                tr.profileMotto, // e.g., "Live your hobby!"
                style: theme.textTheme.bodySmall?.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 16), // spacing
            // ===== Menu tiles =====
            // AFTER — navigates to Calendar screen using the SAME tickets service
            // == CALENDAR TILE: open Calendar using the same tickets data ==
            _tile(
              context,
              icon: Icons.calendar_today, // calendar icon
              title: tr.profileCalendar, // l10n: "My Calendar"
              onTap: () {
                // 1) prepare a safe Dio instance (use global if set, else new)
                final dio = g.appDio ?? Dio(); // shared HTTP client

                // 2) create the tickets service (thin wrapper around Dio)
                final svc = TicketsService(dio); // service instance

                // 3) push the calendar route and pass a loader callback
                Navigator.of(context).pushNamed(
                  Routes.userTicketsCalendar, // route we added in router.dart
                  arguments: CalendarTicketsRouteArgs(
                    // loader returns ALL tickets as BookingEntity list
                    loadTickets: () async {
                      // a) call your 3 endpoints (pending/completed/canceled)
                      final p = await svc.getByStatus(
                        token,
                        'pending',
                      ); // Pending + CancelRequested
                      final c = await svc.getByStatus(
                        token,
                        'completed',
                      ); // Completed
                      final x = await svc.getByStatus(
                        token,
                        'canceled',
                      ); // Canceled

                      // b) merge raw lists
                      final all = <dynamic>[]
                        ..addAll(p)
                        ..addAll(c)
                        ..addAll(x);

                      // c) map raw json → BookingModel (which extends BookingEntity)
                      //    (adjust constructor if your model differs)
                      return all
                          .map(
                            (j) => BookingModel.fromJson(
                              j as Map<String, dynamic>,
                            ),
                          )
                          .toList();
                    },
                  ),
                );
              },
            ),

            _tile(
              context,
              icon: Icons.edit, // edit
              title: tr.profileEditProfile, // "Edit Profile"
              onTap: () => Navigator.of(context).pushNamed(
                Routes.editUserProfile,
                arguments: EditUserProfileRouteArgs(
                  token: token,
                  userId: userId,
                ),
              ),
            ),

            // === EDIT INTERESTS ===
            _tile(
              context,
              icon: Icons.favorite_border, // heart icon
              title: tr.profileMyInterests, // l10n: "My Interests"
              onTap: () {
                // navigate to the Edit Interests screen
                Navigator.of(context).pushNamed(
                  Routes.editInterests, // route name we added
                  arguments: EditInterestsRouteArgs(
                    // pass args to screen
                    token: token, // bearer/raw token
                    userId: userId, // current user id
                  ),
                );
              },
            ),

            _tile(
              context,
              icon: Icons.notifications_outlined, // notifications
              title: tr.notifications, // "Notifications"
              onTap: () => Navigator.of(context).pushNamed(Routes.userHome),
            ),
            _tile(
              context,
              icon: Icons.privacy_tip_outlined, // privacy
              title: tr.privacyPolicy, // "Privacy Policy"
              onTap: () =>
                  Navigator.of(context).pushNamed(Routes.privacyPolicy),
            ),
            _tile(
              context,
              icon: Icons.language, // language
              title: tr.language, // "Language"
              onTap: () => _showLanguageSelector(context), // bottom sheet
            ),
            _tile(
              context,
              icon: Icons.logout, // logout
              title: tr.logout, // "Logout"
              onTap: () => _confirmLogout(context, tr), // dialog
            ),

            const SizedBox(height: 8), // spacing
            // Manage account (visibility / deactivate)
            ExpansionTile(
              leading: const Icon(Icons.settings), // gear
              title: Text(tr.manageAccount), // "Manage Account"
              children: [
                _tile(
                  context,
                  icon: Icons.visibility, // visibility
                  title: (user.isPublicProfile ?? true)
                      ? tr
                            .profileMakePrivate // "Make Private"
                      : tr.profileMakePublic, // "Make Public"
                  onTap: () => context.read<UserProfileBloc>().add(
                    ToggleVisibilityPressed(
                      token,
                      !(user.isPublicProfile ?? true), // flip value
                    ),
                  ),
                ),
                _tile(
                  context,
                  icon: Icons.power_settings_new, // deactivate
                  title: tr.setInactive, // "Set Inactive"
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      // open dialog
                      context: context,
                      barrierDismissible: false, // force choice
                      builder: (ctx) => RepositoryProvider.value(
                        value: context
                            .read<UpdateUserStatus>(), // pass UC to dialog
                        child: DeactivateUserDialog(
                          token: token, // pass token
                          userId: userId, // pass id
                        ),
                      ),
                    );
                    if (ok == true && context.mounted) {
                      // if deactivated
                      final prefs =
                          await SharedPreferences.getInstance(); // clear prefs
                      await prefs.clear();
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.login, // go to login
                        (_) => false, // wipe stack
                      );
                    }
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // small helper: uniform tile with divider
  Widget _tile(
    BuildContext context, {
    required IconData icon, // icon
    required String title, // label
    required VoidCallback onTap, // action
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon), // show icon
          title: Text(title), // show text
          trailing: const Icon(Icons.chevron_right), // arrow
          onTap: onTap, // handle tap
        ),
        const Divider(height: 1), // separator
      ],
    );
  }

  // show language bottom sheet (en/fr/ar)
  void _showLanguageSelector(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'), // en
              onTap: () {
                Navigator.pop(ctx);
                onChangeLocale(const Locale('en'));
              },
            ),
            ListTile(
              title: const Text('Français'), // fr
              onTap: () {
                Navigator.pop(ctx);
                onChangeLocale(const Locale('fr'));
              },
            ),
            ListTile(
              title: const Text('العربية'), // ar
              onTap: () {
                Navigator.pop(ctx);
                onChangeLocale(const Locale('ar'));
              },
            ),
          ],
        ),
      ),
    );
  }
}

// logout helper (clear prefs + go to login)
Future<void> _confirmLogout(BuildContext context, AppLocalizations tr) async {
  final theme = Theme.of(context); // theme
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr.logout), // "Logout"
      content: Text(tr.profileLogoutConfirm), // confirm text
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false), // cancel
          child: Text(
            tr.cancel,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true), // ok
          child: Text(tr.confirm),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    // if ok
    final prefs = await SharedPreferences.getInstance(); // prefs
    await prefs.clear(); // clear
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        // go login
        Routes.login,
        (_) => false,
      );
    }
  }
}
