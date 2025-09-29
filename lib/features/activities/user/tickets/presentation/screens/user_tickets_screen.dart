// Flutter 3.35.x — User Tickets (realtime refresh on booking events)

// core imports
import 'package:dio/dio.dart'; // http client
import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/core/network/globals.dart' as g; // globals

// l10n + theme
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // theme

// data layer
import '../../data/repositories/tickets_repository_impl.dart'; // repo
import '../../data/services/tickets_service.dart'; // service

// domain layer
import '../../domain/usecases/get_tickets_by_status.dart'; // uc
import '../../domain/usecases/cancel_ticket.dart'; // uc
import '../../domain/usecases/delete_ticket.dart'; // uc

// presentation layer
import '../bloc/tickets_bloc.dart'; // bloc
import '../bloc/tickets_event.dart'; // events
import '../bloc/tickets_state.dart'; // states
import '../widgets/ticket_card.dart'; // card ui

// ✅ realtime bridge starter (the only new import)
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart'
    as rt; // ws/bridge

class UserTicketsScreen extends StatefulWidget {
  final String token; // Bearer <jwt> or plain <jwt>
  const UserTicketsScreen({super.key, required this.token}); // ctor

  @override
  State<UserTicketsScreen> createState() => _UserTicketsScreenState(); // state
}

class _UserTicketsScreenState extends State<UserTicketsScreen> {
  bool _wsBound = false; // guard to bind realtime only once

  /// Helper for image base (strip trailing "/api" for static files)
  String _serverRoot() {
    final base = (g.appServerRoot ?? ''); // e.g. https://host/api
    return base.replaceFirst(RegExp(r'/api/?$'), ''); // → https://host
  }

  /// Provide a Dio instance (reuse global if available)
  Dio _provideDio() {
    if (g.appDio != null) return g.appDio!; // reuse
    final raw = (g.appServerRoot ?? '').trim(); // base
    if (raw.isEmpty ||
        !(raw.startsWith('http://') || raw.startsWith('https://'))) {
      throw StateError('Invalid appServerRoot: "$raw"'); // guard
    }
    final dio = Dio(
      BaseOptions(
        baseUrl: raw, // keep /api here for REST
        connectTimeout: const Duration(seconds: 15), // timeouts
        receiveTimeout: const Duration(seconds: 30),
        sendTimeout: const Duration(seconds: 30),
        headers: {'Accept': 'application/json'}, // json
      ),
    );
    g.appDio = dio; // cache globally
    return dio; // return
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n

    final dio = _provideDio(); // http
    final repo = TicketsRepositoryImpl(TicketsService(dio)); // repo
    final getByStatus = GetTicketsByStatus(repo); // uc
    final cancelUse = CancelTicket(repo); // uc
    final deleteUse = DeleteTicket(repo); // uc

    return BlocProvider(
      // provide tickets bloc
      create: (_) => TicketsBloc(
        token: widget.token, // pass token
        getByStatus: getByStatus, // inject uc
        cancelTicket: cancelUse, // inject uc
        deleteTicket: deleteUse, // inject uc
      ),
      // use inner builder context for .read()
      child: Builder(
        builder: (ctx) {
          // ✅ bind realtime → refresh list on booking events
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (_wsBound) return; // run once
            _wsBound = true; // mark bound

            // when backend pushes a booking event → reload current tab
            rt.userBridge.onBooking = (payload) {
              if (!mounted) return; // safety
              ctx.read<TicketsBloc>().add(const TicketsRefresh()); // reload
            };
          });

          return Scaffold(
            body: SafeArea(
              child: Column(
                children: [
                  // title
                  Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      16,
                      16,
                      8,
                    ), // spacing
                    child: Align(
                      alignment: Alignment.centerLeft, // left
                      child: Text(
                        t.ticketScreenTitle, // l10n title
                        style: Theme.of(ctx).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700, // bold
                        ),
                      ),
                    ),
                  ),

                  // tabs (Pending | Completed | Cancel → Requested|Canceled)
                  _Tabs(
                    onChanged: (s) => ctx.read<TicketsBloc>().add(
                      TicketsTabChanged(s),
                    ), // change status
                  ),

                  // list area
                  Expanded(
                    child: BlocBuilder<TicketsBloc, TicketsState>(
                      builder: (_, state) {
                        final cs = Theme.of(ctx).colorScheme; // colors

                        if (state is TicketsLoading) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          ); // loader
                        }
                        if (state is TicketsError) {
                          return Center(
                            child: Text(
                              t.globalError, // generic text
                              style: TextStyle(color: cs.error), // red
                            ),
                          );
                        }
                        if (state is TicketsLoaded) {
                          // empty state per bucket
                          if (state.tickets.isEmpty) {
                            final label = switch (state.status) {
                              'Pending' => t.ticketsEmptyPending, // text
                              'Completed' => t.ticketsEmptyCompleted, // text
                              'CancelRequested' =>
                                t.ticketsEmptyCanceled, // text
                              'Canceled' => t.ticketsEmptyCanceled, // text
                              _ => t.ticketsEmptyGeneric, // fallback
                            };
                            return Center(
                              child: Text(
                                label, // message
                                style: Theme.of(ctx).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.muted), // muted
                              ),
                            );
                          }

                          // list with pull-to-refresh
                          return RefreshIndicator(
                            onRefresh: () async => ctx.read<TicketsBloc>().add(
                              const TicketsRefresh(),
                            ), // reload
                            child: ListView.separated(
                              physics:
                                  const AlwaysScrollableScrollPhysics(), // allow pull
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                8,
                                16,
                                24,
                              ), // insets
                              itemBuilder: (_, i) {
                                final b = state.tickets[i]; // row
                                return Column(
                                  children: [
                                    TicketCard(
                                      booking: b, // data
                                      imageBaseUrl:
                                          _serverRoot(), // absolute base for images
                                      onCancel: (id, reason) =>
                                          ctx.read<TicketsBloc>().add(
                                            TicketsCancelRequested(id, reason),
                                          ), // cancel
                                    ),
                                    if (state.status == 'Canceled') ...[
                                      const SizedBox(height: 8), // gap
                                      SizedBox(
                                        width: double.infinity, // full width
                                        child: OutlinedButton(
                                          style: OutlinedButton.styleFrom(
                                            foregroundColor:
                                                Colors.white, // text color
                                            backgroundColor:
                                                AppColors.error, // red
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                            ), // pad
                                          ),
                                          onPressed: () => _confirmDelete(
                                            ctx,
                                            id: b.id,
                                          ), // delete
                                          child: Text(t.ticketsDelete), // label
                                        ),
                                      ),
                                    ],
                                  ],
                                );
                              },
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 10), // gap
                              itemCount: state.tickets.length, // count
                            ),
                          );
                        }

