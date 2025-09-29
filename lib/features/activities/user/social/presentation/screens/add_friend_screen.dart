import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/app/bootstrap/start_user_realtime.dart' as rt;
import 'package:hobby_sphere/core/realtime/user_realtime_bridge.dart'
    show Remover;
import 'package:hobby_sphere/features/activities/user/social/domain/entities/user_min.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_bloc.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_event.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/bloc/friends/friends_state.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/widgets/user_tile.dart';
import 'package:hobby_sphere/features/activities/user/social/presentation/screens/friendship_screen.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

class AddFriendScreen extends StatefulWidget {
  final int meId;
  const AddFriendScreen({super.key, required this.meId});

  @override
  State<AddFriendScreen> createState() => _AddFriendScreenState();
}

class _AddFriendScreenState extends State<AddFriendScreen> {
  int tab = 0;
  String query = '';
  final Set<int> _optimisticHidden = <int>{};

  late final Remover _rmFrUp;

  @override
  void initState() {
    super.initState();
    final b = context.read<FriendsBloc>();
    b.add(const LoadAllUsers());
    b.add(LoadSuggested(widget.meId));
    b.add(const LoadSent());

    // realtime: any friendship update → resync lists
    _rmFrUp = rt.userBridge.onFriendshipUpdatedListen((_) {
      final bloc = context.read<FriendsBloc>();
      bloc.add(const LoadAllUsers());
      bloc.add(LoadSuggested(widget.meId));
      bloc.add(const LoadSent());
    });
  }

  @override
  void dispose() {
    _rmFrUp();
    super.dispose();
  }

  List<UserMin> _byQuery(List<UserMin> list) {
    final q = query.trim().toLowerCase();
    if (q.isEmpty) return list;
    return list.where((u) => u.fullName.toLowerCase().contains(q)).toList();
  }

  List<UserMin> _candidates(FriendsState st, List<UserMin> source) {
    final me = widget.meId;
    final friendIds = st.friends.map((u) => u.id).toSet();
    final sentIds = st.sent.map((r) => r.user.id).toSet();
    final recvIds = st.received.map((r) => r.user.id).toSet();
    final hide = {..._optimisticHidden};

    final clean = source.where((u) {
      if (u.id == me) return false;
      if (friendIds.contains(u.id)) return false;
      if (sentIds.contains(u.id)) return false;
      if (recvIds.contains(u.id)) return false;
      if (hide.contains(u.id)) return false;
      return true;
    }).toList();

    return _byQuery(clean);
  }

  @override
  Widget build(BuildContext context) {
    final l10 = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        actions: [
          PopupMenuButton<int>(
            onSelected: (v) {
              final bloc = context.read<FriendsBloc>();
              Navigator.of(context)
                  .push(
                    MaterialPageRoute(
                      builder: (_) => BlocProvider.value(
                        value: bloc,
                        child: FriendshipScreen(
                          initialTab: v == 0 ? 1 : (v == 1 ? 0 : 2),
                        ),
                      ),
                    ),
                  )
                  .then((_) {
                    bloc.add(const LoadAllUsers());
                    bloc.add(LoadSuggested(widget.meId));
                    bloc.add(const LoadSent());
                  });
            },
            itemBuilder: (_) => [
              PopupMenuItem(
                value: 0,
                child: Text(l10.friendshipAddFriendViewSent),
              ),
              PopupMenuItem(
                value: 1,
                child: Text(l10.friendshipAddFriendViewReceived),
              ),
              PopupMenuItem(
                value: 2,
                child: Text(l10.friendshipAddFriendViewFriends),
              ),
            ],
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                onChanged: (v) => setState(() => query = v),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.search),
                  hintText: l10.friendshipAddFriendSearchPlaceholder,
                  filled: true,
                  fillColor: cs.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(28),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: _Segment(
                      label: l10.friendshipAddFriendAll,
                      selected: tab == 0,
                      onTap: () => setState(() => tab = 0),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _Segment(
                      label: l10.friendshipAddFriendSuggested,
                      selected: tab == 1,
                      onTap: () => setState(() => tab = 1),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: BlocBuilder<FriendsBloc, FriendsState>(
                builder: (ctx, st) {
                  final src = tab == 0 ? st.all : st.suggested;
                  final list = _candidates(st, src);

                  if (st.isLoading && list.isEmpty) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (list.isEmpty) {
                    return Center(child: Text(l10.friendshipAddFriendNoUsers));
                  }

                  return ListView.separated(
                    itemCount: list.length,
                    separatorBuilder: (_, __) => const Divider(height: 0),
                    itemBuilder: (_, i) {
                      final u = list[i];
                      void _send() {
                        setState(() => _optimisticHidden.add(u.id));
                        showTopToast(
                          context,
                          l10.friendshipRequestSent,
                          type: ToastType.success,
                        );
                        final bloc = context.read<FriendsBloc>();
                        bloc.add(SendRequest(u.id));
                        bloc.add(const LoadSent());
                        bloc.add(const LoadAllUsers());
                        bloc.add(LoadSuggested(widget.meId));
                      }

                      return UserTile(
                        user: u,
                        subtitle: l10.friendshipAddFriendAvailable,
                        trailing: IconButton(
                          icon: const Icon(Icons.person_add_alt_1_rounded),
                          color: cs.primary,
                          onPressed: _send,
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

class _Segment extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _Segment({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Material(
      color: selected ? cs.primary : cs.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Center(
            child: Text(
              label,
              style: TextStyle(color: selected ? cs.onPrimary : cs.onSurface),
            ),
          ),
        ),
      ),
    );
  }
}
