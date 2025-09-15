import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/app/router/router.dart' show Routes; // routes

class LoginLink extends StatelessWidget {
  const LoginLink({super.key});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return Padding(
      padding: const EdgeInsets.only(top: 12), // spacing
      child: Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center, // align
          children: [
            const Text('Already have an account? '), // static text
            InkWell(
              onTap: () => Navigator.of(context).pushNamed(Routes.login),
              child: Text(
                'Log in', // link text
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
