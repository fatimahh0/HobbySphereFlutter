// Flutter 3.35.x — Fix: use `type:` instead of `variant:`
// Simple "Not Logged In" gate with Login / Register actions.

import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // AppButton + types

class NotLoggedInGate extends StatelessWidget {
  final VoidCallback onLogin; // tap: login
  final VoidCallback onRegister; // tap: register

  const NotLoggedInGate({
    super.key, // key
    required this.onLogin, // ctor
    required this.onRegister, // ctor
  });

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // strings
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors

    return Center(
      // center content
      child: Padding(
        // page padding
        padding: const EdgeInsets.symmetric(horizontal: 24.0), // 24px
        child: Column(
          // vertical stack
          mainAxisSize: MainAxisSize.min, // wrap height
          children: [
            Icon(
              // friendly icon
              Icons.lock_outline, // lock icon
              size: 40, // size
              color: cs.primary, // brand color
            ),
            const SizedBox(height: 10), // gap
            Text(
              // title
              t.notLoggedInTitle, // "Not Logged In"
              textAlign: TextAlign.center, // center
              style: theme.textTheme.titleLarge?.copyWith(
                // style
                fontWeight: FontWeight.w800, // bold
              ),
            ),
            const SizedBox(height: 8), // gap
            Text(
              // message
              t.notLoggedInMessage, // hint text
              textAlign: TextAlign.center, // center
              style: theme.textTheme.bodyMedium?.copyWith(
                // style
                color: theme.textTheme.bodyMedium?.color?.withOpacity(
                  0.75,
                ), // softer
              ),
            ),
            const SizedBox(height: 16), // gap
            Row(
              // buttons row
              children: [
                Expanded(
                  // take 1/2 width
                  child: AppButton(
                    // Login button
                    label: t.login, // "Login"
                    onPressed: onLogin, // callback
                    type: AppButtonType.secondary, // soft / secondary
                    size: AppButtonSize.md, // medium
                  ),
                ),
                const SizedBox(width: 12), // space between
                Expanded(
                  // take 1/2 width
                  child: AppButton(
                    // Register button
                    label: t.register, // "Register"
                    onPressed: onRegister, // callback
                    type: AppButtonType.primary, // solid / primary
                    size: AppButtonSize.md, // medium
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
