// === Dialog: confirm INACTIVE (requires password) ===
import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // read()
import '../../domain/usecases/update_user_status.dart'; // usecase

class DeactivateUserDialog extends StatefulWidget {
  final String token; // auth token
  final int userId; // user id
  const DeactivateUserDialog({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<DeactivateUserDialog> createState() => _DeactivateUserDialogState();
}

class _DeactivateUserDialogState extends State<DeactivateUserDialog> {
  final _ctrl = TextEditingController(); // password ctrl
  bool _busy = false; // loading flag
  String? _error; // inline error

  @override
  void dispose() {
    _ctrl.dispose(); // cleanup
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    return AlertDialog(
      title: const Text(
        'Deactivate account',
      ), // title (localize key: deactivateTitle)
      content: Column(
        mainAxisSize: MainAxisSize.min, // wrap content
        children: [
          const Text(
            'Enter your password to confirm.',
          ), // (l10n: deactivateWarning)
          const SizedBox(height: 12),
          TextField(
            controller: _ctrl, // connect ctrl
            obscureText: true, // hide chars
            decoration: InputDecoration(
              labelText: 'Password', // (l10n: currentPasswordLabel)
              errorText: _error, // inline error
              filled: true, // filled style
            ),
            onSubmitted: (_) => _submit(context), // submit on enter
          ),
          if (_busy) const SizedBox(height: 8), // spacing when busy
          if (_busy) const LinearProgressIndicator(minHeight: 2), // spinner
        ],
      ),
      actions: [
        TextButton(
          onPressed: _busy
              ? null
              : () => Navigator.pop(context, false), // cancel
          child: Text(
            'Cancel',
            style: TextStyle(color: theme.colorScheme.error),
          ), // (l10n: cancel)
        ),
        ElevatedButton(
          onPressed: _busy ? null : () => _submit(context), // confirm
          child: const Text('Confirm'), // (l10n: confirm)
        ),
      ],
    );
  }

  Future<void> _submit(BuildContext context) async {
    final pwd = _ctrl.text.trim(); // password
    if (pwd.isEmpty) {
      // validate
      setState(() => _error = 'Password required'); // (l10n: fieldRequired)
      return;
    }
    setState(() {
      _error = null;
      _busy = true;
    }); // start loading
    try {
      final uc = context.read<UpdateUserStatus>(); // get usecase from DI
      await uc(
        // call
        token: widget.token,
        userId: widget.userId,
        status: 'INACTIVE',
        password: pwd,
      );
      if (mounted) Navigator.pop(context, true); // success -> close
    } catch (e) {
      setState(() => _error = e.toString()); // show error
    } finally {
      if (mounted) setState(() => _busy = false); // stop loading
    }
  }
}
