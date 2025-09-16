import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';

import '../../data/repositories/tickets_repository_impl.dart';
import '../../data/services/tickets_service.dart';
import '../../domain/usecases/get_tickets_by_status.dart';
import '../../domain/usecases/cancel_ticket.dart';
import '../../domain/usecases/delete_ticket.dart';
import '../bloc/tickets_bloc.dart';
import '../bloc/tickets_event.dart';
import '../bloc/tickets_state.dart';
import '../widgets/ticket_card.dart';

class UserTicketsScreen extends StatefulWidget {
  final String token; // Bearer token

  const UserTicketsScreen({super.key, required this.token});

  @override
  State<UserTicketsScreen> createState() => _UserTicketsScreenState();
}

class _UserTicketsScreenState extends State<UserTicketsScreen> {
  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final dio = g.appDio ?? Dio();

    final repo = TicketsRepositoryImpl(TicketsService(dio));
    final getByStatus = GetTicketsByStatus(repo);
    final cancelUse = CancelTicket(repo);
    final deleteUse = DeleteTicket(repo);

    return BlocProvider(
      create: (_) => TicketsBloc(
        token: widget.token,
        getByStatus: getByStatus,
        cancelTicket: cancelUse,
        deleteTicket: deleteUse,
      ),
      child: Scaffold(
        body: SafeArea(
          child: Column(
            children: [
              // Title
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    t.ticketScreenTitle, // "Tickets"
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),

              // Tabs
              _Tabs(
                onChanged: (s) =>
                    context.read<TicketsBloc>().add(TicketsTabChanged(s)),
              ),

              // List
              Expanded(
                child: BlocBuilder<TicketsBloc, TicketsState>(
                  builder: (_, state) {
                    final cs = Theme.of(context).colorScheme;

                    if (state is TicketsLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (state is TicketsError) {
                      return Center(
                        child: Text(
                          t.globalError,
                          style: TextStyle(color: cs.error),
                        ),
                      );
                    }
                    if (state is TicketsLoaded) {
                      if (state.tickets.isEmpty) {
                        final label = switch (state.status) {
                          'Pending' => t.ticketsEmptyPending,
                          'Completed' => t.ticketsEmptyCompleted,
                          'Canceled' => t.ticketsEmptyCanceled,
                          _ => t.ticketsEmptyGeneric,
                        };
                        return Center(
                          child: Text(
                            label,
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: AppColors.muted),
                          ),
                        );
                      }
                      return RefreshIndicator(
                        onRefresh: () async => context.read<TicketsBloc>().add(
                          const TicketsRefresh(),
                        ),
                        child: ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                          itemBuilder: (_, i) {
                            final b = state.tickets[i];
                            return Column(
                              children: [
                                TicketCard(
                                  booking: b,
                                  imageBaseUrl: _serverRoot(),
                                  onCancel: (id, reason) => context
                                      .read<TicketsBloc>()
                                      .add(TicketsCancelRequested(id, reason)),
                                ),
                                if (state.status == 'Canceled') ...[
                                  const SizedBox(height: 8),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        backgroundColor: AppColors.error,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      onPressed: () =>
                                          _confirmDelete(context, id: b.id),
                                      child: Text(t.ticketsDelete),
                                    ),
                                  ),
                                ],
                              ],
                            );
                          },
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 12),
                          itemCount: state.tickets.length,
                        ),
                      );
                    }
                    return const SizedBox.shrink();
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, {required int id}) async {
    final t = AppLocalizations.of(context)!;
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(t.ticketsDeleteTitle),
        content: Text(t.ticketsDeleteConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(t.buttonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(t.buttonConfirm),
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<TicketsBloc>().add(TicketsDeleteRequested(id));
    }
  }
}

class _Tabs extends StatefulWidget {
  final ValueChanged<String> onChanged;
  const _Tabs({required this.onChanged});

  @override
  State<_Tabs> createState() => _TabsState();
}

class _TabsState extends State<_Tabs> {
  String _status = 'Pending';

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    Widget chip(String label, String value) {
      final selected = _status == value;
      return InkWell(
        onTap: () {
          if (_status != value) {
            setState(() => _status = value);
            widget.onChanged(value);
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected ? AppColors.primary : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? AppColors.primary : cs.onSurface,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            ),
          ),
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          chip(t.ticketStatusPending, 'Pending'),
          chip(t.ticketStatusCompleted, 'Completed'),
          chip(t.ticketStatusCanceled, 'Canceled'),
        ],
      ),
    );
  }
}
