import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

import '../../data/repositories/manager_invite_repository_impl.dart';
import '../../data/services/manager_invite_service.dart';
import '../../domain/usecases/send_manager_invite.dart';
import '../bloc/invite_manager_bloc.dart';
import '../widgets/invite_manager_form.dart';

class InviteManagerRouteArgs {
  final String token;
  final int businessId;
  const InviteManagerRouteArgs({required this.token, required this.businessId});
}

class InviteManagerScreen extends StatelessWidget {
  final String token;
  final int businessId;

  const InviteManagerScreen({
    super.key,
    required this.token,
    required this.businessId,
  });

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;

    return BlocProvider(
      create: (_) => InviteManagerBloc(
        sendInvite: SendManagerInvite(
          ManagerInviteRepositoryImpl(service: ManagerInviteService()),
        ),
      ),
      child: Scaffold(
        appBar: AppBar(),
        body: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 18),
          child: InviteManagerForm(token: token, businessId: businessId),
        ),
      ),
    );
  }
}
