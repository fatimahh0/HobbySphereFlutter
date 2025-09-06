// ===== Flutter 3.35.x =====
// BusinessProfileScreen — profile + actions, stays inside ShellBottom
// Supports language change (EN / FR / AR)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/entities/business.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_state.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BusinessProfileScreen extends StatelessWidget {
  final String token;
  final int businessId;

  // Callbacks from ShellBottom
  final void Function(int)? onTabChange;
  final void Function(Locale)? onChangeLocale;

  const BusinessProfileScreen({
    super.key,
    required this.token,
    required this.businessId,
    this.onTabChange,
    this.onChangeLocale,
  });

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

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 32),

            // Business Logo
            CircleAvatar(
              radius: 48,
              backgroundImage:
                  (business.logoUrl != null && business.logoUrl!.isNotEmpty)
                  ? NetworkImage('$serverRoot${business.logoUrl}')
                  : null,
              child: (business.logoUrl == null || business.logoUrl!.isEmpty)
                  ? const Icon(Icons.store, size: 48)
                  : null,
            ),

            const SizedBox(height: 16),

            // Business Name
            Text(
              business.name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Profile + Status
            Text(
              "${business.isPublicProfile ? tr.publicProfile : tr.privateProfile} | ${business.status}",
              style: theme.textTheme.bodyMedium,
            ),

            const SizedBox(height: 8),
            Text(
              tr.businessGrowMessage,
              style: theme.textTheme.bodySmall?.copyWith(
                fontStyle: FontStyle.italic,
              ),
            ),

            // Stripe info
            if (stripeConnected != null && stripeConnected) ...[
              Text(
                tr.stripeAccountConnected,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ] else ...[
              ElevatedButton.icon(
                icon: const Icon(Icons.account_balance_wallet),
                label: Text(tr.registerOnStripe),
                onPressed: () {
                  // TODO: implement stripe connect flow
                },
              ),
            ],

            const SizedBox(height: 24),

            // ==========================
            // Menu Actions
            // ==========================
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(tr.editBusinessInfo),
              onTap: () async {
                final updated = await Navigator.pushNamed(
                  context,
                  Routes.editBusiness,
                  arguments: EditBusinessRouteArgs(
                    token: token,
                    businessId: businessId,
                  ),
                );

                if (updated == true) {
                  context.read<BusinessProfileBloc>().add(
                    LoadBusinessProfile(token, businessId),
                  ); //
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: Text(tr.myActivities),
              onTap: () => onTabChange?.call(3), // Switch tab → Activities
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: Text(tr.analytics),
              onTap: () => onTabChange?.call(2), // Switch tab → Analytics
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(tr.notifications),
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
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(tr.inviteManager),
              onTap: () {
                // TODO: implement invite manager screen
              },
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: Text(tr.privacyPolicy),
              onTap: () {
                Navigator.of(context).pushNamed(Routes.privacyPolicy);
              },
            ),

            ListTile(
              leading: const Icon(Icons.language),
              title: Text(tr.language),
              onTap: () {
                _showLanguageSelector(context, tr);
              },
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(tr.logout),
              onTap: () {
                _confirmLogout(context, tr);
              },
            ),

            // Manage Account
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: Text(tr.manageAccount),
              children: [
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: Text(
                    business.isPublicProfile
                        ? tr.profileMakePrivate
                        : tr.profileMakePublic,
                  ),
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
                ListTile(
                  leading: const Icon(Icons.power_settings_new),
                  title: Text(tr.setInactive),
                  onTap: () {
                    context.read<BusinessProfileBloc>().add(
                      ChangeStatus(token, businessId, "INACTIVE"),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ==========================
  // Language Selector Modal
  // ==========================
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

Future<void> _confirmLogout(BuildContext context, AppLocalizations tr) async {
  final theme = Theme.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(tr.logout),
        content: Text(tr.profileLogoutConfirm), // Add this to your arb
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
    Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
  }
}
