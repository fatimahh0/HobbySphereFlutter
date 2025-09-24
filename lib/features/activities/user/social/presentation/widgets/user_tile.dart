// user_tile.dart (Flutter 3.35.x)

import 'package:flutter/material.dart'; // widgets
import 'package:hobby_sphere/core/network/globals.dart'
    as g; // to read base url
import '../../domain/entities/user_min.dart'; // user entity

// Reusable list tile: avatar + name + subtitle + trailing action.
class UserTile extends StatelessWidget {
  final UserMin user; // user object
  final String subtitle; // small text line
  final Widget? trailing; // right side widget
  final VoidCallback? onTap; // row tap

  const UserTile({
    super.key,
    required this.user, // require user
    required this.subtitle, // require subtitle
    this.trailing, // optional trailing
    this.onTap, // optional tap
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // theme colors
    final tt = Theme.of(context).textTheme; // text theme

    // 1) make absolute url (handles relative like "/images/a.png")
    final imgUrl = _resolveImageUrl(user.profileImageUrl); // final image url
    final hasUrl = (imgUrl ?? '').isNotEmpty; // check not empty

    // 2) initials fallback (first letters)
    final initials = _initials(user.firstName, user.lastName, fallback: '?');

    return ListTile(
      onTap: onTap, // row tap
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16, // spacing
        vertical: 6,
      ),
      leading: CircleAvatar(
        radius: 24, // avatar size
        backgroundColor: cs.surfaceVariant, // fallback bg
        child:
            hasUrl // show image or initials
            ? ClipOval(
                child: Image.network(
                  imgUrl!, // safe non-null
                  width: 48,
                  height: 48, // 2 * radius
                  fit: BoxFit.cover, // cover the circle
                  errorBuilder: (_, __, ___) => _Initials(initials: initials),
                  frameBuilder: (ctx, child, frame, _) => AnimatedOpacity(
                    opacity: frame == null ? 0 : 1, // fade-in
                    duration: const Duration(milliseconds: 200),
                    child: child,
                  ),
                ),
              )
            : _Initials(initials: initials), // initials widget
      ),
      title: Text(
        user.fullName, // full name
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // tidy text
        style: tt.titleMedium,
      ),
      subtitle: Text(
        subtitle, // hint text
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // tidy text
        style: tt.bodyMedium?.copyWith(color: cs.onSurfaceVariant),
      ),
      trailing: trailing, // actions
    );
  }

  // Helper: show initials centered
  Widget _Initials({required String initials}) => Center(
    child: Text(
      initials, // letters
      style: const TextStyle(fontWeight: FontWeight.w600),
    ),
  );

  // Build initials from first/last
  String _initials(String? f, String? l, {String fallback = '?'}) {
    final first = (f ?? '').trim();
    final last = (l ?? '').trim();
    if (first.isEmpty && last.isEmpty) return fallback; // no names
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase(); // 2 letters
    }
    return (first.isNotEmpty ? first[0] : last[0]).toUpperCase(); // 1 letter
  }

  // Make absolute image url from relative
  String? _resolveImageUrl(String? raw) {
    if (raw == null || raw.isEmpty) return null; // nothing to do
    if (raw.startsWith('http')) return raw; // already absolute
    final root =
        (g.appServerRoot ?? '') // ex: https://host/api
            .replaceFirst(RegExp(r'/api/?$'), ''); // trim trailing /api
    // Ensure single slash between base and path
    if (raw.startsWith('/')) return '$root$raw'; // base + /path
    return '$root/$raw'; // base + path
  }
}
