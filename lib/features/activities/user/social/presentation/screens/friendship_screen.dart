// 📋 Friendship hub: Received / Sent / Friends + realtime refresh.
import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart'
    as rt; // realtime
import 'package:hobby_sphere/core/realtime/user_realtime_bridge.dart'
    show Remover; // remover
import '../widgets/user_tile.dart'; // tile
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import '../bloc/friends/friends_bloc.dart'; // bloc
import '../bloc/friends/friends_event.dart'; // events
import '../bloc/friends/friends_state.dart'; // state

class FriendshipScreen extends StatefulWidget {
  final int initialTab; // 0 rec / 1 sent / 2 friends
  const FriendshipScreen({super.key, this.initialTab = 0}); // ctor

  @override
  State<FriendshipScreen> createState() => _FriendshipScreenState(); // state
}

class _FriendshipScreenState extends State<FriendshipScreen> {
  late int tab; // current
  String q = ''; // search
  late final Remover _rmFrR; // realtime remover

  @override
  void initState() {
    super.initState(); // start
    tab = widget.initialTab; // set tab
    final b = context.read<FriendsBloc>(); // bloc
    b.add(const LoadReceived()); // load rec
    b.add(const LoadSent()); // load sent
    b.add(const LoadFriends()); // load friends

    _rmFrR = rt.userBridge.onFriendshipUpdatedListen((_) {
      // realtime
      final bloc = context.read<FriendsBloc>(); // bloc
      bloc.add(const LoadReceived()); // refresh rec
      bloc.add(const LoadSent()); // refresh sent
      bloc.add(const LoadFriends()); // refresh friends
    });
  }

  @override
  void dispose() {
    _rmFrR(); // stop
    super.dispose(); // end
  }

  List<T> _filterByName<T>(List<T> src, String Function(T) getter) {
    final s = q.trim().toLowerCase(); // norm
    if (s.isEmpty) return src; // no filter
    return src
        .where((e) => getter(e).toLowerCase().contains(s))
        .toList(); // filtered
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // colors

    return Scaffold(
      appBar: AppBar(title: Text('')), // clean
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), // space
              child: TextField(
                onChanged: (v) => setState(() => q = v), // search
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search), // icon
                  hintText: l10.friendshipAddFriendSearchPlaceholder, // hint
                  filled: true,
                  fillColor: cs.surface, // style
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ), // shape
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ), // height
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // space
              child: Row(
                children: [
                  Expanded(
                    child: _Seg(
                      label: l10.friendshipReceivedRequests,
                      selected: tab == 0,
                      onTap: () => setState(() => tab = 0),
                    ),
                  ), // rec
                  const SizedBox(width: 8), // gap
                  Expanded(
                    child: _Seg(
                      label: l10.friendshipSentRequests,
                      selected: tab == 1,
                      onTap: () => setState(() => tab = 1),
                    ),
                  ), // sent
                  const SizedBox(width: 8), // gap
                  Expanded(
                    child: _Seg(
                      label: l10.friendshipMyFriends,
                      selected: tab == 2,
                      onTap: () => setState(() => tab = 2),
                    ),
                  ), // friends
                ],
              ),
            ),
            const SizedBox(height: 8), // gap
            Expanded(
              child: BlocConsumer<FriendsBloc, FriendsState>(
                listener: (ctx, st) {
                  if (st.error != null && st.error!.isNotEmpty) {
                    showTopToast(
                      context,
                      l10.friendshipErrorFailedAction,
                      type: ToastType.error,
                    ); // toast
                  }
                },
                builder: (ctx, st) {
                  final loadingAll =
                      st.isLoading &&
                      st.received.isEmpty &&
                      st.sent.isEmpty &&
                      st.friends.isEmpty; // first load
                  if (loadingAll)
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // spinner

                  if (tab == 0) {
                    final list = _filterByName(
                      st.received,
                      (r) => r.user.fullName,
                    ); // filter rec
                    if (list.isEmpty)
                      return Center(
                        child: Text(l10.friendshipNoRequests),
                      ); // empty
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 0), // divider
                      itemBuilder: (_, i) {
                        final r = list[i]; // row
                        return UserTile(
                          user: r.user, // avatar + name
                          subtitle: l10.friendTab_received, // hint
                          trailing: Wrap(
                            spacing: 6, // gap
                            children: [
                              IconButton(
                                icon: const Icon(Icons.check_circle_outline),
                                color: cs.primary, // accept
                                onPressed: () {
                                  final b = context.read<FriendsBloc>(); // bloc
                                  b.add(AcceptRequest(r.requestId)); // accept
                                  b.add(const LoadFriends()); // refresh
                                  b.add(const LoadReceived()); // refresh
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.close_rounded),
                                color: cs.error, // reject
                                onPressed: () {
                                  final b = context.read<FriendsBloc>(); // bloc
                                  b.add(RejectRequest(r.requestId)); // reject
                                  b.add(const LoadReceived()); // refresh
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    );
                  }

                  if (tab == 1) {
                    final list = _filterByName(
                      st.sent,
                      (r) => r.user.fullName,
                    ); // sent
                    if (list.isEmpty)
                      return Center(
                        child: Text(l10.friendshipNoRequests),
                      ); // empty
                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 0), // divider
                      itemBuilder: (_, i) {
                        final r = list[i]; // row
                        return UserTile(
                          user: r.user, // avatar
                          subtitle: l10.friendTab_sent, // hint
                          trailing: IconButton(
                            icon: const Icon(Icons.cancel_outlined),
                            color: cs.onSurfaceVariant, // cancel
                            onPressed: () {
                              final bloc = context.read<FriendsBloc>(); // bloc
                              bloc.add(
                                RemoveSentLocal(r.requestId),
                              ); // optimistic remove
                              bloc.add(
                                CancelRequest(r.requestId),
                              ); // server cancel (by requestId)
                              bloc.add(const LoadSent()); // refresh
                            },
                          ),
                        );
                      },
                    );
                  }

                  final list = _filterByName(
                    st.friends,
                    (u) => u.fullName,
                  ); // friends
                  if (list.isEmpty)
                    return Center(
                      child: Text(l10.friendshipNoFriends),
                    ); // empty
                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0), // divider
                    itemBuilder: (_, i) {
                      final u = list[i]; // row
                      return UserTile(
                        user: u, // avatar
                        subtitle: l10.friendTabFriends, // hint
                        trailing: IconButton(
                          icon: const Icon(Icons.person_remove_alt_1_outlined),
                          color: cs.onSurfaceVariant, // unfriend
                          onPressed: () {
                            final b = context.read<FriendsBloc>(); // bloc
                            b.add(UnfriendUser(u.id)); // unfriend
                            b.add(const LoadFriends()); // refresh
                          },
                        ),
                        onTap: () => Navigator.of(context).pushNamed(
                          '/community/chat',
                          arguments: u,
                        ), // open chat
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
  final bool selected; // state
  final VoidCallback onTap; // tap
  const _Seg({
    required this.label,
    required this.selected,
    required this.onTap,
  }); // ctor

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return Material(
      color: selected ? cs.primary : cs.surface, // bg
      borderRadius: BorderRadius.circular(14), // round
      child: InkWell(
        borderRadius: BorderRadius.circular(14), // ripple
        onTap: onTap, // change
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10), // pad
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: selected ? cs.onPrimary : cs.onSurface),
            ),
          ), // text
        ),
      ),
    );
  }
}
