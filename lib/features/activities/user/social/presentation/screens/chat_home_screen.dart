// 🏠 Chat home: friend contacts list + goto AddFriend + realtime refresh.
import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart'
    as rt; // realtime
import 'package:hobby_sphere/core/realtime/user_realtime_bridge.dart'
    show Remover; // remover type
import '../bloc/friends/friends_bloc.dart'; // bloc
import '../bloc/friends/friends_event.dart'; // events
import '../bloc/friends/friends_state.dart'; // state
import '../widgets/user_tile.dart'; // row
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'add_friend_screen.dart'; // add screen

class ChatHomeScreen extends StatefulWidget {
  final int meId; // my id for suggestions
  const ChatHomeScreen({super.key, required this.meId}); // ctor

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState(); // state
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  String q = ''; // search
  late final Remover _rmFrC, _rmFrU, _rmFrD; // realtime removers

  @override
  void initState() {
    super.initState(); // start
    final b = context.read<FriendsBloc>(); // bloc
    b.add(const LoadFriends()); // load friends
    _rmFrC = rt.userBridge.onFriendshipCreatedListen(
      (_) => b.add(const LoadFriends()),
    ); // refresh
    _rmFrU = rt.userBridge.onFriendshipUpdatedListen(
      (_) => b.add(const LoadFriends()),
    ); // refresh
    _rmFrD = rt.userBridge.onFriendshipDeletedListen(
      (_) => b.add(const LoadFriends()),
    ); // refresh
  }

  @override
  void dispose() {
    _rmFrC();
    _rmFrU();
    _rmFrD(); // stop listeners
    super.dispose(); // end
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!; // i18n

    return Scaffold(
      appBar: AppBar(title: Text('')), // minimal
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final bloc = context.read<FriendsBloc>(); // same bloc
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc,
                    child: AddFriendScreen(meId: widget.meId),
                  ),
                ),
              ) // open add
              .then((_) => bloc.add(const LoadFriends())); // refresh on back
        },
        child: const Icon(Icons.person_add_alt_1_rounded), // icon
      ),
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
                  filled: true, // filled
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ), // style
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ), // height
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (_, st) {
                  if (st.isLoading && st.friends.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // spinner
                  }
                  final list = q.trim().isEmpty
                      ? st
                            .friends // all
                      : st.friends
                            .where(
                              (u) => u.fullName.toLowerCase().contains(
                                q.toLowerCase(),
                              ),
                            )
                            .toList(); // filter
                  if (list.isEmpty)
                    return Center(child: Text(l10.friendNoFriends)); // empty

                  return ListView.separated(
                    itemCount: list.length, // count
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0), // divider
                    itemBuilder: (_, i) {
                      final u = list[i]; // user
                      return UserTile(
                        user: u, // avatar + name
                        subtitle: l10.friendChat, // hint
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
