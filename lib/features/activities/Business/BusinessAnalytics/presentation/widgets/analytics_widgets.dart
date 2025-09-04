// ===== Flutter 3.35.x =====
// Analytics Widgets (Grid + Chart) with i18n + AppTheme

import 'package:flutter/material.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/business_analytics.dart';

class AnalyticsMetricsGrid extends StatelessWidget {
  final BusinessAnalytics analytics;

  const AnalyticsMetricsGrid({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context)!;

    final metrics = [
      _MetricData(
        icon: Icons.attach_money,
        label: tr.analyticsTotalRevenue,
        value: '\$${analytics.totalRevenue.toStringAsFixed(0)}',
        color: theme.colorScheme.primary,
      ),
      _MetricData(
        icon: Icons.emoji_events,
        label: tr.analyticsTopActivity,
        value: analytics.topActivity.isNotEmpty ? analytics.topActivity : '—',
        color: theme.colorScheme.secondary,
      ),
      _MetricData(
        icon: Icons.trending_up,
        label: tr.analyticsBookingGrowth,
        value: '${analytics.bookingGrowth.toStringAsFixed(1)}%',
        color: theme.colorScheme.tertiary,
      ),
      _MetricData(
        icon: Icons.schedule,
        label: tr.analyticsPeakHours,
        value: analytics.peakHours.isNotEmpty ? analytics.peakHours : '—',
        color: theme.colorScheme.outline,
      ),
      _MetricData(
        icon: Icons.group,
        label: tr.analyticsCustomerRetention,
        value: '${analytics.customerRetention.toStringAsFixed(1)}%',
        color: theme.colorScheme.primary,
      ),
      _MetricData(
        icon: Icons.calendar_today,
        label: tr.analyticsReportDate,
        value: analytics.analyticsDate, // use backend date directly
        color: theme.colorScheme.secondary,
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.1,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemCount: metrics.length,
      itemBuilder: (context, index) {
        final metric = metrics[index];
        return MetricCard(metric: metric);
      },
    );
  }
}

class MetricCard extends StatelessWidget {
  final _MetricData metric;

  const MetricCard({super.key, required this.metric});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(metric.icon, color: metric.color, size: 24),
          const SizedBox(height: 8),
          Text(
            metric.label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const Spacer(),
          Text(
            metric.value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: metric.color,
              fontWeight: FontWeight.w600,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class RevenueOverviewChart extends StatelessWidget {
  final BusinessAnalytics analytics;

  const RevenueOverviewChart({super.key, required this.analytics});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tr = AppLocalizations.of(context)!;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            tr.analyticsRevenueOverview, // i18n
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            height: 200,
            child: CustomPaint(
              size: const Size(double.infinity, 200),
              painter: _SimpleChartPainter(
                theme: theme,
                data: [0, 0], // TODO: pass real revenue data
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Text(
                tr.analyticsToday, // i18n
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
              Text(
                tr.analyticsYesterday, // i18n
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricData {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MetricData({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });
}

class _SimpleChartPainter extends CustomPainter {
  final ThemeData theme;
  final List<double> data;

  _SimpleChartPainter({required this.theme, required this.data});

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = theme.colorScheme.outline.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = theme.colorScheme.primary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // grid lines
    for (int i = 0; i <= 5; i++) {
      final y = size.height * i / 5;
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // vertical divisions
    for (int i = 0; i <= 4; i++) {
      final x = size.width * i / 4;
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }

    // data path
    final path = Path();
    final pointSpacing = size.width / (data.length - 1);

    for (int i = 0; i < data.length; i++) {
      final x = i * pointSpacing;
      final y = size.height - (data[i] / 100 * size.height);

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }

      canvas.drawCircle(
        Offset(x, y),
        4,
        Paint()..color = theme.colorScheme.primary,
      );
    }

    canvas.drawPath(path, linePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
