// === Header: avatar + name + status text (safe network image) ===
import 'package:flutter/material.dart';
import 'package:hobby_sphere/features/activities/common/domain/entities/user_entity.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

class UserProfileHeader extends StatelessWidget {
  final UserEntity user; // profile data
  const UserProfileHeader({super.key, required this.user});

  // Base host without /api (e.g. http://192.168.1.8:8080)
  String _serverRootNoApi() {
    final base = (g.appServerRoot ?? '').trim();
    if (base.isEmpty) return '';
    return base
        .replaceFirst(RegExp(r'/api/?$'), '')
        .replaceFirst(RegExp(r'/+$'), '');
  }

  // If path is absolute, return it; else join host + / + path
  String? _buildImageUrl(String? pathOrUrl) {
    if (pathOrUrl == null || pathOrUrl.isEmpty) return null;
    // Already absolute?
    if (RegExp(r'^https?://', caseSensitive: false).hasMatch(pathOrUrl)) {
      return pathOrUrl;
    }
    final host = _serverRootNoApi();
    if (host.isEmpty) return null;
    final p = pathOrUrl.replaceFirst(RegExp(r'^/+'), ''); // strip leading /
    return '$host/$p';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = 96.0;

    // Prefer profileImageUrl; if your backend sometimes returns other fields,
    // update here (e.g., user.avatarPath, user.photoUrl, …).
    final url = _buildImageUrl(user.profileImageUrl);

    return Column(
      children: [
        // Avatar
        Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: theme.colorScheme.surface,
            border: Border.all(
              color: theme.colorScheme.outlineVariant,
              width: 1,
            ),
          ),
          child: ClipOval(
            child: (url == null)
                ? Icon(
                    Icons.person,
                    size: size * .46,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : Image.network(
                    url,
                    fit: BoxFit.cover,
                    // ⚠️ Key fix: don’t throw when the file is missing; show fallback.
                    errorBuilder: (_, __, ___) => Icon(
                      Icons.person,
                      size: size * .46,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        // Full name
        Text(
          user.fullName,
          style: theme.textTheme.titleLarge?.copyWith(
            color: theme.colorScheme.primary,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        // Privacy + status
        Text(
          '${(user.isPublicProfile ?? true) ? "Public" : "Private"} • ${user.status ?? "ACTIVE"}',
          style: theme.textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
