// Flutter 3.35.x
// connection_banner.dart — thin top banner showing connection status

import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // BlocBuilder
import '../network/connection_cubit.dart'; // states + cubit
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n

class ConnectionBanner extends StatelessWidget {
  const ConnectionBanner({super.key}); // const ctor

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ConnectionCubit, ConnectionStateX>(
      builder: (context, state) {
        if (state == ConnectionStateX.connected) {
          return const SizedBox.shrink(); // hide when connected
        }

        final cs = Theme.of(context).colorScheme; // colors
        final t = AppLocalizations.of(context)!; // strings

        // background by state
        final bg = (state == ConnectionStateX.offline)
            ? cs
                  .errorContainer // red-ish for offline
            : cs.surfaceContainerHighest; // neutral for connecting/serverDown

        // text by state
        final text = switch (state) {
          ConnectionStateX.offline => t.connectionOffline, // "Not connected"
          ConnectionStateX.serverDown =>
            t.connectionServerDown, // "Server unavailable"
          _ => t.connectionConnecting, // "Connecting…"
        };

        return Material(
          color: bg, // banner bg
          elevation: 2, // small shadow
          child: SafeArea(
            bottom: false, // top only
            child: Container(
              height: 40, // slim bar
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ), // side padding
              child: Row(
                children: [
                  if (state == ConnectionStateX.connecting ||
                      state == ConnectionStateX.serverDown)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ), // spinner
                    ),
                  if (state == ConnectionStateX.connecting ||
                      state == ConnectionStateX.serverDown)
                    const SizedBox(width: 8), // gap
                  Expanded(
                    child: Text(
                      text, // label
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface, // readable
                        fontWeight: FontWeight.w600, // semi-bold
                      ),
                      maxLines: 1, // one line
                      overflow: TextOverflow.ellipsis, // truncate
                    ),
                  ),
                  if (state == ConnectionStateX.offline ||
                      state == ConnectionStateX.serverDown)
                    TextButton(
                      onPressed: () => context
                          .read<ConnectionCubit>()
                          .retryNow(), // re-check
                      child: Text(
                        t.connectionTryAgain, // "Try again"
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: cs.primary, // accent
                          fontWeight: FontWeight.w700, // bold
                        ),
                      ),
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
