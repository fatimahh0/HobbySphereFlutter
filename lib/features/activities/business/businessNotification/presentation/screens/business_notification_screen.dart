// ===== Flutter 3.35.x =====
// BusinessNotificationScreen
// - Uses AppTheme + AppLocalizations
// - Themed top toast for feedback
// - Shows icons per notification type
// - Navigates to correct screen on tap
// - Marks notifications as read before navigation

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/router/router.dart';

import 'package:hobby_sphere/features/activities/business/businessNotification/data/repositories/business_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/data/services/business_notification_service.dart';

import 'package:hobby_sphere/features/activities/business/businessNotification/domain/entities/business_notification.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_event.dart';
import 'package:hobby_sphere/features/activities/business/businessNotification/presentation/bloc/business_notification_state.dart';

import 'package:hobby_sphere/core/constants/app_role.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_colors.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

class BusinessNotificationScreen extends StatelessWidget {
  final String token;
  final int businessId;
  const BusinessNotificationScreen({
    super.key,
    required this.token,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    // prepare repo + usecase
    final repo = BusinessNotificationRepositoryImpl(
      BusinessNotificationService(),
    );
    final getNotifications = GetBusinessNotifications(repo);

    return BlocProvider(
      create: (_) => BusinessNotificationBloc(
        getBusinessNotifications: getNotifications,
        repository: repo,
        token: token,
      )..add(LoadBusinessNotifications()),
      child: Scaffold(
        appBar: AppBar(),
        body: BlocConsumer<BusinessNotificationBloc, BusinessNotificationState>(
          listener: (context, state) {
            if (state.error != null) {
              showTopToast(
                context,
                state.error!,
                type: ToastType.error,
                haptics: true,
              );
            }
          },
          builder: (context, state) {
            if (state.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }
            if (state.notifications.isEmpty) {
              return Center(
                child: Text(
                  tr.notificationEmpty,
                  style: AppTypography.textTheme.bodyMedium?.copyWith(
                    color: AppColors.muted,
                  ),
                ),
              );
            }
            return ListView.separated(
              padding: const EdgeInsets.all(12),
              separatorBuilder: (_, __) => const SizedBox(height: 8),
              itemCount: state.notifications.length,
              itemBuilder: (context, i) {
                final n = state.notifications[i];
                return _NotificationCard(
                  notification: n,
                  token: token,
                  businessId: businessId,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final BusinessNotification notification;
  final String token;
  final int businessId;
  const _NotificationCard({
    required this.notification,
    required this.token,
    required this.businessId,
  });

  // choose icon per type
  IconData _iconForType(String code) {
    switch (code) {
      case 'NEW_REVIEW':
        return Icons.rate_review_rounded;
      case 'BOOKING_CREATED':
        return Icons.event_available_rounded;
      case 'BOOKING_CANCELLED':
        return Icons.event_busy_rounded;
      case 'BOOKING_COMPLETED':
        return Icons.check_circle_rounded;
      default:
        return Icons.notifications_rounded;
    }
  }

  // choose color per type
  Color _colorForType(String code) {
    switch (code) {
      case 'NEW_REVIEW':
        return AppColors.primary;
      case 'BOOKING_CREATED':
        return AppColors.paid;
      case 'BOOKING_CANCELLED':
        return AppColors.canceled;
      case 'BOOKING_COMPLETED':
        return AppColors.completed;
      default:
        return AppColors.muted;
    }
  }

  // handle navigation depending on type
  void _handleNavigation(BuildContext context) {
    final nav = Navigator.of(context);

    switch (notification.typeCode) {
      case 'BOOKING_CREATED':
      case 'BOOKING_CANCELLED':
      case 'BOOKING_COMPLETED':
        nav.pushNamed(Routes.businessBookings);
        break;

      case 'NEW_REVIEW':
        nav.pushNamed(
          Routes.businessReviews,
          arguments: BusinessReviewsRouteArgs(
            businessId: businessId,
            token: token,
          ),
        );
        break;

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
    final bloc = context.read<BusinessNotificationBloc>();
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
          notification.typeDescription,
          style: AppTypography.textTheme.bodyMedium?.copyWith(
            color: AppColors.muted,
          ),
        ),
        trailing: IconButton(
          icon: Icon(Icons.delete, color: AppColors.error),
          onPressed: () {
            bloc.add(DeleteBusinessNotification(notification.id));
            showTopToast(
              context,
              tr.deletedSuccessfully,
              type: ToastType.success,
            );
          },
        ),
        onTap: () {
          // mark as read before navigation
          bloc.add(MarkBusinessNotificationRead(notification.id));

          // navigate to correct screen
          _handleNavigation(context);
        },
      ),
    );
  }
}
