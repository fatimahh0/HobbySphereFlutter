import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart'; // user
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_bloc.dart'; // bloc
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_event.dart'; // events
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_state.dart'; // state
import 'package:hobby_sphere/features/activities/user/social/presentation/widgets/user_tile.dart'; // row
import 'package:hobby_sphere/features/activities/user/social/presentation/screens/friendship_screen.dart'; // screen
import 'package:hobby_sphere/l10n/app_localizations.dart'; // l10n
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

class AddFriendScreen extends StatefulWidget {
  final int meId; // current user id (to hide myself)
  const AddFriendScreen({super.key, required this.meId});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  int tab = 0; // 0 all / 1 suggested
  String query = ''; // search text

  // keep local ids to hide instantly after "Add" tap (optimistic)
  final Set<int> _optimisticHidden = <int>{}; // temp hidden ids

  @override
  void initState() {
    super.initState(); // life-cycle
    final b = context.read<FriendsBloc>(); // get bloc
    b.add(const LoadAllUsers()); // load "all" users
    b.add(LoadSuggested(widget.meId)); // load "suggested"
    b.add(const LoadSent()); // load "sent" to compute hides
  }

  // filter by search (case-insensitive)
  List<UserMin> _byQuery(List<UserMin> list) {
    final q = query.trim().toLowerCase(); // normalize
    if (q.isEmpty) return list; // nothing to filter
    return list.where((u) => u.fullName.toLowerCase().contains(q)).toList();
  }

  // build a final list that excludes: me, friends, sent-to, received-from, and optimistic hidden
  List<UserMin> _candidates(FriendsState st, List<UserMin> source) {
    // collect ids of relations
    final me = widget.meId; // my id
    final friendIds = st.friends.map((u) => u.id).toSet(); // current friends
    final sentIds = st.sent.map((r) => r.user.id).toSet(); // already sent
    final recvIds = st.received
        .map((r) => r.user.id)
        .toSet(); // pending incoming
    final hide = {..._optimisticHidden}; // local optimistic hides

    // keep only users not in any set above
    final clean = source.where((u) {
      if (u.id == me) return false; // hide myself
      if (friendIds.contains(u.id)) return false; // hide friends
      if (sentIds.contains(u.id)) return false; // hide already sent
      if (recvIds.contains(u.id)) return false; // hide already received
      if (hide.contains(u.id)) return false; // hide local optimistic
      return true; // show otherwise
    }).toList();

    return _byQuery(clean); // apply search last
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!; // i18n
    final cs = Theme.of(context).colorScheme; // theme colors

    return Scaffold(
      appBar: AppBar(
        title: Text(''), // title text
        actions: [
          PopupMenuButton<int>(
            // quick jump menu
            onSelected: (v) {
              final bloc = context.read<FriendsBloc>(); // same bloc
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc, // reuse friends bloc
                        child: FriendshipScreen(
                          initialTab: v == 0 ? 1 : (v == 1 ? 0 : 2), // map
                        ),
                      ),
                    ),
                  )
                  .then((_) {
                    // after returning, refresh lists
                    bloc.add(const LoadAllUsers()); // refresh all
                    bloc.add(LoadSuggested(widget.meId)); // refresh suggested
                    bloc.add(const LoadSent()); // refresh sent
                  });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 0,
                child: Text(l10.friendshipAddFriendViewSent),
              ), // go Sent
              PopupMenuItem(
                value: 1,
                child: Text(l10.friendshipAddFriendViewReceived),
              ), // go Received
              PopupMenuItem(
                value: 2,
                child: Text(l10.friendshipAddFriendViewFriends),
              ), // go Friends
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // search box
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), // inset
              child: TextField(
                onChanged: (v) => setState(() => query = v), // update search
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search), // icon
                  hintText: l10.friendshipAddFriendSearchPlaceholder, // hint
                  filled: true, // filled style
                  fillColor: cs.surface, // bg color
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28), // round
                    borderSide: BorderSide.none, // no border
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ), // height
                ),
              ),
            ),

            // tabs for All / Suggested
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16), // inset
              child: Row(
                children: [
                  Expanded(
                    child: _Segment(
                      label: l10.friendshipAddFriendAll, // label
                      selected: tab == 0, // active?
                      onTap: () => setState(() => tab = 0), // switch
                    ),
                  ),
                  const SizedBox(width: 10), // space
                  Expanded(
                    child: _Segment(
                      label: l10.friendshipAddFriendSuggested, // label
                      selected: tab == 1, // active?
                      onTap: () => setState(() => tab = 1), // switch
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8), // gap
            // lists body
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (ctx, st) {
                  final src = tab == 0 ? st.all : st.suggested; // choose source
                  final list = _candidates(st, src); // cleaned + searched

                  if (st.isLoading && list.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // spinner
                  }
                  if (list.isEmpty) {
                    return Center(
                      child: Text(l10.friendshipAddFriendNoUsers),
                    ); // empty
                  }

                  return ListView.separated(
                    itemCount: list.length, // rows count
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0), // divider
                    itemBuilder: (_, i) {
                      final u = list[i]; // one user

                      // tap handler to add (with optimistic hide)
                      void _send() {
                        // 1) optimistic: hide immediately
                        setState(() => _optimisticHidden.add(u.id)); // hide now
                        // 2) show success toast
                        showTopToast(
                          context,
                          l10.friendshipRequestSent,
                          type: ToastType.success,
                        );
                        // 3) dispatch real send request
                        final bloc = context.read<FriendsBloc>(); // bloc
                        bloc.add(SendRequest(u.id)); // server call
                        // 4) light re-sync (optional but safe)
                        bloc.add(const LoadSent()); // refresh "sent"
                        // 5) optionally refresh All/Suggested in background
                        bloc.add(const LoadAllUsers()); // refresh "all"
                        bloc.add(
                          LoadSuggested(widget.meId),
                        ); // refresh "suggested"
                      }

                      return UserTile(
                        user: u, // shows avatar + name
                        subtitle: l10.friendshipAddFriendAvailable, // hint
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.person_add_alt_1_rounded,
                          ), // add icon
                          color: cs.primary, // brand color
                          onPressed: _send, // send flow
                        ),
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

// small segmented button
class _Segment extends StatelessWidget {
  final String label; // text
  final bool selected; // state
  final VoidCallback onTap; // tap
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return Material(
      color: selected ? cs.primary : cs.surface, // bg by state
      borderRadius: BorderRadius.circular(14), // rounded
      child: InkWell(
        borderRadius: BorderRadius.circular(14), // ripple radius
        onTap: onTap, // switch
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10), // padding
          child: Center(
            child: Text(
              label, // text
              style: TextStyle(
                color: selected ? cs.onPrimary : cs.onSurface,
              ), // color
            ),
          ),
        ),
      ),
    );
  }
}
