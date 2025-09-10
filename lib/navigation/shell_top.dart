// ===== Flutter 3.35.x =====
// ShellTop — top tab navigation (fixed header + smooth tabs)
// Fixed: includes BusinessNotificationBloc + BusinessHomeBloc for Home tab.

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/constants/app_role.dart';

// Business Activity
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/bloc/business_activities_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessActivity/presentation/screen/business_activities_screen.dart';

// Business Home
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/bloc/business_home_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessHome/presentation/screen/business_home_screen.dart';

// Business Notifications
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/repositories/business_notification_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/data/services/business_notification_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/domain/usecases/get_business_notifications.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessNotification/presentation/bloc/business_notification_event.dart';

// Business Profile
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/repositories/business_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/data/services/business_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/check_stripe_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/delete_business.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/get_business_by_id.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/domain/usecases/update_business_visibility.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/bloc/business_profile_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessProfile/presentation/screen/business_profile_screen.dart';

// Business Booking
import 'package:hobby_sphere/features/activities/Business/businessBooking/data/repositories/business_booking_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/data/services/business_booking_service.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/domain/usecases/get_business_bookings.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/domain/usecases/update_booking_status.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/bloc/business_booking_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/bloc/business_booking_event.dart';
import 'package:hobby_sphere/features/activities/Business/businessBooking/presentation/screen/business_booking_screen.dart';

// Business Analytics
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/data/repositories/business_analytics_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/data/services/business_analytics_service.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/domain/usecases/get_business_analytics.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/screen/business_analytics_screen.dart';

// Common UseCases
import 'package:hobby_sphere/features/activities/Business/common/data/repositories/business_activity_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/common/data/services/business_activity_service.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/delete_business_activity.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activities.dart';
import 'package:hobby_sphere/features/activities/Business/common/domain/usecases/get_business_activity_by_id.dart';

// User Screens
import 'package:hobby_sphere/features/activities/user/presentation/user_home_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_explore_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_community_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_tickets_screen.dart';
import 'package:hobby_sphere/features/activities/user/presentation/user_profile_screen.dart';

// Localizations
import 'package:hobby_sphere/l10n/app_localizations.dart';

class ShellTop extends StatelessWidget {
  final AppRole role;
  final String token;
  final int businessId;

  final void Function(Locale) onChangeLocale;
  final VoidCallback onToggleTheme;

  final int bookingsBadge;
  final int ticketsBadge;

  const ShellTop({
    super.key,
    required this.role,
    required this.token,
    required this.businessId,
    required this.onChangeLocale,
    required this.onToggleTheme,
    this.bookingsBadge = 0,
    this.ticketsBadge = 0,
  });

  List<String> _labels(BuildContext ctx) {
    final t = AppLocalizations.of(ctx)!;
    return role == AppRole.business
        ? [
            t.tabHome,
            t.tabBookings,
            t.tabAnalytics,
            t.tabActivities,
            t.tabProfile,
          ]
        : [t.tabHome, t.tabExplore, t.tabSocial, t.tabTickets, t.tabProfile];
  }

  List<(IconData, IconData)> _icons() {
    return role == AppRole.business
        ? const [
            (Icons.home_outlined, Icons.home),
            (Icons.event_available_outlined, Icons.event_available),
            (Icons.insights_outlined, Icons.insights),
            (Icons.local_activity_outlined, Icons.local_activity),
            (Icons.person_outline, Icons.person),
          ]
        : const [
            (Icons.home_outlined, Icons.home),
            (Icons.search_outlined, Icons.search),
            (Icons.groups_outlined, Icons.groups),
            (Icons.confirmation_number_outlined, Icons.confirmation_number),
            (Icons.person_outline, Icons.person),
          ];
  }

