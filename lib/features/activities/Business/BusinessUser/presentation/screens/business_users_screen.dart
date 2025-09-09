// ===== Flutter 3.35.x =====
// BusinessUsersScreen — full updated version with Add + Assign functionality
// - Auto-pop back to Insights after assigning
// - Hide users already enrolled in the activity
// - Fixed Add User form
// - Assign dialog lets you set participants + paid/unpaid

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

// Bloc
import '../bloc/business_users_bloc.dart';
import '../bloc/business_users_event.dart';
import '../bloc/business_users_state.dart';

// Domain / Repository / Usecases
import '../../data/repositories/business_users_repository_impl.dart';
import '../../data/services/business_users_service.dart';
import '../../domain/usecases/get_business_users.dart';
import '../../domain/usecases/create_business_user.dart';
import '../../domain/usecases/book_cash.dart';

class BusinessUsersScreen extends StatefulWidget {
  final String token;
  final int businessId;
  final int itemId; // 👈 the activity id to assign users to
  final List<int> enrolledUserIds; // 👈 users already assigned

  const BusinessUsersScreen({
    super.key,
    required this.token,
    required this.businessId,
    required this.itemId,
    this.enrolledUserIds = const [],
  });

  @override
  State<BusinessUsersScreen> createState() => _BusinessUsersScreenState();
}

class _BusinessUsersScreenState extends State<BusinessUsersScreen> {
  String _query = "";

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;
    final tt = Theme.of(context).textTheme;

