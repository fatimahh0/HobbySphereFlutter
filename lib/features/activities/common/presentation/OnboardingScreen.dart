// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart'; // Flutter core UI
import 'package:hobby_sphere/navigation/shell_bottom.dart';
import 'package:hobby_sphere/shared/theme/app_theme.dart'; // your app theme (colors/typography)
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n strings
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // reusable AppButton

// ===== added imports =====
import 'package:hobby_sphere/app/router/router.dart'; // app routes (for login)
import 'package:hobby_sphere/core/constants/app_role.dart'; // AppRole enum
// ⬇️ adjust the path to where your ShellBottom lives

// ^ if your file path is different, change this import only.

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme; // toggle theme (optional)
  final void Function(Locale locale)?
  onChangeLocale; // change language (optional)
  final Locale? currentLocale; // current locale (optional)

  const OnboardingScreen({
    super.key, // widget key
    this.onToggleTheme, // pass theme toggle
    this.onChangeLocale, // pass language change
    this.currentLocale, // pass current locale
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState(); // create state
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // --- animation controllers ---
  late final AnimationController _introCtrl; // fade + scale in
  late final AnimationController _floatCtrl; // breathing float

  // --- animated values ---
  late final Animation<double> _opacity; // fade progress
  late final Animation<double> _scale; // scale progress
  late final Animation<double> _yOffset; // vertical offset

  @override
  void initState() {
    super.initState(); // init base
    _introCtrl = AnimationController(
      // intro controller
      vsync: this, // ticker
      duration: const Duration(milliseconds: 800), // 0.8s
    );
    _opacity = CurvedAnimation(
      // fade curve
      parent: _introCtrl,
      curve: Curves.easeOutCubic,
    );
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      // small pop
      CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutBack),
    );
    _floatCtrl = AnimationController(
      // float controller
      vsync: this,
      duration: const Duration(milliseconds: 2400), // slow loop
    )..repeat(reverse: true); // ping-pong
    _yOffset = Tween<double>(begin: -6, end: 6).animate(
      // up/down
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut),
    );
    _introCtrl.forward(); // start intro
  }

  @override
  void dispose() {
    _introCtrl.dispose(); // free intro
    _floatCtrl.dispose(); // free float
    super.dispose(); // dispose base
  }

  // open bottom sheet to pick language
  void _openLanguageSheet(BuildContext context) {
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // color scheme
    final l10n = AppLocalizations.of(context)!; // l10n

    showModalBottomSheet(
      // show sheet
      context: context,
      backgroundColor: cs.surface, // bg color
      shape: const RoundedRectangleBorder(
        // rounded top
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        // helper tile builder
        Widget tile(String code, String name, Locale locale) {
          final selected =
              widget.currentLocale?.languageCode == code; // selected?
          return ListTile(
            title: Text(name, style: theme.textTheme.bodyMedium), // label
            trailing: selected
                ? Icon(Icons.check, color: cs.primary)
                : null, // check
            onTap: () {
              Navigator.pop(ctx); // close
              widget.onChangeLocale?.call(locale); // change
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // wrap height
            children: [
              const SizedBox(height: 12), // gap
              Container(
                // grab bar
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12), // gap
              Text(
                l10n.selectLanguage, // title
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 4), // gap
              Divider(color: cs.outlineVariant), // divider
              tile('en', 'English', const Locale('en')), // English
              tile('ar', 'العربية', const Locale('ar')), // Arabic
              tile('fr', 'Français', const Locale('fr')), // French
              const SizedBox(height: 8), // bottom gap
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // l10n instance
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // color scheme
    final isDark = theme.brightness == Brightness.dark; // mode
    final code =
        (widget.currentLocale?.languageCode ?? 'en') // language code
            .toUpperCase();

    // responsive metrics
    final size = MediaQuery.sizeOf(context); // screen size
    final w = size.width; // width
    final h = size.height; // height
    final horizontal = _clampDouble(w * 0.05, 16, 24); // side padding
    final topGap = _clampDouble(h * 0.02, 8, 20); // top gap
    final imageUpShift = _clampDouble(h * 0.06, 28, 56); // image shift
    final ctaGap = _clampDouble(h * 0.025, 16, 28); // gap to CTA
    final imageRadius = _clampDouble(
      w * 0.04,
      14,
      22,
    ); // radius (kept if you wrap)

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // scaffold bg
      body: Stack(
        fit: StackFit.expand, // fill screen
        children: [
          // subtle primary gradient background
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, // start
                end: Alignment.bottomRight, // end
                colors: [
                  cs.primary.withOpacity(0.12), // tint
                  cs.primary.withOpacity(0.02), // fade
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal), // sides
              child: Column(
                children: [
                  SizedBox(height: topGap), // top space
                  // top actions (theme + language)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // spread
                    children: [
                      AppButton(
                        // theme button
                        onPressed: widget.onToggleTheme, // toggle
                        type: AppButtonType.secondary, // soft fill
                        size: AppButtonSize.sm, // small
                        leading: Icon(
                          // icon
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          size: 18,
                        ),
                        label:
                            '${l10n.changeTheme} • ${isDark ? "Dark" : "Light"}', // text
                      ),
                      AppButton(
                        // language button
                        onPressed: () =>
                            _openLanguageSheet(context), // open sheet
                        type: AppButtonType.outline, // outline
                        size: AppButtonSize.sm, // small
                        leading: const Icon(Icons.translate, size: 18), // icon
                        label: ' $code ', // show code
                      ),
                    ],
                  ),

                  SizedBox(height: _clampDouble(h * 0.03, 18, 36)), // gap
                  // illustration (animated + centered)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: imageUpShift,
                        ), // shift up
                        child: AnimatedBuilder(
                          // rebuild on anim
                          animation: Listenable.merge([_introCtrl, _floatCtrl]),
                          builder: (context, _) {
                            final hh = MediaQuery.sizeOf(
                              context,
                            ).height; // height
                            return Opacity(
                              // fade in
                              opacity: _opacity.value,
                              child: Transform.translate(
                                // float up/down
                                offset: Offset(0, _yOffset.value),
                                child: Transform.scale(
                                  // small pop
                                  scale: _scale.value,
                                  child: Hero(
                                    // hero tag (optional)
                                    tag: 'onboarding-illustration',
                                    child: SizedBox(
                                      height: _clampDouble(
                                        hh * 0.34,
                                        240,
                                        420,
                                      ), // size
                                      width: double.infinity, // full width box
                                      child: FittedBox(
                                        // fit image
                                        fit: BoxFit.contain, // keep full image
                                        alignment: Alignment.center, // centered
                                        child: Image.asset(
                                          'assets/images/Onboarding.png', // asset
                                          filterQuality:
                                              FilterQuality.high, // crisp
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),

                  SizedBox(height: _clampDouble(h * 0.005, 6, 12)), // gap
                  // title text
                  Text(
                    l10n.onboardingTitle, // title
                    textAlign: TextAlign.center, // center
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800, // bold
                      letterSpacing: 0.2, // tracking
                    ),
                  ),

                  SizedBox(height: _clampDouble(h * 0.008, 6, 12)), // gap
                  // subtitle text
                  Text(
                    l10n.onboardingSubtitle, // subtitle
                    textAlign: TextAlign.center, // center
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.75,
                      ),
                      height: 1.35, // line height
                    ),
                  ),

                  SizedBox(height: ctaGap), // gap before CTA
                  // ===== PRIMARY CTA: Get Started (→ open GUEST shell) =====
                  AppButton(
                    onPressed: () {
                      // push the ShellBottom with EMPTY token => guest mode
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(
                          builder: (_) => ShellBottom(
                            role: AppRole.user, // user shell
                            token: '', // '' => guest
                            businessId: 0, // not used here
                            onChangeLocale:
                                widget.onChangeLocale ??
                                (_) {}, // no-op if null
                            onToggleTheme:
                                widget.onToggleTheme ?? () {}, // no-op if null
                          ),
                        ),
                      );
                    },
                    type: AppButtonType.primary, // solid button
                    size: AppButtonSize.lg, // large
                    expand: true, // full width
                    label: l10n.onboardingGetStarted, // text
                  ),

                  SizedBox(height: _clampDouble(h * 0.012, 8, 16)), // gap
                  // ===== SECONDARY: Already have an account? (→ Login) =====
                  AppButton(
                    onPressed: () {
                      // go to login screen using your router constant (adjust if needed)
                      Navigator.pushReplacementNamed(context, Routes.login);
                    },
                    type: AppButtonType.text, // text style
                    label: l10n.onboardingAlreadyHaveAccount, // text
                  ),

                  SizedBox(height: _clampDouble(h * 0.01, 6, 12)), // bottom gap
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // clamp helper
  double _clampDouble(double v, double min, double max) {
    if (v < min) return min; // min bound
    if (v > max) return max; // max bound
    return v; // within
  }
}
