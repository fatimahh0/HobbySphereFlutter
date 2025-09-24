import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_event.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_state.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/widgets/user_tile.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

import 'add_friend_screen.dart';

// Chat home shows your friends (contacts) + FAB to "Add Friend".
class ChatHomeScreen extends StatefulWidget {
  final int meId; // used by AddFriendScreen suggestions
  const ChatHomeScreen({super.key, required this.meId});

  @override
  State<ChatHomeScreen> createState() => _ChatHomeScreenState();
}

class _ChatHomeScreenState extends State<ChatHomeScreen> {
  String q = ''; // search

  @override
  void initState() {
    super.initState();
    context.read<FriendsBloc>().add(
      const LoadFriends(),
    ); // load friend contacts
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text('')), // keep simple
      // chat_home_screen.dart (only the FAB changed)

floatingActionButton: FloatingActionButton(
  onPressed: () {
    final bloc = context.read<FriendsBloc>();                    // current bloc
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider.value(                      // reuse bloc
          value: bloc,
          child: AddFriendScreen(meId: widget.meId),
        ),
      ),
    ).then((_) {
      // when AddFriend closes → refresh my friends
      bloc.add(const LoadFriends());
    });
  },
  child: const Icon(Icons.person_add_alt_1_rounded),
),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => q = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10.friendshipAddFriendSearchPlaceholder,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (_, st) {
                  if (st.isLoading && st.friends.isEmpty)
                    return const Center(child: CircularProgressIndicator());
                  final list = q.trim().isEmpty
                      ? st.friends
                      : st.friends
                            .where(
                              (u) => u.fullName.toLowerCase().contains(
                                q.toLowerCase(),
                              ),
                            )
                            .toList();

                  if (list.isEmpty)
                    return Center(
                      child: Text(l10.friendNoFriends),
                    ); // empty state

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (_, i) {
                      final u = list[i];
                      return UserTile(
                        user: u,
                        subtitle: l10.friendChat, // small "Chat"
                        onTap: () {
                          Navigator.of(context).pushNamed(
                            '/community/chat',
                            arguments: u,
                          ); // go to conversation
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
