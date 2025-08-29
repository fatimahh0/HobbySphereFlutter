// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/core/services/token_store.dart'; // ✅ token storage
import 'package:hobby_sphere/app/router/router.dart'; // for navigation (Login route)

class BusinessProfileScreen extends StatelessWidget {
  const BusinessProfileScreen({super.key});

  // helper: logout method
  Future<void> _logout(BuildContext context) async {
    await TokenStore.clear(); // ✅ remove token from local storage
    if (context.mounted) {
      // after logout navigate to login page (replace to avoid back button issue)
      Navigator.of(context).pushNamedAndRemoveUntil(
        '/login', // make sure this is your login route
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // translations
    final cs = Theme.of(context).colorScheme; // theme colors
    final tt = Theme.of(context).textTheme; // typography

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // ===== Profile Header =====
        Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: cs.primary,
              child: const Icon(Icons.business, color: Colors.white),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Business name', style: tt.titleMedium),
                Text(
                  'business@email.com',
                  style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),

        const SizedBox(height: 32),

        // ===== Logout Button =====
        ElevatedButton.icon(
          onPressed: () => _logout(context), // call logout method
          icon: const Icon(Icons.logout),
          label: Text(t.buttonLogout), // from translations
          style: ElevatedButton.styleFrom(
            backgroundColor: cs.error, // red button
            foregroundColor: Colors.white,
            minimumSize: const Size.fromHeight(48), // full-width
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ],
    );
  }
}
