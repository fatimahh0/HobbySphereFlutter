// lib/navigation/products/product_shell_bottom.dart
import 'package:flutter/material.dart';
import 'package:hobby_sphere/core/constants/app_role.dart';
import 'package:hobby_sphere/features/products/homeScreen/presentation/screens/product_home_screen.dart';

class ProductShellBottom extends StatefulWidget {
  final AppRole role; // current role
  final String token; // jwt ('' => guest)
  final int businessId; // reserved

  final void Function(Locale) onChangeLocale;
  final VoidCallback onToggleTheme;

  const ProductShellBottom({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    required this.onChangeLocale,
    required this.onToggleTheme,
  });

  @override
  State<ProductShellBottom> createState() => _ProductShellBottomState();
}

class _ProductShellBottomState extends State<ProductShellBottom> {
  int _index = 0;

  late final List<Widget> _pages = <Widget>[
    const ProductHomeScreen(),
    const _Placeholder(title: 'Explore'),
    const _Placeholder(title: 'Cart'),
    const _Placeholder(title: 'Profile'),
  ];

  final List<String> _labels = const ['Home', 'Explore', 'Cart', 'Profile'];

  final List<IconData> _icons = const [
    Icons.home_outlined,
    Icons.search_outlined,
    Icons.shopping_cart_outlined,
    Icons.person_outline,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        top: true,
        bottom: false,
        child: IndexedStack(index: _index, children: _pages),
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: NavigationBar(
          height: 64,
          selectedIndex: _index,
          onDestinationSelected: (i) => setState(() => _index = i),
          destinations: List.generate(_labels.length, (i) {
            return NavigationDestination(
              icon: Icon(_icons[i]),
              label: _labels[i],
            );
          }),
        ),
      ),
    );
  }
}

class _Placeholder extends StatelessWidget {
  final String title;
  const _Placeholder({required this.title});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        '$title (coming soon)',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
