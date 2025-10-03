import 'dart:math' as math; // for min() sizing
import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart'; // input formatters & clipboard

/// Professional 6-digit OTP boxes with:
/// - No overflow (responsive sizing via LayoutBuilder)
/// - Smart focus (next/prev on type/backspace)
/// - Paste support (paste 6 digits fills all)
/// - iOS/Android autofill (oneTimeCode)
/// - Simple callbacks: onChanged(code) + onCompleted(code)
class OtpBoxes extends StatelessWidget {
  // 6 controllers passed from parent (keep your Bloc sync)
  final List<TextEditingController> ctrls; // must be length 6
  // 6 focus nodes passed from parent (to manage focus externally)
  final List<FocusNode> nodes; // must be length 6
  // called on any change with full code (may be partial)
  final ValueChanged<String> onChanged;
  // optional: called when all 6 digits entered
  final ValueChanged<String>? onCompleted;
  // optional: error text shown under the row
  final String? errorText;
  // optional: disable input (e.g., while verifying)
  final bool enabled;
  // optional: autofocus the first box
  final bool autofocusFirst;
  // optional: vertical padding around the row
  final EdgeInsetsGeometry padding;

  const OtpBoxes({
    super.key,
    required this.ctrls, // 6 controllers
    required this.nodes, // 6 nodes
    required this.onChanged, // change callback
    this.onCompleted, // completed callback
    this.errorText, // error text
    this.enabled = true, // enabled flag
    this.autofocusFirst = true, // autofocus first
    this.padding = const EdgeInsets.symmetric(vertical: 6.0), // default padding
  }) : assert(ctrls.length == 6, 'Need exactly 6 controllers'),
       assert(nodes.length == 6, 'Need exactly 6 focus nodes');

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors

