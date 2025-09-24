// friendship_screen.dart
// one hub with 3 tabs — now with a global search and initialTab

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/widgets/user_tile.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import '../bloc/friends/friends_bloc.dart';
import '../bloc/friends/friends_event.dart';
import '../bloc/friends/friends_state.dart';

class FriendshipScreen extends StatefulWidget {
  final int initialTab; // which tab to open
  const FriendshipScreen({
    super.key,
    this.initialTab = 0,
  }); // 0 rec, 1 sent, 2 friends

  @override
  State<FriendshipScreen> createState() => _FriendshipScreenState();
}

class _FriendshipScreenState extends State<FriendshipScreen> {
  late int tab; // current tab index
  String q = ''; // global search text

  @override
  void initState() {
    super.initState();
    tab = widget.initialTab; // set initial tab
    final b = context.read<FriendsBloc>(); // get bloc
    b.add(const LoadReceived()); // load received
    b.add(const LoadSent()); // load sent
    b.add(const LoadFriends()); // load friends
  }

  // filter helper that works for all three lists
  List<T> _filterByName<T>(List<T> src, String Function(T) getter) {
    final s = q.trim().toLowerCase(); // normalize search
    if (s.isEmpty) return src; // no filter
    return src.where((e) => getter(e).toLowerCase().contains(s)).toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors

    return Scaffold(
      appBar: AppBar(title: Text('')), // title
      body: SafeArea(
        child: Column(
          children: [
            // 🔎 global search (works on all tabs)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => q = v), // update search
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search), // icon
                  hintText: l10.friendshipAddFriendSearchPlaceholder,
                  filled: true, // style
                  fillColor: cs.surface, // bg
                  border: OutlineInputBorder(
                    // no border
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            // tabs
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _Seg(
                      label: l10.friendshipReceivedRequests, // received
                      selected: tab == 0,
                      onTap: () => setState(() => tab = 0),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Seg(
                      label: l10.friendshipSentRequests, // sent
                      selected: tab == 1,
                      onTap: () => setState(() => tab = 1),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _Seg(
                      label: l10.friendshipMyFriends, // friends
                      selected: tab == 2,
                      onTap: () => setState(() => tab = 2),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),

            // lists
            Expanded(
              child: BlocConsumer<FriendsBloc, FriendsState>(
                listener: (ctx, st) {
                  if (st.error != null && st.error!.isNotEmpty) {
                    showTopToast(
                      context,
                      l10.friendshipErrorFailedAction,
                      type: ToastType.error,
                    ); // show error toast
                  }
                },
                builder: (ctx, st) {
                  final loadingAll =
                      st.isLoading &&
                      st.received.isEmpty &&
                      st.sent.isEmpty &&
                      st.friends.isEmpty; // first load spinner

                  if (loadingAll) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // pick + filter by current tab
                  if (tab == 0) {
                    final list = _filterByName(
                      st.received,
                      (r) => r.user.fullName,
                    );
                    if (list.isEmpty)
                      return Center(child: Text(l10.friendshipNoRequests));
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (_, i) {
                        final r = list[i]; // request row
                        return UserTile(
                          user: r.user, // shows avatar
                          subtitle: l10.friendTab_received,
                          trailing: Wrap(
                            spacing: 6,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                color: cs.primary,
                                onPressed: () {
                                  context.read<FriendsBloc>().add(
                                    AcceptRequest(r.requestId),
                                  ); // accept
                                  context.read<FriendsBloc>().add(
                                    const LoadFriends(),
                                  ); // refresh friends
                                  context.read<FriendsBloc>().add(
                                    const LoadReceived(),
                                  ); // refresh received
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                color: cs.error,
                                onPressed: () {
                                  context.read<FriendsBloc>().add(
                                    RejectRequest(r.requestId),
                                  ); // reject
                                  context.read<FriendsBloc>().add(
                                    const LoadReceived(),
                                  ); // refresh received
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  if (tab == 1) {
                    final list = _filterByName(st.sent, (r) => r.user.fullName);
                    if (list.isEmpty)
                      return Center(child: Text(l10.friendshipNoRequests));
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) => const Divider(height: 0),
                      itemBuilder: (_, i) {
                        final r = list[i];
                        return UserTile(
                          user: r.user, // shows avatar
                          subtitle: l10.friendTab_sent,
                          // friendship_screen.dart (Sent Requests tab button)
                          trailing: IconButton(
                            icon: const Icon(
                              Icons.cancel_outlined,
                            ), // cancel icon
                            color: cs.onSurfaceVariant, // neutral color
                            onPressed: () {
                              final bloc = context
                                  .read<FriendsBloc>(); // get bloc
                              bloc.add(
                                RemoveSentLocal(r.requestId),
                              ); // 1) instant remove
                              showTopToast(
                                // 2) toast now
                                context,
                                (l10.friendCancelled), // "Request cancelled."
                                type: ToastType.success,
                              );
                              bloc.add(
                                CancelRequest(r.requestId),
                              ); // 3) call API
                              bloc.add(const LoadSent()); // 4) optional refresh
                            },
                          ),
                        );
                      },
                    );
                  }

                  // tab == 2
                  final list = _filterByName(st.friends, (u) => u.fullName);
                  if (list.isEmpty)
                    return Center(child: Text(l10.friendshipNoFriends));
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (_, i) {
                      final u = list[i];
                      return UserTile(
                        user: u, // shows avatar
                        subtitle: l10.friendTabFriends,
                        trailing: IconButton(
                          icon: const Icon(Icons.person_remove_alt_1_outlined),
                          color: cs.onSurfaceVariant,
                          onPressed: () {
                            context.read<FriendsBloc>().add(
                              UnfriendUser(u.id),
                            ); // unfriend
                            context.read<FriendsBloc>().add(
                              const LoadFriends(),
                            ); // refresh
                          },
                        ),
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/community/chat',
                            arguments: u,
                          ); // open chat
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Seg extends StatelessWidget {
  final String label; // text
  final bool selected; // selected flag
  final VoidCallback onTap; // tap
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // theme colors
    return Material(
      color: selected ? cs.primary : cs.surface, // bg by state
      borderRadius: BorderRadius.circular(14), // rounded
      child: InkWell(
        borderRadius: BorderRadius.circular(14), // ripple radius
        onTap: onTap, // switch tab
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10), // padding
          child: Center(
            child: Text(
              // label
              label,
              style: TextStyle(color: selected ? cs.onPrimary : cs.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
