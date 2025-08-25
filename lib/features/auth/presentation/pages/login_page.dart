import 'package:flutter/material.dart';
import 'package:hobby_sphere/theme/app_theme.dart'; // AppColors / Typography

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign In'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/feed',
              ), // mock login
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
              ),
              child: const Text('Continue (mock login)'),
            ),
          ],
        ),
      ),
    );
  }
}
