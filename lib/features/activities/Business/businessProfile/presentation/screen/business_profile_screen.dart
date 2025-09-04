import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/entities/business.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../bloc/business_profile_bloc.dart';
import '../bloc/business_profile_event.dart';
import '../bloc/business_profile_state.dart';

class BusinessProfileScreen extends StatelessWidget {
  final String token;
  final int businessId;

  const BusinessProfileScreen({
    super.key,
    required this.token,
    required this.businessId,
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
            Text(
              business.name,
              style: theme.textTheme.titleLarge?.copyWith(
                color: theme.colorScheme.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
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

            // Stripe connection info
            // Stripe connection info
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
                  // Dispatch event to Bloc

                  //connect stripe
                },
              ),
            ],

            const SizedBox(height: 24),

            // Actions
            ListTile(
              leading: const Icon(Icons.edit),
              title: Text(tr.editBusinessInfo),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.work),
              title: Text(tr.myActivities),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: Text(tr.analytics),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: Text(tr.notifications),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: Text(tr.inviteManager),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.privacy_tip),
              title: Text(tr.privacyPolicy),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.language),
              title: Text(tr.language),
              onTap: () {},
            ),
            ListTile(
              leading: const Icon(Icons.logout),
              title: Text(tr.logout),
              onTap: () async {
                // Clear local storage
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();

                // Navigate to login (remove all routes)
                Navigator.of(
                  context,
                ).pushNamedAndRemoveUntil(Routes.login, (route) => false);
              },
            ),

            // Manage account section
            ExpansionTile(
              leading: const Icon(Icons.settings),
              title: Text(tr.manageAccount),
              children: [
                ListTile(
                  title: Text(tr.setInactive),
                  onTap: () {
                    context.read<BusinessProfileBloc>().add(
                      ChangeStatus(token, businessId, "INACTIVE"),
                    );
                  },
                ),
                ListTile(
                  title: Text(tr.deleteAccount),
                  onTap: () {
                    context.read<BusinessProfileBloc>().add(
                      DeleteBusinessEvent(token, businessId, "password"),
                    ); // TODO: show modal for password
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
