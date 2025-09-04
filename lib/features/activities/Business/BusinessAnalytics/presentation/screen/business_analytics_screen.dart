// ===== Flutter 3.35.x =====
// Business Analytics Screen (Pro UI + PDF Export + Floating Reviews Button)

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/utils/PdfHelper.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/bloc/business_analytics_state.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessAnalytics/presentation/widgets/analytics_widgets.dart';

class BusinessAnalyticsScreen extends StatelessWidget {
  final String token;
  final int businessId;

  const BusinessAnalyticsScreen({
    super.key,
    required this.token,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: theme.colorScheme.background,

      // ✅ floating action button → reviews
      floatingActionButton: FloatingActionButton(
        backgroundColor: theme.colorScheme.primary,
        shape: const CircleBorder(),
        child: const Icon(Icons.reviews, color: Colors.white),
        onPressed: () {
          Navigator.pushNamed(
            context,
            Routes.businessReviews,
            arguments: BusinessReviewsRouteArgs(
              businessId: businessId,
              token: token, // 👈 pass the token too
            ),
          );
        },
      ),

      body: BlocBuilder<BusinessAnalyticsBloc, BusinessAnalyticsState>(
        builder: (context, state) {
          if (state is BusinessAnalyticsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BusinessAnalyticsError) {
            return Center(
              child: Text(
                state.message,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }

          if (state is BusinessAnalyticsLoaded ||
              state is BusinessAnalyticsDownloading ||
              state is BusinessAnalyticsDownloadSuccess ||
              state is BusinessAnalyticsDownloadError) {
            final analytics = (state as dynamic).analytics;

            return RefreshIndicator(
              onRefresh: () async {
                context.read<BusinessAnalyticsBloc>().add(
                  RefreshBusinessAnalytics(
                    token: token,
                    businessId: businessId,
                  ),
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AnalyticsMetricsGrid(analytics: analytics),
                    const SizedBox(height: 24),
                    RevenueOverviewChart(analytics: analytics),
                    const SizedBox(height: 32),
                    AppButton(
                      label: tr.analyticsDownloadReport,
                      expand: true,
                      onPressed: () async {
                        await PdfHelper.exportPdf(analytics, businessId);
                      },
                      type: AppButtonType.primary,
                      size: AppButtonSize.lg,
                      trailing: const Icon(
                        Icons.picture_as_pdf,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          return Center(
            child: Text(tr.noBookings, style: theme.textTheme.bodyMedium),
          );
        },
      ),
    );
  }
}
