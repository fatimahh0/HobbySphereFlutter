import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:excel/excel.dart';
import 'package:hobby_sphere/core/network/globals.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/data/repositories/business_users_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/data/services/business_users_service.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/domain/usecases/book_cash.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/domain/usecases/create_business_user.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/domain/usecases/get_business_users.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/presentation/bloc/business_users_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/presentation/bloc/business_users_event.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/presentation/screens/business_users_screen.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

import 'package:hobby_sphere/features/activities/Business/BusinessInsights/data/repositories/insight_repository_impl.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessInsights/data/services/insight_service.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessInsights/domain/usecases/get_business_bookings.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessInsights/domain/usecases/mark_booking_paid.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessInsights/presentation/bloc/insights_bloc.dart';

import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/app/router/router.dart';

class BusinessInsightsScreen extends StatefulWidget {
  final String token;
  final int businessId;
  final int itemId;

  const BusinessInsightsScreen({
    super.key,
    required this.token,
    required this.businessId,
    required this.itemId,
  });

  @override
  State<BusinessInsightsScreen> createState() => _BusinessInsightsScreenState();
}

class _BusinessInsightsScreenState extends State<BusinessInsightsScreen> {
  String _filter = "Paid";
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) => InsightsBloc(
        getBookings: GetBusinessBookings(
          InsightRepositoryImpl(InsightService()),
        ),
        markPaid: MarkBookingPaid(InsightRepositoryImpl(InsightService())),
      )..add(LoadInsights(widget.token, itemId: widget.itemId)),
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr.activityInsightsTitle, style: tt.headlineSmall),
          centerTitle: true,
          actions: [
            BlocBuilder<InsightsBloc, InsightsState>(
              builder: (context, state) {
                if (state is InsightsLoaded) {
                  // 👇 Collect enrolled userIds
                  final enrolledIds = state.bookings
                      .map((b) => b.businessUserId)
                      .whereType<int>()
                      .toList();

                  return AppIconButton(
                    icon: const Icon(Icons.group_add),
                    onPressed: () async {
                      final refresh = await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) {
                            final repo = BusinessUsersRepositoryImpl(
                              BusinessUsersService(),
                            );
                            return BlocProvider(
                              create: (_) => BusinessUsersBloc(
                                getUsers: GetBusinessUsers(repo),
                                createUser: CreateBusinessUser(repo),
                                bookCash: BookCash(repo),
                              )..add(LoadBusinessUsers(widget.token)),
                              child: BusinessUsersScreen(
                                token: widget.token,
                                businessId: widget.businessId,
                                itemId: widget.itemId,
                                enrolledUserIds: enrolledIds,
                              ),
                            );
                          },
                        ),
                      );

                      if (refresh == true) {
                        context.read<InsightsBloc>().add(
                          LoadInsights(widget.token, itemId: widget.itemId),
                        );
                      }
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),
            const SizedBox(width: 12),
          ],
        ),

        body: BlocBuilder<InsightsBloc, InsightsState>(
          builder: (context, state) {
            if (state is InsightsLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is InsightsLoaded) {
              var list = state.bookings;

              final enrolledIds = state.bookings
                  .map((b) => b.businessUserId) // 👈 link to BusinessUser
                  .whereType<int>() // filter out nulls
                  .toList();

              // === Apply filters ===
              if (_filter == "Paid") {
                list = list.where((b) => b.wasPaid).toList();
              } else if (_filter == "Not Paid") {
                list = list.where((b) => !b.wasPaid).toList();
              }

              // === Apply search ===
              if (_query.isNotEmpty) {
                list = list
                    .where(
                      (b) =>
                          b.clientName.toLowerCase().contains(
                            _query.toLowerCase(),
                          ) ||
                          b.itemName.toLowerCase().contains(
                            _query.toLowerCase(),
                          ),
                    )
                    .toList();
              }

              return Column(
                children: [
                  // Top actions
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Expanded(
                          child: AppButton(
                            label: tr.exportExcel,
                            leading: const Icon(Icons.download_rounded),
                            onPressed: () => _exportExcel(list, tr),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Search bar
                  AppSearchBar(
                    hint: tr.searchPlaceholder,
                    onQueryChanged: (q) => setState(() => _query = q),
                  ),

                  // Filter chips
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Wrap(
                      spacing: 8,
                      children: [
                        ChoiceChip(
                          label: Text(tr.filtersAll),
                          selected: _filter == "All",
                          onSelected: (_) => setState(() => _filter = "All"),
                        ),
                        ChoiceChip(
                          label: Text(tr.filtersPaid),
                          selected: _filter == "Paid",
                          onSelected: (_) => setState(() => _filter = "Paid"),
                        ),
                        ChoiceChip(
                          label: Text(tr.filtersNotPaid),
                          selected: _filter == "Not Paid",
                          onSelected: (_) =>
                              setState(() => _filter = "Not Paid"),
                        ),
                      ],
                    ),
                  ),

                  // List of bookings
                  Expanded(
                    child: list.isEmpty
                        ? Center(
                            child: Text(
                              tr.noBookings,
                              style: tt.bodyMedium?.copyWith(
                                color: cs.onSurfaceVariant,
                              ),
                            ),
                          )
                        : ListView.separated(
                            itemCount: list.length,
                            separatorBuilder: (_, __) => Divider(
                              color: cs.outlineVariant,
                              thickness: 0.8,
                            ),
                            itemBuilder: (_, i) {
                              final b = list[i];
                              return Card(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                elevation: 1,
                                child: ListTile(
                                  contentPadding: const EdgeInsets.all(12),
                                  leading: CircleAvatar(
                                    backgroundColor: b.wasPaid
                                        ? AppColors.completed.withOpacity(0.15)
                                        : AppColors.pending.withOpacity(0.15),
                                    child: Icon(
                                      b.wasPaid
                                          ? Icons.check_circle
                                          : Icons.pending_actions,
                                      color: b.wasPaid
                                          ? AppColors.completed
                                          : AppColors.pending,
                                    ),
                                  ),
                                  title: Text(
                                    b.clientName,
                                    style: tt.titleMedium,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        b.itemName,
                                        style: tt.bodyMedium?.copyWith(
                                          color: cs.onSurfaceVariant,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        b.wasPaid ? tr.paid : tr.notPaid,
                                        style: tt.labelLarge?.copyWith(
                                          color: b.wasPaid
                                              ? AppColors.completed
                                              : AppColors.error,
                                        ),
                                      ),
                                    ],
                                  ),
                                  trailing: !b.wasPaid
                                      ? SizedBox(
                                          width: 120, // 👈 control the width
                                          child: AppButton(
                                            label: tr.markAsPaid,
                                            type: AppButtonType.outline,
                                            onPressed: () {
                                              context.read<InsightsBloc>().add(
                                                MarkAsPaid(
                                                  widget.token,
                                                  b.id,
                                                  itemId: widget.itemId,
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : null,
                                ),
                              );
                            },
                          ),
                  ),
                ],
              );
            }
            return const SizedBox();
          },
        ),
      ),
    );
  }

  // Export to Excel
  void _exportExcel(List list, AppLocalizations tr) async {
    final excel = Excel.createExcel();
    final sheet = excel['Sheet1'];

    sheet.appendRow([
      TextCellValue(tr.insightsName),
      TextCellValue(tr.insightsItem),
      TextCellValue(tr.insightsPayment),
    ]);

    for (var b in list) {
      sheet.appendRow([
        TextCellValue(b.clientName),
        TextCellValue(b.itemName),
        TextCellValue(b.wasPaid ? tr.paid : tr.notPaid),
      ]);
    }

    final fileBytes = excel.encode();
    if (fileBytes == null) return;

    final dir = await getApplicationDocumentsDirectory();
    final path = "${dir.path}/insights_report.xlsx";
    final file = File(path)
      ..createSync(recursive: true)
      ..writeAsBytesSync(fileBytes);

    await OpenFilex.open(path);
  }
}
