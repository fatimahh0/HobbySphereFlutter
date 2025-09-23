import 'package:flutter/material.dart';
import '../../domain/entities/post.dart';
import 'package:intl/intl.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final VoidCallback onToggleLike;
  final VoidCallback onComment;
  final String? imageBaseUrl;

  const PostCard({
    super.key,
    required this.post,
    required this.onToggleLike,
    required this.onComment,
    this.imageBaseUrl,
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
    final cs = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final visFriends = post.visibility.toUpperCase().contains('FRIEND');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // header
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
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
                            visFriends
                                ? Icons.people_alt_rounded
                                : Icons.public_rounded,
                            size: 13,
                            color: cs.onSurfaceVariant,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            visFriends ? 'Friends' : 'Public',
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
            const SizedBox(height: 8),
            const Divider(height: 1),
            Row(
              children: [
                IconButton(
                  icon: Icon(
                    Icons.favorite,
                    color: post.isLiked ? Colors.red : cs.onSurfaceVariant,
                  ),
                  onPressed: onToggleLike,
                  tooltip: 'Like',
                ),
                Text(
                  '${post.likeCount}',
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
                const SizedBox(width: 16),
                IconButton(
                  icon: Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: cs.primary,
                  ),
                  onPressed: onComment,
                  tooltip: 'Comment',
                ),
                Text(
                  '${post.commentCount}',
                  style: text.bodySmall?.copyWith(color: cs.onSurfaceVariant),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
