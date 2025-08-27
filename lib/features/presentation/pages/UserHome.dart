import 'package:flutter/material.dart';

class UserHome extends StatefulWidget {
  const UserHome({Key? key}) : super(key: key);

  @override
  State<UserHome> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<UserHome> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // read current theme
    final cs = theme.colorScheme; // color scheme (light/dark aware)

    return Scaffold(
      // screen scaffold
      backgroundColor: cs.background, // page background
      appBar: AppBar(
        // top app bar
        title: const Text('User Home'), // screen title
        backgroundColor: cs.primary, // brand color
        foregroundColor: cs.onPrimary, // title/icon color
      ),
      body: Center(
        // page body
        child: Column(
          // vertical layout
          mainAxisSize: MainAxisSize.min, // compact height
          children: [
            Icon(
              Icons.storefront, // business icon
              size: 64,
              color: cs.primary,
            ), // size + color
            const SizedBox(height: 12), // spacing
            Text(
              // welcome text
              'Welcome, Business!', // simple label
              style: theme.textTheme.titleMedium?.copyWith(
                color: cs.onBackground, // readable color
                fontWeight: FontWeight.w600, // semi-bold
              ),
            ),
          ],
        ),
      ),
    );
  }
}
