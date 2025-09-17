import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

class UserProfileScreen extends StatelessWidget {
  const UserProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Row(
          children: [
            CircleAvatar(radius: 28, backgroundColor: cs.primary),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // TODO: plug real display name
                  Text(t.tabProfile, style: tt.titleMedium),
                  Text(
                    t.manageAccount,
                    style: tt.bodySmall?.copyWith(color: cs.outline),
                  ),
                ],
              ),
            ),
            IconButton(
              tooltip: t.logout,
              icon: const Icon(Icons.logout),
              onPressed: () => _confirmLogout(context, t),
            ),
          ],
        ),
        const SizedBox(height: 16),

        Card(
          elevation: 0,
          color: cs.surfaceContainer,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person),
                title: Text(t.profileEditProfile, style: tt.titleMedium),
                subtitle: Text(t.manageAccount, style: tt.bodySmall),
                trailing: const Icon(Icons.chevron_right),
                onTap: () {
                  // TODO: open details/edit page
                },
              ),
              const Divider(height: 1),

              // 👇 Logout inside the card
              ListTile(
                leading: const Icon(Icons.logout),
                title: Text(t.logout),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _confirmLogout(context, t),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// Same confirm/logout flow you used in BusinessProfileScreen,
/// tweaked to remove common auth keys before navigating.
Future<void> _confirmLogout(BuildContext context, AppLocalizations t) async {
  final theme = Theme.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) {
      return AlertDialog(
        title: Text(t.logout),
        content: Text(t.profileLogoutConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              t.cancel,
              style: TextStyle(color: theme.colorScheme.error),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(t.confirm),
          ),
        ],
      );
    },
  );

  if (confirmed == true) {
    final prefs = await SharedPreferences.getInstance();

    // Remove ONLY what matters (safer than .clear())
    await prefs.remove('token');
    await prefs.remove('role');
    await prefs.remove('businessId');
    await prefs.remove('userId');

    if (context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(Routes.login, (_) => false);
    }
  }
}
