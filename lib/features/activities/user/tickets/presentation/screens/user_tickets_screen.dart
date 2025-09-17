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
  final String token; // Bearer <jwt> or <jwt>; both supported
  const UserTicketsScreen({super.key, required this.token});

  @override
  State<UserTicketsScreen> createState() => _UserTicketsScreenState();
}

class _UserTicketsScreenState extends State<UserTicketsScreen> {
  /// For image URLs only (strip trailing "/api")
  String _serverRoot() {
    final base = (g.appServerRoot ?? '');
    return base.replaceFirst(RegExp(r'/api/?$'), '');
  }

  Dio _provideDio() {
    if (g.appDio != null) return g.appDio!;
    final raw = (g.appServerRoot ?? '').trim();
    if (raw.isEmpty ||
        !(raw.startsWith('http://') || raw.startsWith('https://'))) {
      throw StateError('Invalid appServerRoot: "$raw"');
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: raw, // keep /api for API calls
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'},
      ),
    );
    g.appDio = dio;
    return dio;
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;

    final dio = _provideDio();
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
      // use inner ctx so context.read finds the provider
      child: Builder(
        builder: (ctx) => Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                // Title
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      t.ticketScreenTitle,
                      style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),

                // Tabs (Pending | Completed | Cancel -> Requested|Canceled)
                _Tabs(
                  onChanged: (s) =>
                      ctx.read<TicketsBloc>().add(TicketsTabChanged(s)),
                ),

                // List
                Expanded(
                  child: BlocBuilder<TicketsBloc, TicketsState>(
                    builder: (_, state) {
                      final cs = Theme.of(ctx).colorScheme;

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
                            'CancelRequested' => t.ticketsEmptyCanceled,
                            'Canceled' => t.ticketsEmptyCanceled,
                            _ => t.ticketsEmptyGeneric,
                          };
                          return Center(
                            child: Text(
                              label,
                              style: Theme.of(ctx).textTheme.bodyMedium
                                  ?.copyWith(color: AppColors.muted),
                            ),
                          );
                        }
                        return RefreshIndicator(
                          onRefresh: () async => ctx.read<TicketsBloc>().add(
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
                                    onCancel: (id, reason) =>
                                        ctx.read<TicketsBloc>().add(
                                          TicketsCancelRequested(id, reason),
                                        ),
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
                                            vertical: 10,
                                          ),
                                        ),
                                        onPressed: () =>
                                            _confirmDelete(ctx, id: b.id),
                                        child: Text(t.ticketsDelete),
                                      ),
                                    ),
                                  ],
                                ],
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 10),
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
  // main: 'Pending' | 'Completed' | 'Cancel'
  String _main = 'Pending';
  // sub for cancel: 'CancelRequested' | 'Canceled'
  String _cancelSub = 'CancelRequested';

  void _emit() {
    if (_main == 'Cancel') {
      widget.onChanged(_cancelSub);
    } else {
      widget.onChanged(_main);
    }
  }

  @override
  void initState() {
    super.initState();
    _emit();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    Widget chip(String label, bool selected, VoidCallback onTap) {
      return InkWell(
        onTap: onTap,
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

    // MAIN BAR
    final mainBar = Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      height: 46,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          chip(t.ticketStatusPending, _main == 'Pending', () {
            setState(() => _main = 'Pending');
            _emit();
          }),
          chip(t.ticketStatusCompleted, _main == 'Completed', () {
            setState(() => _main = 'Completed');
            _emit();
          }),
          chip(t.ticketStatusCanceled, _main == 'Cancel', () {
            setState(() => _main = 'Cancel');
            _emit();
          }),
        ],
      ),
    );

    // SUB BAR (only when Cancel main tab active)
    final subBar = _main != 'Cancel'
        ? const SizedBox.shrink()
        : Container(
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: cs.outlineVariant)),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            height: 40,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                chip(
                  t.ticketsCancelRequested,
                  _cancelSub == 'CancelRequested',
                  () {
                    setState(() => _cancelSub = 'CancelRequested');
                    _emit();
                  },
                ),
                const SizedBox(width: 16),
                chip(t.ticketCancel, _cancelSub == 'Canceled', () {
                  setState(() => _cancelSub = 'Canceled');
                  _emit();
                }),
              ],
            ),
          );

    return Column(mainAxisSize: MainAxisSize.min, children: [mainBar, subBar]);
  }
}
