// ===== Flutter 3.35.x =====
// Welcome block: title, subtitle, notifications with unread badge, and "Create Activity".

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;

import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_state.dart';

class WelcomeSection extends StatelessWidget {
  final VoidCallback? onOpenNotifications;
  final VoidCallback? onOpenCreateActivity;
  final String token;

  const WelcomeSection({
    super.key,
    this.onOpenNotifications,
    this.onOpenCreateActivity,
    required this.token,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    final t = AppLocalizations.of(context)!;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Text(
                  t.businessWelcome,
                  style: text.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: scheme.primary,
                  ),
                ),
              ),
              // 👇 Listen to unreadCount from Bloc
              BlocBuilder<BusinessNotificationBloc, BusinessNotificationState>(
                builder: (context, state) {
                  final unreadCount = state.unreadCount;

                  return Stack(
                    clipBehavior: Clip.none,
                    children: [
                      IconButton(
                        onPressed: onOpenNotifications,
                        icon: const Icon(
                          Icons.notifications_outlined,
                          size: 26,
                        ),
                        tooltip: t.socialNotifications,
                      ),
                      if (unreadCount > 0)
                        Positioned(
                          right: 6,
                          top: 6,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            constraints: const BoxConstraints(
                              minWidth: 18,
                              minHeight: 18,
                            ),
                            child: Text(
                              '$unreadCount',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                    ],
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            t.businessManageText,
            style: text.bodyMedium?.copyWith(
              color: scheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 12),

          // 🔥 Responsive, not stuck to the edge, bigger button
          LayoutBuilder(
            builder: (context, constraints) {
              final shortest = MediaQuery.of(context).size.shortestSide;
              final isTablet = shortest >= 600;

              // if width is unbounded, fallback to screen width - padding (32)
              final available = constraints.hasBoundedWidth
                  ? constraints.maxWidth
                  : MediaQuery.of(context).size.width - 32;

              // keep the button pleasantly wide but not full-bleed
              final double btnWidth =
                  (available.isFinite ? available.clamp(280.0, 520.0) : 520.0)
                      .toDouble();
              final double btnHeight = isTablet ? 56.0 : 52.0;

              return Align(
                alignment: Alignment.centerLeft,
                child: ConstrainedBox(
                  constraints: BoxConstraints.tightFor(
                    width: btnWidth,
                    height: btnHeight,
                  ),
                  child: ElevatedButton.icon(
                    onPressed: onOpenCreateActivity,
                    icon: const Icon(Icons.add_circle_outline, size: 22),
                    label: Text(
                      t.businessCreateActivity,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: scheme.primary,
                      foregroundColor: scheme.onPrimary,
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      textStyle: text.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                      elevation: 1,
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
