// 🏠 Chat home: friend contacts + Add Friend + realtime refresh.
// Flutter 3.35.x — simple, clean, every line commented.

import 'package:flutter/material.dart'; // ui
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart'
    as rt; // realtime bridge
import 'package:hobby_sphere/app/router/router.dart';
import 'package:hobby_sphere/core/realtime/user_realtime_bridge.dart'
    show Remover; // remover typedef
import '../bloc/friends/friends_bloc.dart'; // friends bloc
import '../bloc/friends/friends_event.dart'; // friends events
import '../bloc/friends/friends_state.dart'; // friends state
import '../widgets/user_tile.dart'; // friend row tile
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

import 'add_friend_screen.dart'; // add friends page

class ChatHomeScreen extends StatefulWidget {
  final int meId; // my user id (needed for opening a conversation)
  const ChatHomeScreen({super.key, required this.meId}); // ctor

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState(); // state
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  String q = ''; // search query
  late final Remover _rmFrC, _rmFrU, _rmFrD; // realtime unsubs

  @override
  void initState() {
    super.initState(); // lifecycle
    final b = context.read<FriendsBloc>(); // get bloc
    b.add(const LoadFriends()); // initial load
    // subscribe to realtime changes and reload list each time
    _rmFrC = rt.userBridge.onFriendshipCreatedListen(
      (_) => b.add(const LoadFriends()),
    );
    _rmFrU = rt.userBridge.onFriendshipUpdatedListen(
      (_) => b.add(const LoadFriends()),
    );
    _rmFrD = rt.userBridge.onFriendshipDeletedListen(
      (_) => b.add(const LoadFriends()),
    );
  }

  @override
  void dispose() {
    // stop realtime listeners
    _rmFrC();
    _rmFrU();
    _rmFrD();
    super.dispose(); // lifecycle
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!; // localization

    return Scaffold(
      appBar: AppBar(
        title: Text(l10.friendshipTitle), // simple title
        centerTitle: false, // left aligned
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final bloc = context.read<FriendsBloc>(); // reuse same bloc
          Navigator.of(context)
              .push(
                MaterialPageRoute(
                  builder: (_) => BlocProvider.value(
                    value: bloc, // pass same instance
                    child: AddFriendScreen(
                      meId: widget.meId,
                    ), // open add friend
                  ),
                ),
              )
              .then((_) => bloc.add(const LoadFriends())); // refresh on back
        },
        child: const Icon(Icons.person_add_alt_1_rounded), // FAB icon
      ),
      body: SafeArea(
        child: Column(
          children: [
            // search field
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8), // spacing
              child: TextField(
                onChanged: (v) => setState(() => q = v), // update query
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search), // icon
                  hintText: l10.friendshipAddFriendSearchPlaceholder, // hint
                  filled: true, // filled bg
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28), // rounded
                    borderSide: BorderSide.none, // no line
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                  ), // height
                ),
              ),
            ),
            // friends list
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (_, st) {
                  if (st.isLoading && st.friends.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    ); // first load
                  }

                  // filter by search query (case-insensitive)
                  final list = q.trim().isEmpty
                      ? st.friends
                      : st.friends
                            .where(
                              (u) => u.fullName.toLowerCase().contains(
                                q.toLowerCase(),
                              ),
                            )
                            .toList();

                  if (list.isEmpty) {
                    return Center(
                      child: Text(l10.friendNoFriends),
                    ); // empty state
                  }

                  return ListView.separated(
                    itemCount: list.length, // rows count
                    separatorBuilder: (_, __) =>
                        const Divider(height: 0), // thin divider
                    itemBuilder: (_, i) {
                      final u = list[i]; // friend item
                      return UserTile(
                        user: u, // avatar + name
                        subtitle: l10.friendChat, // small hint
                        onTap: () {
                          // ✅ open conversation and PASS myId + peer together
                          Navigator.of(context).pushNamed(
                            Routes.friendship, // route name
                            arguments: ConversationRouteArgs(
                              myId: widget
                                  .meId, // my user id (needed by ChatBloc)
                              peer: u, // the contact to chat with
                            ),
                          );
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
