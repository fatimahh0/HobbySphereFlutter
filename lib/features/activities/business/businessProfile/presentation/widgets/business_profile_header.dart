import 'package:flutter/material.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/entities/business.dart';

class ProfileHeader extends StatelessWidget {
  final Business business;
  final String serverRoot;

  const ProfileHeader({
    super.key,
    required this.business,
    required this.serverRoot,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        CircleAvatar(
          radius: 48,
          backgroundImage: business.logoUrl != null
              ? NetworkImage('$serverRoot${business.logoUrl}')
              : null,
          child: business.logoUrl == null
              ? const Icon(Icons.store, size: 48)
              : null,
        ),
        const SizedBox(height: 8),
        Text(
          business.name,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        Text(
          '${business.isPublicProfile ? "Public" : "Private"} Profile | ${business.status}',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 6),
        Text(
          business.stripeConnected
              ? "Stripe account connected"
              : "Stripe account not connected",
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }
}
