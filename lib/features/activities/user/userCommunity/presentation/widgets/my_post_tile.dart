// lib/.../my_posts/my_post_tile.dart
// Uses Theme colors & typography; text labels (e.g. “Friends/Public”)
// can also be localized if you prefer.

import 'package:flutter/material.dart';
import 'package:hobby_sphere/features/activities/user/userCommunity/domain/entities/post.dart';
import 'package:intl/intl.dart';

class MyPostTile extends StatelessWidget {
  final Post post; // post
  final String? imageBaseUrl; // base url
  final VoidCallback onDelete; // delete
  final bool deleting; // busy flag

  const MyPostTile({
    super.key,
    required this.post,
    required this.onDelete,
    this.imageBaseUrl,
    this.deleting = false,
  });

  String? _abs(String? url) {
    if (url == null || url.isEmpty) return null;
    if (url.startsWith('http')) return url;
    final base = (imageBaseUrl ?? '').replaceFirst(RegExp(r'/$'), '');
    return '$base$url';
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m';
    if (d.inDays < 1) return '${d.inHours}h';
    return DateFormat('yMMMd').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // ← theme colors
    final text = Theme.of(context).textTheme; // ← theme text styles
    final isFriends = post.visibility.toUpperCase().contains('FRIEND');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: cs.surfaceVariant,
                  backgroundImage: _abs(post.profilePictureUrl) != null
                      ? NetworkImage(_abs(post.profilePictureUrl)!)
                      : null,
                  child: _abs(post.profilePictureUrl) == null
                      ? Icon(Icons.person, color: cs.onSurfaceVariant)
                      : null,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${post.firstName} ${post.lastName}',
                        style: text.titleMedium?.copyWith(
                          color: Colors.green[800],
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            isFriends ? Icons.people_alt : Icons.public,
                            size: 13,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            isFriends
                                ? 'Friends'
                                : 'Public', // ← you can l10n if needed
                            style: text.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                          Text(
                            ' · ${_ago(post.postDatetime)}',
                            style: text.bodySmall?.copyWith(
                              color: cs.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                deleting
                    ? const SizedBox(
                        height: 24,
                        width: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : IconButton(
                        icon: const Icon(Icons.delete_outline_rounded),
                        onPressed: onDelete,
                        tooltip: 'Delete', // ← optional l10n
                      ),
              ],
            ),
            const SizedBox(height: 8),
            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: text.bodyMedium?.copyWith(color: cs.onSurface),
              ),
            if (post.imageUrl.isNotEmpty) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  _abs(post.imageUrl)!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
            ],
            if (post.hashtags.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                post.hashtags,
                style: text.bodySmall?.copyWith(color: cs.primary),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
