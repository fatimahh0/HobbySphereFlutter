// === Header: avatar + name + status text ===
import 'package:flutter/material.dart'; // UI
import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart'; // entity
import 'package:hobby_sphere/core/network/globals.dart' as g; // server root

class UserProfileHeader extends StatelessWidget {
  final UserEntity user; // profile data
  const UserProfileHeader({super.key, required this.user}); // ctor

  String _serverRoot() {
    final base = (g.appServerRoot ?? ''); // base url
    return base.replaceFirst(RegExp(r'/api/?$'), ''); // strip /api
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    final img = user.profileImageUrl; // path
    final size = 96.0; // avatar size

    return Column(
      children: [
        // avatar circle
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface, // bg
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: ClipOval(
            child:
                (img != null && img.isNotEmpty) // has image?
                ? Image.network(
                    '${_serverRoot()}$img', // full url
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        const Icon(Icons.person, size: 44),
                  )
                : const Icon(Icons.person, size: 44), // fallback icon
          ),
        ),
        const SizedBox(height: 12), // spacing
        // full name
        Text(
          user.fullName, // name
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4), // spacing
        // privacy + status
        Text(
          '${(user.isPublicProfile ?? true) ? "Public" : "Private"} • ${user.status ?? "ACTIVE"}',
          style: theme.textTheme.bodyMedium, // subtle
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
