// lib/shared/widgets/connection_banner.dart
// Show banner only when OFFLINE. No banner while CONNECTING (no flicker).

import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc
import '../network/connection_cubit.dart'; // cubit
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key}); // const

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionCubit, ConnectionStateX>(
      buildWhen: (p, n) => p != n, // rebuild only on change
      builder: (context, state) {
        // ❗ only show when OFFLINE (hide for CONNECTED + CONNECTING)
        if (state != ConnectionStateX.offline) {
          return const SizedBox.shrink(); // hide
        }

        // theme + i18n
        final cs = Theme.of(context).colorScheme; // colors
        final t = AppLocalizations.of(context)!; // texts

        return Material(
          color: cs.errorContainer, // alert background
          elevation: 3, // subtle shadow
          child: SafeArea(
            bottom: false, // top only
            child: Container(
              height: 44, // comfy height
              padding: const EdgeInsets.symmetric(horizontal: 12), // inner pad
              child: Row(
                children: [
                  Icon(
                    Icons.wifi_off_rounded,
                    size: 20,
                    color: cs.onErrorContainer,
                  ), // icon
                  const SizedBox(width: 10), // gap
                  Expanded(
                    child: Text(
                      t.connectionOffline, // "Not connected"
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis, // one line
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onErrorContainer, // readable text
                        fontWeight: FontWeight.w700, // strong
                      ),
                    ),
                  ),
                  FilledButton.tonal(
                    onPressed: () => context
                        .read<ConnectionCubit>()
                        .retryNow(), // re-check now
                    child: Text(t.connectionTryAgain), // "Try again"
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
