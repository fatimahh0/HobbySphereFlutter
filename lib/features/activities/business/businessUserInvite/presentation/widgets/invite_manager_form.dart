import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import '../bloc/invite_manager_bloc.dart';
import '../bloc/invite_manager_event.dart';
import '../bloc/invite_manager_state.dart';

class InviteManagerForm extends StatefulWidget {
  final String token;
  final int businessId;

  const InviteManagerForm({
    super.key,
    required this.token,
    required this.businessId,
  });

  @override
  State<InviteManagerForm> createState() => _InviteManagerFormState();
}

class _InviteManagerFormState extends State<InviteManagerForm> {
  final _emailCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return BlocConsumer<InviteManagerBloc, InviteManagerState>(
      listenWhen: (a, b) =>
          a.successMessage != b.successMessage || a.error != b.error,
      listener: (context, state) {
        if (state.successMessage != null) {
          showTopToast(
            context,
            state.successMessage!,
            type: ToastType.success,
            haptics: true,
          );
        }
        if (state.error != null) {
          showTopToast(
            context,
            state.error!,
            type: ToastType.error,
            haptics: true,
          );
        }
      },
      builder: (context, state) {
        final errText = switch (state.emailErrorCode) {
          'required' => tr.fieldRequired,
          'invalid' => tr.invalidEmail,
          _ => null,
        };

        return LayoutBuilder(
          builder: (ctx, c) {
            final w = c.maxWidth;
            final isWide = w >= 700;
            final maxW = isWide ? 540.0 : 480.0;

            return Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(maxWidth: maxW),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 24),
                    Text(
                      tr.inviteManagerTitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      tr.inviteManagerInstruction,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(.65),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AppTextField(
                      controller: _emailCtrl,
                      label: tr.managerEmailLabel,
                      hint: tr.managerEmailHint,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.send,
                      filled: true,
                      prefix: const Icon(Icons.email_outlined),
                      errorText: errText,
                      onChanged: (v) => context.read<InviteManagerBloc>().add(
                        InviteEmailChanged(v),
                      ),
                      onSubmitted: (_) => _submit(context),
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                    ),
                    const SizedBox(height: 16),
                    AppButton(
                      label: state.submitting ? tr.sending : tr.sendInvite,
                      onPressed: state.submitting
                          ? null
                          : () => _submit(context),
                      expand: true,
                      isBusy: state.submitting,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      semanticLabel: tr.sendInvite,
                    ),
                    const SizedBox(height: 12),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _submit(BuildContext context) {
    context.read<InviteManagerBloc>().add(
      InviteSubmitted(token: widget.token, businessId: widget.businessId),
    );
  }
}