                        return const SizedBox.shrink(); // fallback
                      },
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    // optional: clear the hook (keeps things tidy when leaving screen)
    rt.userBridge.onBooking = null; // remove listener
    super.dispose(); // parent cleanup
  }

  // confirm delete dialog
  Future<void> _confirmDelete(BuildContext context, {required int id}) async {
    final t = AppLocalizations.of(context)!; // l10n
    final ok = await showDialog<bool>(
      context: context, // ctx
      builder: (_) => AlertDialog(
        title: Text(t.ticketsDeleteTitle), // title
        content: Text(t.ticketsDeleteConfirm), // question
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false), // cancel
            child: Text(t.buttonCancel), // label
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true), // ok
            child: Text(t.buttonConfirm), // label
          ),
        ],
      ),
    );
    if (ok == true && context.mounted) {
      context.read<TicketsBloc>().add(TicketsDeleteRequested(id)); // delete
    }
  }
}

// small tabs widget (main + cancel sub)
class _Tabs extends StatefulWidget {
  final ValueChanged<String> onChanged; // status callback
  const _Tabs({required this.onChanged}); // ctor

  @override
  State<_Tabs> createState() => _TabsState(); // state
}

class _TabsState extends State<_Tabs> {
  String _main = 'Pending'; // main: Pending | Completed | Cancel
  String _cancelSub = 'CancelRequested'; // sub: CancelRequested | Canceled

  // emit proper status depending on main/sub
  void _emit() {
    if (_main == 'Cancel') {
      widget.onChanged(_cancelSub); // sub status
    } else {
      widget.onChanged(_main); // main status
    }
  }

  @override
  void initState() {
    super.initState(); // life-cycle
    _emit(); // initial emit
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // l10n
    final cs = Theme.of(context).colorScheme; // colors

    // helper for a chip-like tab
    Widget chip(String label, bool selected, VoidCallback onTap) {
      return InkWell(
        onTap: onTap, // change
        borderRadius: BorderRadius.circular(16), // ripple radius
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 10,
            vertical: 8,
          ), // pad
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: selected
                    ? AppColors.primary
                    : Colors.transparent, // underline
                width: 2, // thickness
              ),
            ),
          ),
          child: Text(
            label, // text
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: selected ? AppColors.primary : cs.onSurface, // color
              fontWeight: selected
                  ? FontWeight.w700
                  : FontWeight.w500, // weight
            ),
          ),
        ),
      );
    }

    // main bar (3 options)
    final mainBar = Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: cs.outlineVariant)), // divider
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16), // pad
      height: 46, // height
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround, // spread
        children: [
          chip(t.ticketStatusPending, _main == 'Pending', () {
            setState(() => _main = 'Pending'); // select
            _emit(); // notify
          }),
          chip(t.ticketStatusCompleted, _main == 'Completed', () {
            setState(() => _main = 'Completed'); // select
            _emit(); // notify
          }),
          chip(t.ticketStatusCanceled, _main == 'Cancel', () {
            setState(() => _main = 'Cancel'); // select
            _emit(); // notify
          }),
        ],
      ),
    );

    // sub bar (only when Cancel main tab active)
    final subBar = _main != 'Cancel'
        ? const SizedBox.shrink() // hide
        : Container(
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(color: cs.outlineVariant),
              ), // divider
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16), // pad
            height: 40, // height
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center, // center
              children: [
                chip(
                  t.ticketsCancelRequested,
                  _cancelSub == 'CancelRequested',
                  () {
                    setState(() => _cancelSub = 'CancelRequested'); // pick
                    _emit(); // notify
                  },
                ),
                const SizedBox(width: 16), // gap
                chip(t.ticketCancel, _cancelSub == 'Canceled', () {
                  setState(() => _cancelSub = 'Canceled'); // pick
                  _emit(); // notify
                }),
              ],
            ),
          );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [mainBar, subBar],
    ); // stack
  }
}
