// ===== Flutter 3.35.x =====
// BusinessUsersScreen — professional UI with add + assign actions

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/activities/Business/BusinessUser/domain/usecases/book_cash.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/app_search_bar.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

import '../bloc/business_users_bloc.dart';
import '../bloc/business_users_event.dart';
import '../bloc/business_users_state.dart';
import '../../data/repositories/business_users_repository_impl.dart';
import '../../data/services/business_users_service.dart';
import '../../domain/usecases/get_business_users.dart';
import '../../domain/usecases/create_business_user.dart';

class BusinessUsersScreen extends StatefulWidget {
  final String token;
  final int businessId;

  const BusinessUsersScreen({
    super.key,
    required this.token,
    required this.businessId,
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
        appBar: AppBar(title: Text(tr.businessUsersTitle), centerTitle: true),
        floatingActionButton: FloatingActionButton.extended(
          icon: const Icon(Icons.person_add_alt_1),
          label: Text(tr.addUser),
          onPressed: () => _showAddUserDialog(context, tr),
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: AppSearchBar(
                hint: tr.searchPlaceholder,
                onQueryChanged: (q) => setState(() => _query = q),
              ),
            ),
            Expanded(
              child: BlocBuilder<BusinessUsersBloc, BusinessUsersState>(
                builder: (context, state) {
                  if (state is BusinessUsersLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is BusinessUsersLoaded) {
                    var list = state.users;

                    // apply search filter
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
                          child: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      backgroundColor: cs.primary.withOpacity(
                                        0.15,
                                      ),
                                      child: Icon(
                                        Icons.person,
                                        color: cs.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "${u.firstname} ${u.lastname}",
                                            style: tt.titleMedium,
                                          ),
                                          if (u.email != null)
                                            Text(u.email!, style: tt.bodySmall),
                                          if (u.phoneNumber != null)
                                            Text(
                                              u.phoneNumber!,
                                              style: tt.bodySmall,
                                            ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                AppButton(
                                  label: tr.assignToActivity,
                                  type: AppButtonType.outline,
                                  onPressed: () {
                                    _showAssignDialog(context, tr, u.id);
                                  },
                                ),
                              ],
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
      ),
    );
  }

  /// Dialog to add new BusinessUser (by email or phone)
  void _showAddUserDialog(BuildContext context, AppLocalizations tr) {
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
                    if (!usePhone && emailCtrl.text.isEmpty ||
                        usePhone && phoneCtrl.text.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text(tr.bookingErrorFailed)),
                      );
                      return;
                    }
                    context.read<BusinessUsersBloc>().add(
                      CreateBusinessUserEvent(
                        token: widget.token,
                        firstname: firstCtrl.text,
                        lastname: lastCtrl.text,
                        email: !usePhone ? emailCtrl.text : null,
                        phoneNumber: usePhone ? phoneCtrl.text : null,
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

  /// Dialog to manually assign BusinessUser to an activity (bookCash)
  void _showAssignDialog(
    BuildContext context,
    AppLocalizations tr,
    int businessUserId,
  ) {
    final participantsCtrl = TextEditingController(text: "1");
    bool wasPaid = false;
    final itemIdCtrl = TextEditingController();

    showDialog(
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
                    decoration: const InputDecoration(
                      labelText: "Participants",
                    ),
                    keyboardType: TextInputType.number,
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
                  label: tr.confirm,
                  onPressed: () {
                    context.read<BusinessUsersBloc>().add(
                      BookCashEvent(
                        token: widget.token,
                        itemId: int.tryParse(itemIdCtrl.text) ?? 0,
                        businessUserId: businessUserId,
                        participants: int.tryParse(participantsCtrl.text) ?? 1,
                        wasPaid: wasPaid,
                      ),
                    );
                    Navigator.pop(ctx);
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }
}
