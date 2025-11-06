// presentation/widgets/deactivate_account_dialog.dart
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import '../cubit/deactivate_account_cubit.dart';

class DeactivateAccountDialog extends StatefulWidget {
  final String token;
  final int businessId;
  const DeactivateAccountDialog({super.key, required this.token, required this.businessId});

  @override
  State<DeactivateAccountDialog> createState() => _DeactivateAccountDialogState();
}

class _DeactivateAccountDialogState extends State<DeactivateAccountDialog> {
  final _ctrl = TextEditingController();
  String? _inlineError;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return AlertDialog(
      contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      content: BlocConsumer<DeactivateAccountCubit, DeactivateState>(
        listenWhen: (a, b) => b is DeactivateSuccess || b is DeactivateFailure,
        listener: (ctx, state) {
          if (state is DeactivateSuccess) Navigator.pop(ctx, true);
          if (state is DeactivateFailure) setState(() => _inlineError = state.message);
        },
        builder: (ctx, state) {
          final busy = state is DeactivateSubmitting;
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr.deactivateTitle,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 8),
              Text(tr.deactivateWarning, textAlign: TextAlign.center, style: theme.textTheme.bodyMedium),
              const SizedBox(height: 14),
              AppTextField(
                controller: _ctrl,
                label: tr.currentPasswordLabel,
                hint: tr.currentPasswordLabel,
                obscure: true,
                filled: true,
                textInputAction: TextInputAction.done,
                onSubmitted: (_) => _onConfirm(context),
                errorText: _inlineError?.isEmpty ?? true ? null : _inlineError,
              ),
              if (busy) const SizedBox(height: 6),
              if (busy) const LinearProgressIndicator(minHeight: 2),
            ],
          );
        },
      ),
      actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: Text(tr.cancel, style: TextStyle(color: cs.primary)),
        ),
        BlocBuilder<DeactivateAccountCubit, DeactivateState>(
          builder: (ctx, state) {
            final busy = state is DeactivateSubmitting;
            return ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: cs.error, foregroundColor: cs.onError),
              onPressed: busy ? null : () => _onConfirm(context),
              child: busy
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : Text(tr.confirm),
            );
          },
        ),
      ],
    );
  }

  void _onConfirm(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final password = _ctrl.text.trim();
    if (password.isEmpty) {
      setState(() => _inlineError = tr.fieldRequired);
      return;
    }
    setState(() => _inlineError = null);
    context.read<DeactivateAccountCubit>().submit(
          token: widget.token,
          businessId: widget.businessId,
          password: password,
        );
  }
}
