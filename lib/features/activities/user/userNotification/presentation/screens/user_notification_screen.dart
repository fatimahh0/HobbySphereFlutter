import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import 'package:hobby_sphere/features/activities/user/userNotification/data/repositories/user_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/data/services/user_notification_service.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/entities/user_notification.dart';
import 'package:hobby_sphere/features/activities/user/userNotification/domain/usecases/get_user_notifications.dart';

import '../bloc/user_notification_bloc.dart';
import '../bloc/user_notification_event.dart';
import '../bloc/user_notification_state.dart';

class UserNotificationScreen extends StatelessWidget {
  final String token;
  const UserNotificationScreen({super.key, required this.token});

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    final repo = UserNotificationRepositoryImpl(UserNotificationService());
    final getNotifications = GetUserNotifications(repo);

    return BlocProvider(
      create: (_) => UserNotificationBloc(
        getUserNotifications: getNotifications,
        repository: repo,
        token: token,
      )..add(LoadUserNotifications()),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocConsumer<UserNotificationBloc, UserNotificationState>(
          listener: (context, state) {
            if (state.error != null) {
              showTopToast(
                context,
                state.error!,
                type: ToastType.error,
                haptics: true,
              );
              context.read<UserNotificationBloc>().add(ClearError());
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.notifications_none_rounded,
                      size: 48,
                      color: AppColors.muted,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      tr.notificationEmpty,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                    ),
                  ],
                ),
              );
            }
            return RefreshIndicator(
              onRefresh: () async => context.read<UserNotificationBloc>().add(
                LoadUserNotifications(),
              ),
              child: ListView.separated(
                padding: const EdgeInsets.all(12),
                separatorBuilder: (_, __) => const SizedBox(height: 8),
                itemCount: state.notifications.length,
                itemBuilder: (context, i) {
                  final n = state.notifications[i];
                  return _NotificationCard(notification: n, token: token);
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final UserNotification notification;
  final String token;
  const _NotificationCard({required this.notification, required this.token});

  IconData _iconForType(String code) {
    switch (code) {
      case 'NEW_MESSAGE':
        return Icons.mark_chat_unread_rounded;
      case 'BOOKING_CREATED':
      case 'BOOKING_CONFIRMED':
        return Icons.event_available_rounded;
      case 'BOOKING_CANCELLED':
      case 'BOOKING_CANCELED':
      case 'BOOKING_REJECTED':
        return Icons.event_busy_rounded;
      case 'BOOKING_COMPLETED':
        return Icons.check_circle_rounded;
      case 'ITEM_UPDATED':
        return Icons.update_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  Color _colorForType(String code) {
    switch (code) {
      case 'NEW_MESSAGE':
        return AppColors.primary;
      case 'BOOKING_CREATED':
      case 'BOOKING_CONFIRMED':
        return AppColors.paid;
      case 'BOOKING_CANCELLED':
      case 'BOOKING_CANCELED':
      case 'BOOKING_REJECTED':
        return AppColors.canceled;
      case 'BOOKING_COMPLETED':
        return AppColors.completed;
      case 'ITEM_UPDATED':
        return AppColors.pending;
      default:
        return AppColors.muted;
    }
  }

  String _ago(DateTime dt) {
    final d = DateTime.now().difference(dt);
    if (d.inMinutes < 1) return 'just now';
    if (d.inHours < 1) return '${d.inMinutes}m ago';
    if (d.inDays < 1) return '${d.inHours}h ago';
    return '${d.inDays}d ago';
  }

  void _handleNavigation(BuildContext context) {
    final nav = Navigator.of(context);
    switch (notification.typeCode) {
      case 'BOOKING_CREATED':
      case 'BOOKING_CONFIRMED':
      case 'BOOKING_CANCELLED':
      case 'BOOKING_CANCELED':
      case 'BOOKING_REJECTED':
      case 'BOOKING_COMPLETED':
        nav.pushNamed(Routes.userTicketsCalendar);
        break;
      // case 'NEW_MESSAGE': nav.pushNamed(Routes.singleChat); break;
      // case 'ITEM_UPDATED': nav.pushNamed(Routes.explore); break;
      default:
        showTopToast(
          context,
          AppLocalizations.of(context)!.noScreenForNotification,
          type: ToastType.info,
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<UserNotificationBloc>();
    final tr = AppLocalizations.of(context)!;

    return Card(
      color: notification.read
          ? AppColors.white
          : AppColors.primary.withOpacity(0.05),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _colorForType(
            notification.typeCode,
          ).withOpacity(0.15),
          child: Icon(
            _iconForType(notification.typeCode),
            color: _colorForType(notification.typeCode),
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          notification.message,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.text,
            fontWeight: notification.read ? FontWeight.w400 : FontWeight.w600,
          ),
        ),
        subtitle: Text(
          '${notification.typeDescription} • ${_ago(notification.createdAt.toLocal())}',
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.muted,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: AppColors.error),
          onPressed: () {
            bloc.add(DeleteUserNotification(notification.id));
            showTopToast(
              context,
              tr.deletedSuccessfully,
              type: ToastType.success,
            );
          },
        ),
        onTap: () {
          bloc.add(MarkUserNotificationRead(notification.id));
          _handleNavigation(context);
        },
      ),
    );
  }
}
