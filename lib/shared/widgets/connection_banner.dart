import 'package:flutter/material.dart'; // UI basics
import 'package:flutter_bloc/flutter_bloc.dart'; // read cubit state
import '../network/connection_cubit.dart'; // our cubit
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n strings

/// A thin banner that appears only when offline/connecting.
class ConnectionBanner extends StatelessWidget {
  // place banner at top of any screen or globally in App
  const ConnectionBanner({super.key}); // const constructor

  @override
  Widget build(BuildContext context) {
    // listen to cubit to know connection state
    return BlocBuilder<ConnectionCubit, ConnectionStateX>(
      builder: (context, state) {
        // if connected => render nothing (zero height)
        if (state == ConnectionStateX.connected) {
          return const SizedBox.shrink(); // hide
        }

        // get theme colors
        final cs = Theme.of(context).colorScheme; // color scheme
        final t = AppLocalizations.of(context)!; // localized strings

        // choose background color per state
        final bg = state == ConnectionStateX.offline
            ? cs
                  .errorContainer // more alerting color
            : cs.surfaceContainerHighest; // neutral while connecting

        // choose text per state
        final text = state == ConnectionStateX.offline
            ? t
                  .connectionOffline // "Not connected"
            : t.connectionConnecting; // "Connecting..."

        return Material(
          // material to apply color/elevation
          color: bg, // background color
          elevation: 2, // subtle shadow
          child: SafeArea(
            // keep under status bar
            bottom: false, // only top safe area
            child: Container(
              height: 40, // slim bar
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
              ), // left/right padding
              child: Row(
                children: [
                  if (state == ConnectionStateX.connecting)
                    const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ), // small spinner
                  if (state == ConnectionStateX.connecting)
                    const SizedBox(width: 8), // gap after spinner
                  Expanded(
                    child: Text(
                      text, // localized label
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: cs.onSurface, // readable text color
                        fontWeight: FontWeight.w600, // semi-bold
                      ),
                      maxLines: 1, // single line
                      overflow: TextOverflow.ellipsis, // no wrap
                    ),
                  ),
                  if (state == ConnectionStateX.offline)
                    TextButton(
                      onPressed: () => context
                          .read<ConnectionCubit>()
                          .retryNow(), // force re-check
                      child: Text(
                        t.connectionTryAgain, // "Try again"
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: cs.primary, // themed accent
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
