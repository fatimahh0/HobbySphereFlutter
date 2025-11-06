// Flutter 3.35.x
// BusinessProfileScreen — simple, shows Stripe button, uses BLoC.
// Uses LegacyNav for all route navigation.

import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:shared_preferences/shared_preferences.dart'; // local storage

import 'package:hobby_sphere/app/router/router.dart'; // routes
import 'package:hobby_sphere/app/router/legacy_nav.dart'; // ✅ Legacy bridge
import 'package:hobby_sphere/core/network/globals.dart' as g; // server root
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

// Invite manager route args
import 'package:hobby_sphere/features/activities/business/businessUserInvite/presentation/screens/invite_manager_screen.dart'; // invite args

// Profile BLoC
import 'package:hobby_sphere/features/activities/business/businessProfile/presentation/bloc/business_profile_bloc.dart'; // bloc
import 'package:hobby_sphere/features/activities/business/businessProfile/presentation/bloc/business_profile_event.dart'; // events
import 'package:hobby_sphere/features/activities/business/businessProfile/presentation/bloc/business_profile_state.dart'; // states

// OLD stack for deactivate dialog
import 'package:hobby_sphere/features/activities/business/businessProfile/data/services/business_service.dart'; // service
import 'package:hobby_sphere/features/activities/business/businessProfile/data/repositories/business_repository_impl.dart'; // repo impl
import 'package:hobby_sphere/features/activities/business/businessProfile/presentation/cubit/deactivate_account_cubit.dart'; // cubit
import 'package:hobby_sphere/features/activities/business/businessProfile/presentation/widgets/deactivate_account_dialog.dart'; // dialog
import 'package:hobby_sphere/features/activities/business/businessProfile/domain/usecases/update_business_status.dart'; // usecase

class BusinessProfileScreen extends StatelessWidget {
  final String token; // auth token
  final int businessId; // business id
  final void Function(int)? onTabChange; // optional callback
  final void Function(Locale)? onChangeLocale; // optional callback

  const BusinessProfileScreen({
    super.key,
    required this.token,
    required this.businessId,
    this.onTabChange,
    this.onChangeLocale,
  });