    return BlocProvider(
      create: (_) {
        final repo = BusinessUsersRepositoryImpl(BusinessUsersService());
        return BusinessUsersBloc(
          getUsers: GetBusinessUsers(repo),
          createUser: CreateBusinessUser(repo),
          bookCash: BookCash(repo),
        )..add(LoadBusinessUsers(widget.token));
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(tr.businessUsersTitle),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_alt_1),
              tooltip: tr.addUser,
              onPressed: () => _showAddUserDialog(context, tr),
            ),
          ],
        ),
        body: Column(
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(12),
              child: AppSearchBar(
                hint: tr.searchPlaceholder,
                onQueryChanged: (q) => setState(() => _query = q),
              ),
            ),
            Expanded(
              child: BlocConsumer<BusinessUsersBloc, BusinessUsersState>(
                listener: (context, state) {
                  if (state is BusinessUserBookingSuccess) {
                    Navigator.pop(context, true); // 👈 return to Insights
                  } else if (state is BusinessUsersError) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text(state.message)));
                  }
                },
                builder: (context, state) {
                  if (state is BusinessUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BusinessUsersLoaded) {
                    var list = state.users;

                    // Remove already enrolled users
                    list = list
                        .where((u) => !widget.enrolledUserIds.contains(u.id))
                        .toList();

                    // Apply search filter
                    if (_query.isNotEmpty) {
                      list = list
                          .where(
                            (u) =>
                                (u.firstname + u.lastname)
                                    .toLowerCase()
                                    .contains(_query.toLowerCase()) ||
                                (u.email ?? "").toLowerCase().contains(
                                  _query.toLowerCase(),
                                ) ||
                                (u.phoneNumber ?? "").toLowerCase().contains(
                                  _query.toLowerCase(),
                                ),
                          )
                          .toList();
                    }

                    if (list.isEmpty) {
                      return Center(
                        child: Text(
                          tr.noAvailableUsers,
                          style: tt.bodyMedium?.copyWith(
                            color: cs.onSurfaceVariant,
                          ),
                        ),
                      );
                    }

                    return ListView.separated(
                      itemCount: list.length,
                      separatorBuilder: (_, __) =>
                          Divider(color: cs.outlineVariant, thickness: 0.8),
                      itemBuilder: (_, i) {
                        final u = list[i];
                        return Card(
                          margin: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: const EdgeInsets.all(12),
                            leading: CircleAvatar(
                              backgroundColor: cs.primary.withOpacity(0.15),
                              child: Icon(Icons.person, color: cs.primary),
                            ),
                            title: Text(
                              "${u.firstname} ${u.lastname}",
                              style: tt.titleMedium,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (u.email != null)
                                  Text(u.email!, style: tt.bodySmall),
                                if (u.phoneNumber != null)
                                  Text(u.phoneNumber!, style: tt.bodySmall),
                              ],
                            ),
                            trailing: SizedBox(
                              width: 140,
                              child: AppButton(
                                label: tr.assignToActivity,
                                type: AppButtonType.outline,
                                onPressed: () =>
                                    _showAssignDialog(context, u.id),
                              ),
                            ),
                          ),
                        );
                      },
                    );
                  } else if (state is BusinessUsersError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: tt.bodyMedium?.copyWith(color: AppColors.error),
                      ),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.person_add_alt_1),
          label: Text(tr.addUser),
          onPressed: () => _showAddUserDialog(context, tr),
        ),
      ),
    );
  }

  /// Dialog to add new business user (either by email OR phone)
  void _showAddUserDialog(BuildContext context, AppLocalizations tr) {
    final parentContext = context; // 👈 capture the bloc-aware context

    final firstCtrl = TextEditingController();
    final lastCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    bool usePhone = false;

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(tr.addUser),
              content: SingleChildScrollView(
                child: Column(
                  children: [
                    TextField(
                      controller: firstCtrl,
                      decoration: InputDecoration(labelText: tr.firstName),
                    ),
                    TextField(
                      controller: lastCtrl,
                      decoration: InputDecoration(labelText: tr.lastName),
                    ),
                    SwitchListTile(
                      title: Text(usePhone ? tr.phoneNumber : tr.email),
                      value: usePhone,
                      onChanged: (val) => setLocal(() => usePhone = val),
                    ),
                    if (usePhone)
                      TextField(
                        controller: phoneCtrl,
                        decoration: InputDecoration(labelText: tr.phoneNumber),
                        keyboardType: TextInputType.phone,
                      )
                    else
                      TextField(
                        controller: emailCtrl,
                        decoration: InputDecoration(labelText: tr.email),
                        keyboardType: TextInputType.emailAddress,
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr.cancel),
                ),
                AppButton(
                  label: tr.save,
                  onPressed: () {
                    final first = firstCtrl.text.trim();
                    final last = lastCtrl.text.trim();
                    final email = emailCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();

                    if (first.isEmpty || last.isEmpty) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text(tr.bookingErrorFailed)),
                      );
                      return;
                    }
                    if (!usePhone && email.isEmpty ||
                        usePhone && phone.isEmpty) {
                      ScaffoldMessenger.of(parentContext).showSnackBar(
                        SnackBar(content: Text(tr.bookingErrorFailed)),
                      );
                      return;
                    }

                    // 👇 use parentContext here
                    BlocProvider.of<BusinessUsersBloc>(parentContext).add(
                      CreateBusinessUserEvent(
                        token: widget.token,
                        firstname: first,
                        lastname: last,
                        email: !usePhone ? email : null,
                        phoneNumber: usePhone ? phone : null,
                      ),
                    );

                    Navigator.pop(ctx);
                  },
                  type: AppButtonType.primary,
                ),
              ],
            );
          },
        );
      },
    );
  }

  /// Dialog to assign user with participants + paid toggle
  void _showAssignDialog(BuildContext context, int userId) async {
    final tr = AppLocalizations.of(context)!;
    final participantsCtrl = TextEditingController(text: "1");
    bool wasPaid = false;

    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setLocal) {
            return AlertDialog(
              title: Text(tr.assignToActivity),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: participantsCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: tr.bookingParticipants,
                    ),
                  ),
                  SwitchListTile(
                    title: Text(tr.paid),
                    value: wasPaid,
                    onChanged: (val) => setLocal(() => wasPaid = val),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: Text(tr.cancel),
                ),
                AppButton(
                  label: tr.save,
                  type: AppButtonType.primary,
                  onPressed: () {
                    Navigator.pop(ctx, {
                      "participants": int.tryParse(participantsCtrl.text) ?? 1,
                      "wasPaid": wasPaid,
                    });
                  },
                ),
              ],
            );
          },
        );
      },
    );

    if (result != null) {
      context.read<BusinessUsersBloc>().add(
        BookCashEvent(
          token: widget.token,
          itemId: widget.itemId,
          businessUserId: userId,
          participants: result["participants"],
          wasPaid: result["wasPaid"],
        ),
      );
    }
  }
}
