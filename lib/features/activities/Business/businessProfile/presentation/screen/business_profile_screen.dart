// Flutter 3.35.x
// BusinessProfileScreen — simple, shows Stripe button, uses BLoC.

import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:shared_preferences/shared_preferences.dart'; // local storage

import 'package:hobby_sphere/app/router/router.dart'; // routes
import 'package:hobby_sphere/core/network/globals.dart' as g; // server root
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

// Invite manager route args
import 'package:hobby_sphere/features/activities/Business/BusinessUserInvite/presentation/screens/invite_manager_screen.dart'; // invite args

// Profile BLoC
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_bloc.dart'; // bloc
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_event.dart'; // events
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_state.dart'; // states

// OLD stack for deactivate dialog
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart'; // service
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart'; // repo impl
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/cubit/deactivate_account_cubit.dart'; // cubit
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/widgets/deactivate_account_dialog.dart'; // dialog
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart'; // usecase

class BusinessProfileScreen extends StatelessWidget {
  final String token; // auth token
  final int businessId; // business id
  final void Function(int)? onTabChange; // optional callback
  final void Function(Locale)? onChangeLocale; // optional callback

  const BusinessProfileScreen({
    super.key, // key
    required this.token, // set token
    required this.businessId, // set id
    this.onTabChange, // optional
    this.onChangeLocale, // optional
  });

