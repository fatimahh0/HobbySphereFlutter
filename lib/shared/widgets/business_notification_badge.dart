// business_notification_badge.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_state.dart';

class BusinessNotificationBadge extends StatelessWidget {
  final double iconSize;
  final VoidCallback? onTap;

  const BusinessNotificationBadge({super.key, this.iconSize = 26, this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return BlocSelector<
      BusinessNotificationBloc,
      BusinessNotificationState,
      int
    >(
      selector: (s) => s.unreadCount,
      builder: (context, count) {
        return Padding(
          padding: const EdgeInsets.all(6),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: onTap,
                icon: Icon(
                  Icons.notifications_none_outlined,
                  size: iconSize,
                  color: scheme.primary,
                ),
              ),
              if (count > 0)
                Positioned(
                  right: -2,
                  top: -3,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints: const BoxConstraints(
                      minWidth: 18,
                      minHeight: 18,
                    ),
                    decoration: BoxDecoration(
                      color: scheme.error,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      count > 99 ? '99+' : '$count',
                      style:
                          Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: scheme.onError,
                            fontWeight: FontWeight.bold,
                          ) ??
                          const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 11,
                          ),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
