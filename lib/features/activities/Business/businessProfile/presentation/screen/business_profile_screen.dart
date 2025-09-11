// ===== Flutter 3.35.x =====
// BusinessProfileScreen — clean; deactivation via old Business service stack

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/cubit/deactivate_account_cubit.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/widgets/deactivate_account_dialog.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/l10n/app_localizations.dart';

// Invite route args
import 'package:hobby_sphere/features/activities/Business/BusinessUserInvite/presentation/screens/invite_manager_screen.dart';

// Profile bloc
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_state.dart';

// OLD business service stack
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart';

class BusinessProfileScreen extends StatelessWidget {
  final String token;
  final int businessId;

  final void Function(int)? onTabChange;
  final void Function(Locale)? onChangeLocale;

  const BusinessProfileScreen({
    super.key,
    required this.token,
    required this.businessId,
    this.onTabChange,
    this.onChangeLocale,
  });

  // For images (strip /api)
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
            // Logo
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

            Text(
              business.name,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 6),

            Text(
              "${business.isPublicProfile ? tr.publicProfile : tr.privateProfile} | ${business.status}",
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 6),
            Text(
              tr.businessGrowMessage,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),

            const SizedBox(height: 14),

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
                  onPressed: () {},
                ),
              ),

            const SizedBox(height: 18),

            // ===== Menu =====
            _menuTile(
              context,
              icon: Icons.edit,
              title: tr.editBusinessInfo,
              onTap: () async {
                final updated = await Navigator.pushNamed(
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
                Navigator.pushNamed(
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
              onTap: () => Navigator.pushNamed(
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
              onTap: () =>
                  Navigator.of(context).pushNamed(Routes.privacyPolicy),
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
                        // Wire cubit to OLD business stack
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
                      Navigator.of(
                        context,
                      ).pushNamedAndRemoveUntil(Routes.login, (_) => false);
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

  // ===== helpers =====

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

// ===== logout helper (unchanged) =====
Future<void> _confirmLogout(BuildContext context, AppLocalizations tr) async {
  final theme = Theme.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
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
      );
    },
  );

  if (confirmed == true) {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
    }
  }
}