  // Helper: get server root without /api
  String _serverRoot() {
    final base = (g.appServerRoot ?? ''); // take global root
    return base.replaceFirst(RegExp(r'/api/?$'), ''); // strip /api
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!; // i18n

    return BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
      builder: (context, state) {
        // show spinner while loading
        if (state is BusinessProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()), // spinner
          );
        }
        // show error
        if (state is BusinessProfileError) {
          return Scaffold(
            body: Center(child: Text(state.message)),
          ); // error text
        }
        // show content
        if (state is BusinessProfileLoaded) {
          return _buildProfile(context, state, tr); // content
        }
        // empty if initial
        return const SizedBox.shrink(); // nothing
      },
    );
  }

  // Content builder
  Widget _buildProfile(
    BuildContext context, // context
    BusinessProfileLoaded state, // loaded state
    AppLocalizations tr, // i18n
  ) {
    final business = state.business; // business entity
    final stripeConnected = state.stripeConnected; // stripe flag
    final theme = Theme.of(context); // theme
    final serverRoot = _serverRoot(); // server root for images

    const double avatarSize = 96; // avatar size

    return Scaffold(
      backgroundColor: theme.colorScheme.background, // bg color
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ), // page padding
          children: [
            // Logo circle
            Center(
              child: Container(
                width: avatarSize, // width
                height: avatarSize, // height
                decoration: BoxDecoration(
                  shape: BoxShape.circle, // circle
                  color: theme.colorScheme.surface, // surface color
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant, // thin border
                    width: 1, // 1px
                  ),
                ),
                child: ClipOval(
                  child:
                      (business.logoUrl != null &&
                          business.logoUrl!.isNotEmpty) // has logo?
                      ? Image.network(
                          '$serverRoot${business.logoUrl}', // full image url
                          fit: BoxFit.contain, // contain
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.store,
                            size: 44,
                          ), // fallback icon
                        )
                      : const Icon(Icons.store, size: 44), // default icon
                ),
              ),
            ),

            const SizedBox(height: 12), // space
            // Business name
            Text(
              business.name, // name
              textAlign: TextAlign.center, // center text
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary, // primary color
                fontWeight: FontWeight.bold, // bold
              ),
            ),

            const SizedBox(height: 6), // space
            // Visibility + status
            Text(
              "${business.isPublicProfile ? tr.publicProfile : tr.privateProfile} | ${business.status}", // info
              textAlign: TextAlign.center, // center
              style: theme.textTheme.bodyMedium, // style
            ),

            const SizedBox(height: 6), // space
            // Motivation line
            Text(
              tr.businessGrowMessage, // localized text
              textAlign: TextAlign.center, // center
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic, // italic
              ),
            ),

            const SizedBox(height: 14), // space
            // Stripe section
            if (stripeConnected == true) // if connected
              Center(
                child: Text(
                  tr.stripeAccountConnected, // "Stripe connected"
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green, // green text
                    fontWeight: FontWeight.w600, // semi-bold
                  ),
                ),
              )
            else
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.account_balance_wallet), // wallet icon
                  label: Text(tr.registerOnStripe), // "Register on Stripe"
                  onPressed: () {
                    // Dispatch event to open Stripe onboarding
                    context.read<BusinessProfileBloc>().add(
                      ConnectStripePressed(
                        // custom event
                        token: token, // pass token
                        businessId: businessId, // pass id
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 18), // space
            // ===== Menu tiles =====
            _menuTile(
              context,
              icon: Icons.edit, // edit icon
              title: tr.editBusinessInfo, // edit text
              onTap: () async {
                // Open edit screen
                final updated = await Navigator.pushNamed(
                  context,
                  Routes.editBusiness, // route
                  arguments: EditBusinessRouteArgs(
                    token: token, // pass token
                    businessId: businessId, // pass id
                  ),
                );
                // If updated, reload profile
                if (updated == true && context.mounted) {
                  context.read<BusinessProfileBloc>().add(
                    LoadBusinessProfile(token, businessId), // reload
                  );
                }
              },
            ),

            _menuTile(
              context,
              icon: Icons.notifications, // bell
              title: tr.notifications, // title
              onTap: () {
                // Open notifications
                Navigator.pushNamed(
                  context,
                  Routes.businessNotifications, // route
                  arguments: BusinessNotificationsRouteArgs(
                    token: token, // token
                    businessId: businessId, // id
                  ),
                );
              },
            ),

            _menuTile(
              context,
              icon: Icons.person_add, // add person
              title: tr.inviteManager, // title
              onTap: () => Navigator.pushNamed(
                context,
                Routes.inviteManager, // route
                arguments: InviteManagerRouteArgs(
                  token: token, // token
                  businessId: businessId, // id
                ),
              ),
            ),

            _menuTile(
              context,
              icon: Icons.privacy_tip, // privacy icon
              title: tr.privacyPolicy, // title
              onTap: () => Navigator.of(
                context,
              ).pushNamed(Routes.privacyPolicy), // open policy
            ),

            _menuTile(
              context,
              icon: Icons.language, // language icon
              title: tr.language, // title
              onTap: () => _showLanguageSelector(context, tr), // open selector
            ),

            _menuTile(
              context,
              icon: Icons.logout, // logout icon
              title: tr.logout, // title
              onTap: () => _confirmLogout(context, tr), // confirm logout
            ),

            const SizedBox(height: 8), // space
            // Manage account (expand)
            ExpansionTile(
              leading: const Icon(Icons.settings), // settings icon
              title: Text(tr.manageAccount), // title
              children: [
                _menuTile(
                  context,
                  icon: Icons.visibility, // eye icon
                  title: business.isPublicProfile
                      ? tr.profileMakePrivate
                      : tr.profileMakePublic, // toggle text
                  onTap: () {
                    // Dispatch toggle visibility
                    context.read<BusinessProfileBloc>().add(
                      ToggleVisibility(
                        token, // token
                        businessId, // id
                        !business.isPublicProfile, // switch value
                      ),
                    );
                  },
                ),
                _menuTile(
                  context,
                  icon: Icons.power_settings_new, // power icon
                  title: tr.setInactive, // title
                  onTap: () async {
                    // Show deactivate dialog (old stack)
                    final ok = await showDialog<bool>(
                      context: context, // context
                      barrierDismissible: false, // force choice
                      builder: (ctx) {
                        // Create repo + usecase for dialog
                        final repo = BusinessRepositoryImpl(
                          BusinessService(),
                        ); // repo
                        final usecase = UpdateBusinessStatus(repo); // usecase
                        return BlocProvider(
                          create: (_) =>
                              DeactivateAccountCubit(usecase), // cubit
                          child: DeactivateAccountDialog(
                            token: token, // token
                            businessId: businessId, // id
                          ),
                        );
                      },
                    );
                    // If deactivated, clear and go to login
                    if (ok == true && context.mounted) {
                      final prefs =
                          await SharedPreferences.getInstance(); // prefs
                      await prefs.clear(); // clear
                      Navigator.of(context).pushNamedAndRemoveUntil(
                        Routes.login,
                        (_) => false,
                      ); // go login
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

  // Simple tile helper
  Widget _menuTile(
    BuildContext context, {
    required IconData icon, // left icon
    required String title, // title text
    required VoidCallback onTap, // on press
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon), // icon
          title: Text(title), // text
          trailing: const Icon(Icons.chevron_right), // arrow
          onTap: onTap, // open
        ),
        const Divider(height: 1), // thin divider
      ],
    );
  }

  // Language selector bottom sheet
  void _showLanguageSelector(BuildContext context, AppLocalizations tr) {
    showModalBottomSheet(
      context: context, // context
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // wrap content
            children: [
              ListTile(
                title: const Text("English"), // en
                onTap: () {
                  Navigator.pop(ctx); // close
                  onChangeLocale?.call(const Locale('en')); // set
                },
              ),
              ListTile(
                title: const Text("Français"), // fr
                onTap: () {
                  Navigator.pop(ctx); // close
                  onChangeLocale?.call(const Locale('fr')); // set
                },
              ),
              ListTile(
                title: const Text("العربية"), // ar
                onTap: () {
                  Navigator.pop(ctx); // close
                  onChangeLocale?.call(const Locale('ar')); // set
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// Logout confirm dialog
Future<void> _confirmLogout(BuildContext context, AppLocalizations tr) async {
  final theme = Theme.of(context); // theme
  final confirmed = await showDialog<bool>(
    context: context, // context
    builder: (ctx) {
      return AlertDialog(
        title: Text(tr.logout), // title
        content: Text(tr.profileLogoutConfirm), // message
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false), // cancel
            child: Text(
              tr.cancel, // cancel text
              style: TextStyle(color: theme.colorScheme.error), // red text
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true), // confirm
            child: Text(tr.confirm), // confirm text
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    final prefs = await SharedPreferences.getInstance(); // prefs
    await prefs.clear(); // clear
    if (context.mounted) {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(Routes.login, (_) => false); // go login
    }
  }
}