    return Padding(
      padding: padding, // outer padding
      child: LayoutBuilder(
        builder: (context, constraints) {
          final maxW = constraints.maxWidth; // available width
          const gap = 8.0; // horizontal gap between boxes
          const maxBox = 56.0; // comfy max width per box
          // compute a safe width per box: min(maxBox, (maxW - gaps) / 6)
          final boxW = math.min(maxBox, (maxW - (gap * 5)) / 6);
          // keep height slightly taller than width for readability
          final boxH = math.max(44.0, boxW + 6);

          // helper to emit code + completed
          void _emitAndMaybeComplete() {
            final code = ctrls.map((c) => c.text).join(); // full code
            onChanged(code); // notify parent
            if (code.length == 6 && !code.contains('')) {
              // when 6 chars filled, fire completed if provided
              if (onCompleted != null) onCompleted!(code);
            }
          }

          // helper: distribute pasted text across boxes
          Future<void> _handlePaste(int fromIndex) async {
            // read clipboard
            final data = await Clipboard.getData(Clipboard.kTextPlain);
            final text = (data?.text ?? '').replaceAll(
              RegExp(r'\D'),
              '',
            ); // digits only
            if (text.length < 2) return; // ignore single char (normal flow)
            // if user pasted more than 1 char, fill forward
            var i = fromIndex;
            for (final ch in text.characters) {
              if (i > 5) break; // stop at last box
              ctrls[i].text = ch; // set digit
              i++; // next box
            }
            // move focus to next empty or stay on last
            final nextEmpty = ctrls.indexWhere((c) => c.text.isEmpty);
            if (nextEmpty != -1) {
              nodes[nextEmpty].requestFocus(); // focus next empty
            } else {
              nodes.last.unfocus(); // all filled -> unfocus keyboard
            }
            _emitAndMaybeComplete(); // emit code
          }

          return Column(
            mainAxisSize: MainAxisSize.min, // compact column
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center, // center row
                children: List.generate(6, (i) {
                  final isLast = i == 5; // last index
                  return Padding(
                    padding: EdgeInsets.only(right: i == 5 ? 0 : gap), // gap
                    child: SizedBox(
                      width: boxW, // responsive width
                      height: boxH, // responsive height
                      child: _OtpCell(
                        controller: ctrls[i], // this ctrl
                        node: nodes[i], // this node
                        enabled: enabled, // enable/disable
                        autofocus: autofocusFirst && i == 0, // autofocus first
                        isLast: isLast, // last box
                        colorScheme: cs, // colors
                        onBackspaceEmpty: () {
                          // if this box empty and backspace -> go previous
                          if (i > 0) nodes[i - 1].requestFocus(); // prev
                        },
                        onFilledGoNext: () {
                          // after a char typed -> focus next or stay on last
                          if (!isLast) {
                            nodes[i + 1].requestFocus(); // next
                          } else {
                            nodes[i].unfocus(); // last: dismiss
                          }
                          _emitAndMaybeComplete(); // emit
                        },
                        onClearedGoPrev: () {
                          // if cleared manually -> go previous
                          if (i > 0) nodes[i - 1].requestFocus(); // prev
                          _emitAndMaybeComplete(); // emit
                        },
                        onPaste: () => _handlePaste(i), // paste handler
                        onAnyChange:
                            _emitAndMaybeComplete, // emit on any change
                      ),
                    ),
                  );
                }),
              ),
              if ((errorText ?? '').isNotEmpty) // show error if provided
                Padding(
                  padding: const EdgeInsets.only(top: 8.0), // spacing
                  child: Text(
                    errorText!, // error text
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: cs.error,
                    ), // red
                    textAlign: TextAlign.center, // center
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// Single OTP cell (extracted for clarity)
class _OtpCell extends StatelessWidget {
  final TextEditingController controller; // ctrl
  final FocusNode node; // focus
  final bool enabled; // enabled
  final bool autofocus; // autofocus
  final bool isLast; // last cell
  final ColorScheme colorScheme; // colors
  final VoidCallback onBackspaceEmpty; // backspace when empty
  final VoidCallback onFilledGoNext; // after entering a char
  final VoidCallback onClearedGoPrev; // when cleared
  final VoidCallback onPaste; // when paste menu used
  final VoidCallback onAnyChange; // any change emit

  const _OtpCell({
    required this.controller,
    required this.node,
    required this.enabled,
    required this.autofocus,
    required this.isLast,
    required this.colorScheme,
    required this.onBackspaceEmpty,
    required this.onFilledGoNext,
    required this.onClearedGoPrev,
    required this.onPaste,
    required this.onAnyChange,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context); // theme
    return Focus(
      // wrapper to intercept key events (backspace)
      onKeyEvent: (nodeRaw, event) {
        // if backspace pressed and this field empty -> jump previous
        if (event is KeyDownEvent &&
            event.logicalKey == LogicalKeyboardKey.backspace &&
            controller.text.isEmpty) {
          onBackspaceEmpty(); // go prev
          return KeyEventResult.handled; // handled
        }
        return KeyEventResult.ignored; // otherwise ignore
      },
      child: TextField(
        controller: controller, // controller
        focusNode: node, // node
        enabled: enabled, // enabled
        autofocus: autofocus, // autofocus
        textAlign: TextAlign.center, // center char
        style: theme.textTheme.titleMedium, // font size/weight
        keyboardType: TextInputType.number, // numeric keypad
        textInputAction: isLast
            ? TextInputAction.done
            : TextInputAction.next, // ime
        maxLength: 1, // single char
        autofillHints: const [AutofillHints.oneTimeCode], // OTP autofill
        enableSuggestions: false, // no suggestions
        autocorrect: false, // no autocorrect
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // digits only
          LengthLimitingTextInputFormatter(1), // limit to 1
        ],
        decoration: InputDecoration(
          counterText: '', // hide "0/1"
          isDense: true, // compact
          contentPadding: const EdgeInsets.symmetric(
            vertical: 10,
          ), // vertical pad
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // rounded
            borderSide: BorderSide(color: colorScheme.outline), // default
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // rounded
            borderSide: BorderSide(color: colorScheme.outlineVariant), // subtle
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // rounded
            borderSide: BorderSide(
              color: colorScheme.primary,
              width: 1.6,
            ), // primary
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10), // rounded
            borderSide: BorderSide(color: colorScheme.outlineVariant), // subtle
          ),
        ),
        onChanged: (v) async {
          // if user pasted multiple digits into this field
          // (some keyboards let onChanged see all chars before formatter)
          if (v.length > 1) {
            onPaste(); // distribute paste
            return; // done
          }
          // normal flow:
          if (v.isNotEmpty) {
            onFilledGoNext(); // go next / complete
          } else {
            onClearedGoPrev(); // go prev if cleared
          }
          onAnyChange(); // emit code
        },
        onTap: () async {
          // if user long-press → paste via menu; try to handle soon after
          await Future<void>.delayed(
            const Duration(milliseconds: 1),
          ); // tiny wait
          onAnyChange(); // re-emit
        },
      ),
    );
  }
}