  List<Widget> _views(BuildContext context) {
    if (role == AppRole.business) {
      return [
        // ✅ Home with Notifications + HomeBloc
        MultiBlocProvider(
          providers: [
            BlocProvider(
              create: (ctx) => BusinessHomeBloc(
                getList: GetBusinessActivities(
                  BusinessActivityRepositoryImpl(BusinessActivityService()),
                ),
                getOne: GetBusinessActivityById(
                  BusinessActivityRepositoryImpl(BusinessActivityService()),
                ),
                deleteOne: DeleteBusinessActivity(
                  BusinessActivityRepositoryImpl(BusinessActivityService()),
                ),
                token: token,
                businessId: businessId,
                optimisticDelete: false,
              )..add(const BusinessHomeStarted()),
            ),
            BlocProvider(
              create: (ctx) {
                final repo = BusinessNotificationRepositoryImpl(
                  BusinessNotificationService(),
                );
                return BusinessNotificationBloc(
                  getBusinessNotifications: GetBusinessNotifications(repo),
                  repository: repo,
                  token: token,
                )..add(LoadUnreadCount(token));
              },
            ),
          ],
          child: BusinessHomeScreen(
            token: token,
            businessId: businessId,
            onCreate: (ctx, bid) {
              Navigator.pushNamed(
                ctx,
                Routes.createBusinessActivity,
                arguments: CreateActivityRouteArgs(businessId: bid),
              );
            },
          ),
        ),

        // ✅ Bookings
        BlocProvider(
          create: (ctx) => BusinessBookingBloc(
            getBookings: GetBusinessBookings(
              BusinessBookingRepositoryImpl(BusinessBookingService()),
            ),
            updateStatus: UpdateBookingStatus(
              BusinessBookingRepositoryImpl(BusinessBookingService()),
            ),
          )..add(BusinessBookingBootstrap()),
          child: const BusinessBookingScreen(),
        ),

        // ✅ Analytics
        BlocProvider(
          create: (ctx) => BusinessAnalyticsBloc(
            getBusinessAnalytics: GetBusinessAnalytics(
              BusinessAnalyticsRepositoryImpl(BusinessAnalyticsService()),
            ),
          )..add(LoadBusinessAnalytics(token: token, businessId: businessId)),
          child: BusinessAnalyticsScreen(token: token, businessId: businessId),
        ),

        // ✅ Activities
        BlocProvider(
          create: (ctx) {
            final repo = BusinessActivityRepositoryImpl(
              BusinessActivityService(),
            );
            return BusinessActivitiesBloc(
              getActivities: GetBusinessActivities(repo),
              deleteActivity: DeleteBusinessActivity(repo),
            )..add(
              LoadBusinessActivities(token: token, businessId: businessId),
            );
          },
          child: BusinessActivitiesScreen(token: token, businessId: businessId),
        ),

        // ✅ Profile
        BlocProvider(
          create: (ctx) {
            final businessRepo = BusinessRepositoryImpl(BusinessService());
            return BusinessProfileBloc(
              getBusinessById: GetBusinessById(businessRepo),
              updateBusinessVisibility: UpdateBusinessVisibility(businessRepo),
              updateBusinessStatus: UpdateBusinessStatus(businessRepo),
              deleteBusiness: DeleteBusiness(businessRepo),
              checkStripeStatus: CheckStripeStatus(businessRepo),
            )..add(LoadBusinessProfile(token, businessId));
          },
          child: BusinessProfileScreen(
            token: token,
            businessId: businessId,
            onTabChange: (_) {},
            onChangeLocale: onChangeLocale,
          ),
        ),
      ];
    }

    // ✅ User role
    return const [
      UserHomeScreen(),
      UserExploreScreen(),
      UserCommunityScreen(),
      UserTicketsScreen(),
      UserProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: Colors.transparent,
        systemNavigationBarDividerColor: Colors.transparent,
      ),
    );

    final scheme = Theme.of(context).colorScheme;
    final labels = _labels(context);
    final icons = _icons();
    final pages = _views(context);

    final badgeIndex = role == AppRole.business ? 1 : 3;
    final badgeCount = role == AppRole.business ? bookingsBadge : ticketsBadge;

    return DefaultTabController(
      length: labels.length,
      child: Builder(
        builder: (tabCtx) {
          final controller = DefaultTabController.of(tabCtx);

          return Scaffold(
            body: SafeArea(
              bottom: false,
              child: Column(
                children: [
                  Material(
                    elevation: 0,
                    color: Colors.transparent,
                    child: Container(
                      height: 42,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).dividerColor.withOpacity(0.6),
                        ),
                      ),
                      child: TabBar(
                        isScrollable: false,
                        indicator: BoxDecoration(
                          // softer highlight for selected tab
                          color: scheme.primary.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: scheme.primary, width: 1.5),
                        ),
                        labelColor: scheme.primary, // text colored like theme
                        unselectedLabelColor: scheme.onSurface.withOpacity(0.7),
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                          letterSpacing: 0.5,
                        ),
                        unselectedLabelStyle: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        tabs: labels.map((text) {
                          return Tab(
                            child: Center(
                              child: Text(
                                text,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.visible,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  Expanded(
                    child: TabBarView(controller: controller, children: pages),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Tiny, tasteful selected animation
class _AnimatedNavIcon extends StatelessWidget {
  final IconData unselected;
  final IconData selected;
  final bool isSelected;
  final Color color;
  final Color activeColor;

  const _AnimatedNavIcon({
    required this.unselected,
    required this.selected,
    required this.isSelected,
    required this.color,
    required this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 220),
      curve: Curves.easeOutCubic,
      tween: Tween<double>(begin: 0, end: isSelected ? 1 : 0),
      builder: (context, t, _) {
        final scale = 1.0 + 0.10 * t;
        final iconData = t > 0.5 ? selected : unselected;
        final iconColor = Color.lerp(color, activeColor, t)!;
        return Transform.scale(
          scale: scale,
          child: Icon(iconData, color: iconColor, size: 26),
        );
      },
    );
  }
}
