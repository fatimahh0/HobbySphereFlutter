import 'package:flutter/material.dart';

import 'package:hobby_sphere/shared/utils/image_resolver.dart';
import '../../domain/entities/user_min.dart';

class UserTile extends StatelessWidget {
  final UserMin user;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const UserTile({
    super.key,
    required this.user,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    final imgUrl = resolveUrl(user.profileImageUrl);
    final hasUrl = (imgUrl ?? '').isNotEmpty;
    final initials = _initials(user.firstName, user.lastName, fallback: '?');

    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      leading: CircleAvatar(
        radius: 24,
        backgroundColor: cs.surfaceVariant,
        child: hasUrl
            ? ClipOval(
                child: Image.network(
                  imgUrl!,
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                  // fallbacks so it never stays blank
                  errorBuilder: (_, __, ___) => _Initials(initials: initials),
                  loadingBuilder: (ctx, child, progress) =>
                      progress == null ? child : _Initials(initials: initials),
                ),
              )
            : _Initials(initials: initials),
      ),
      title: Text(
        user.fullName,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tt.titleMedium,
      ),
      subtitle: Text(
        subtitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: trailing,
    );
  }

  Widget _Initials({required String initials}) => Center(
    child: Text(initials, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  String _initials(String? f, String? l, {String fallback = '?'}) {
    final first = (f ?? '').trim();
    final last = (l ?? '').trim();
    if (first.isEmpty && last.isEmpty) return fallback;
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    return (first.isNotEmpty ? first[0] : last[0]).toUpperCase();
  }
}