  // Helper: get server root without /api
  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return BlocBuilder<BusinessProfileBloc, BusinessProfileState>(
      builder: (context, state) {
        if (state is BusinessProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (state is BusinessProfileError) {
          return Scaffold(body: Center(child: Text(state.message)));
        }
        if (state is BusinessProfileLoaded) {
          return _buildProfile(context, state, tr);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildProfile(
    BuildContext context,
    BusinessProfileLoaded state,
    AppLocalizations tr,
  ) {
    final business = state.business;
    final stripeConnected = state.stripeConnected;
    final theme = Theme.of(context);
    final serverRoot = _serverRoot();

    const double avatarSize = 96;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          children: [
            // Logo circle
            Center(
              child: Container(
                width: avatarSize,
                height: avatarSize,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: theme.colorScheme.surface,
                  border: Border.all(
                    color: theme.colorScheme.outlineVariant,
                    width: 1,
                  ),
                ),
                child: ClipOval(
                  child:
                      (business.logoUrl != null && business.logoUrl!.isNotEmpty)
                      ? Image.network(
                          '$serverRoot${business.logoUrl}',
                          fit: BoxFit.contain,
                          errorBuilder: (_, __, ___) =>
                              const Icon(Icons.store, size: 44),
                        )
                      : const Icon(Icons.store, size: 44),
                ),
              ),
            ),

            const SizedBox(height: 12),
            // Business name
            Text(
              business.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),
            // Visibility + status
            Text(
              "${business.isPublicProfile ? tr.publicProfile : tr.privateProfile} | ${business.status}",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 6),
            // Motivation line
            Text(
              tr.businessGrowMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 14),
            // Stripe section
            if (stripeConnected == true)
              Center(
                child: Text(
                  tr.stripeAccountConnected,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              )
            else
              Center(
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.account_balance_wallet),
                  label: Text(tr.registerOnStripe),
                  onPressed: () {
                    context.read<BusinessProfileBloc>().add(
                      ConnectStripePressed(
                        token: token,
                        businessId: businessId,
                      ),
                    );
                  },
                ),
              ),

            const SizedBox(height: 18),

            // ===== Menu tiles =====
            _menuTile(
              context,
              icon: Icons.edit,
              title: tr.editBusinessInfo,
              onTap: () async {
                final updated = await LegacyNav.pushNamed<bool>(
                  context,
                  Routes.editBusiness,
                  arguments: EditBusinessRouteArgs(
                    token: token,
                    businessId: businessId,
                  ),
                );
                if (updated == true && context.mounted) {
                  context.read<BusinessProfileBloc>().add(
                    LoadBusinessProfile(token, businessId),
                  );
                }
              },
            ),

            _menuTile(
              context,
              icon: Icons.notifications,
              title: tr.notifications,
              onTap: () {
                LegacyNav.pushNamed(
                  context,
                  Routes.businessNotifications,
                  arguments: BusinessNotificationsRouteArgs(
                    token: token,
                    businessId: businessId,
                  ),
                );
              },
            ),

            _menuTile(
              context,
              icon: Icons.person_add,
              title: tr.inviteManager,
              onTap: () => LegacyNav.pushNamed(
                context,
                Routes.inviteManager,
                arguments: InviteManagerRouteArgs(
                  token: token,
                  businessId: businessId,
                ),
              ),
            ),

            _menuTile(
              context,
              icon: Icons.privacy_tip,
              title: tr.privacyPolicy,
              onTap: () => LegacyNav.pushNamed(context, Routes.privacyPolicy),
            ),

            _menuTile(
              context,
              icon: Icons.language,
              title: tr.language,
              onTap: () => _showLanguageSelector(context, tr),
            ),

            _menuTile(
              context,
              icon: Icons.logout,
              title: tr.logout,
              onTap: () => _confirmLogout(context, tr),
            ),

            const SizedBox(height: 8),

            // Manage account
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: Text(tr.manageAccount),
              children: [
                _menuTile(
                  context,
                  icon: Icons.visibility,
                  title: business.isPublicProfile
                      ? tr.profileMakePrivate
                      : tr.profileMakePublic,
                  onTap: () {
                    context.read<BusinessProfileBloc>().add(
                      ToggleVisibility(
                        token,
                        businessId,
                        !business.isPublicProfile,
                      ),
                    );
                  },
                ),
                _menuTile(
                  context,
                  icon: Icons.power_settings_new,
                  title: tr.setInactive,
                  onTap: () async {
                    final ok = await showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (ctx) {
                        final repo = BusinessRepositoryImpl(BusinessService());
                        final usecase = UpdateBusinessStatus(repo);
                        return BlocProvider(
                          create: (_) => DeactivateAccountCubit(usecase),
                          child: DeactivateAccountDialog(
                            token: token,
                            businessId: businessId,
                          ),
                        );
                      },
                    );
                    if (ok == true && context.mounted) {
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.clear();
                      LegacyNav.pushNamedAndRemoveUntil(
                        context,
                        Routes.login,
                        (_) => false,
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

  // Simple tile helper
  Widget _menuTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: const Icon(Icons.chevron_right),
          onTap: onTap,
        ),
        const Divider(height: 1),
      ],
    );
  }

  // Language selector bottom sheet
  void _showLanguageSelector(BuildContext context, AppLocalizations tr) {
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                title: const Text("English"),
                onTap: () {
                  Navigator.pop(ctx);
                  onChangeLocale?.call(const Locale('en'));
                },
              ),
              ListTile(
                title: const Text("Français"),
                onTap: () {
                  Navigator.pop(ctx);
                  onChangeLocale?.call(const Locale('fr'));
                },
              ),
              ListTile(
                title: const Text("العربية"),
                onTap: () {
                  Navigator.pop(ctx);
                  onChangeLocale?.call(const Locale('ar'));
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
  final theme = Theme.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(tr.logout),
      content: Text(tr.profileLogoutConfirm),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(
            tr.cancel,
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(tr.confirm),
        ),
      ],
    ),
  );

  if (confirmed == true) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      // Clear stack and go to login via Legacy bridge
      LegacyNav.pushNamedAndRemoveUntil(context, Routes.login, (_) => false);
    }
  }
}
