// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart'; // Flutter core UI
import 'package:hobby_sphere/theme/app_theme.dart'; // your app theme (colors/typography)
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/ui/widgets/app_button.dart'; // reusable AppButton

// Onboarding screen with responsive layout and animated image
class OnboardingScreen extends StatefulWidget {
  // callback to toggle theme mode (light/dark)
  final VoidCallback? onToggleTheme; // can be null
  // callback to change language (Locale)
  final void Function(Locale locale)? onChangeLocale; // can be null
  // current selected locale
  final Locale? currentLocale; // can be null

  const OnboardingScreen({
    super.key, // widget key
    this.onToggleTheme, // theme toggle callback
    this.onChangeLocale, // language change callback
    this.currentLocale, // current locale
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState(); // create state
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  // controllers for animations
  late final AnimationController _introCtrl; // fade + scale
  late final AnimationController _floatCtrl; // breathing float

  // animated values
  late final Animation<double> _opacity; // fade in
  late final Animation<double> _scale; // scale in
  late final Animation<double> _yOffset; // vertical float

  @override
  void initState() {
    super.initState(); // call parent

    // setup intro controller (fast ease in)
    _introCtrl = AnimationController(
      vsync: this, // ticker (required)
      duration: const Duration(milliseconds: 800), // 0.8s
    );

    // fade curve
    _opacity = CurvedAnimation(
      parent: _introCtrl, // controller
      curve: Curves.easeOutCubic, // smooth curve
    );

    // scale from 0.96 to 1.0 for subtle pop
    _scale = Tween<double>(begin: 0.96, end: 1.0).animate(
      CurvedAnimation(
        parent: _introCtrl,
        curve: Curves.easeOutBack,
      ), // nice spring
    );

    // setup float controller (endless)
    _floatCtrl = AnimationController(
      vsync: this, // ticker
      duration: const Duration(milliseconds: 2400), // slow loop
    )..repeat(reverse: true); // back and forth

    // y offset from -A to +A (A set later by curve here)
    _yOffset = Tween<double>(begin: -6, end: 6).animate(
      CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut), // gentle
    );

    _introCtrl.forward(); // start intro animation
  }

  @override
  void dispose() {
    _introCtrl.dispose(); // free controller
    _floatCtrl.dispose(); // free controller
    super.dispose(); // call parent
  }

  // open bottom sheet to pick language
  void _openLanguageSheet(BuildContext context) {
    final theme = Theme.of(context); // theme reference
    final cs = theme.colorScheme; // color scheme
    final l10n = AppLocalizations.of(context)!; // localization

    showModalBottomSheet(
      context: context, // show in this context
      backgroundColor: cs.surface, // sheet background
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(20),
        ), // rounded top
      ),
      builder: (ctx) {
        // small helper to build each language row
        Widget tile(String code, String name, Locale locale) {
          final selected =
              widget.currentLocale?.languageCode == code; // selected?
          return ListTile(
            title: Text(name, style: theme.textTheme.bodyMedium), // name
            trailing: selected
                ? Icon(Icons.check, color: cs.primary)
                : null, // check if selected
            onTap: () {
              Navigator.pop(ctx); // close sheet
              widget.onChangeLocale?.call(locale); // call change
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min, // wrap content
            children: [
              const SizedBox(height: 12), // spacing
              Container(
                width: 48, // grabbar width
                height: 4, // grabbar height
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withOpacity(0.7), // subtle color
                  borderRadius: BorderRadius.circular(10), // rounded
                ),
              ),
              const SizedBox(height: 12), // spacing
              Text(
                l10n.selectLanguage,
                style: theme.textTheme.titleMedium,
              ), // title
              const SizedBox(height: 4), // spacing
              Divider(color: cs.outlineVariant), // divider
              tile('en', 'English', const Locale('en')), // English
              tile('ar', 'العربية', const Locale('ar')), // Arabic
              tile('fr', 'Français', const Locale('fr')), // French
              const SizedBox(height: 8), // bottom spacing
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // localization instance
    final theme = Theme.of(context); // theme instance
    final cs = theme.colorScheme; // color scheme for colors
    final isDark = theme.brightness == Brightness.dark; // theme mode
    final code = (widget.currentLocale?.languageCode ?? 'en')
        .toUpperCase(); // current lang

    // ===== responsive metrics =====
    final size = MediaQuery.sizeOf(context); // screen size
    final w = size.width; // width
    final h = size.height; // height

    // horizontal padding responsive (clamp between 16..24)
    final horizontal = _clampDouble(w * 0.05, 16, 24); // 5% width
    // space above illustration (responsive vertical gap)
    final topGap = _clampDouble(h * 0.02, 8, 20); // small top gap
    // amount to shift image UP (padding-bottom pushes it up visually)
    final imageUpShift = _clampDouble(h * 0.06, 28, 56); // 6% height
    // gap under subtitle before CTA (responsive)
    final ctaGap = _clampDouble(h * 0.025, 16, 28); // spacing to CTA
    // image corner radius responsive (slightly larger on tablets)
    final imageRadius = _clampDouble(w * 0.04, 14, 22); // px radius

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor, // scaffold bg
      body: Stack(
        fit: StackFit.expand, // fill screen
        children: [
          // background gradient using primary color
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft, // start corner
                end: Alignment.bottomRight, // end corner
                colors: [
                  cs.primary.withOpacity(0.12), // soft tint
                  cs.primary.withOpacity(0.02), // fade out
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: horizontal,
              ), // responsive sides
              child: Column(
                children: [
                  SizedBox(height: topGap), // top breathing space
                  // ===== top actions (theme + language) =====
                  Row(
                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween, // separate
                    children: [
                      // theme toggle (secondary filled)
                      AppButton(
                        onPressed: widget.onToggleTheme, // toggle callback
                        type: AppButtonType.secondary, // soft fill
                        size: AppButtonSize.sm, // compact
                        leading: Icon(
                          // theme icon
                          isDark
                              ? Icons.dark_mode
                              : Icons.light_mode, // by mode
                          size: 18, // small
                        ),
                        label:
                            '${l10n.changeTheme} • ${isDark ? "Dark" : "Light"}', // text
                      ),

                      // language button (outlined)
                      AppButton(
                        onPressed: () =>
                            _openLanguageSheet(context), // open sheet
                        type: AppButtonType.outline, // outline style
                        size: AppButtonSize.sm, // compact
                        leading: const Icon(Icons.translate, size: 18), // icon
                        label: ' $code ', // show code (EN/AR/FR)
                      ),
                    ],
                  ),

                  SizedBox(
                    height: _clampDouble(h * 0.03, 18, 36),
                  ), // space under top row
                  // ===== illustration (animated + shifted up) =====
                  Expanded(
                    child: Center(
                      // center wrapper
                      child: Padding(
                        padding: EdgeInsets.only(
                          bottom: imageUpShift,
                        ), // push image up
                        // ===== illustration (no crop, full image) =====
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_introCtrl, _floatCtrl]),
                          builder: (context, _) {
                            final h = MediaQuery.sizeOf(context).height;

                            return Opacity(
                              opacity: _opacity.value,
                              child: Transform.translate(
                                offset: Offset(0, _yOffset.value),
                                child: Transform.scale(
                                  scale: _scale.value,
                                  child: Hero(
                                    tag: 'onboarding-illustration',
                                    child: SizedBox(
                                      // responsive height: tweak limits if you like
                                      height: _clampDouble(h * 0.34, 240, 420),
                                      width: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit
                                            .contain, // <-- show ALL of the image
                                        alignment: Alignment
                                            .center, // centered, no weird shifts
                                        child: Image.asset(
                                          'assets/images/Onboarding.png',
                                          filterQuality: FilterQuality
                                              .high, // cleaner scaling
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

                  SizedBox(height: _clampDouble(h * 0.005, 6, 12)), // small gap
                  // ===== title =====
                  Text(
                    l10n.onboardingTitle, // localized title
                    textAlign: TextAlign.center, // center text
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800, // bold
                      letterSpacing: 0.2, // tiny tracking
                    ),
                  ),

                  SizedBox(height: _clampDouble(h * 0.008, 6, 12)), // gap
                  // ===== subtitle =====
                  Text(
                    l10n.onboardingSubtitle, // localized subtitle
                    textAlign: TextAlign.center, // center text
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.75,
                      ), // softer
                      height: 1.35, // line height
                    ),
                  ),

                  SizedBox(height: ctaGap), // gap before CTA
                  // ===== CTA: Get Started (full width) =====
                  AppButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/login',
                    ), // go login
                    type: AppButtonType.primary, // solid primary
                    size: AppButtonSize.lg, // large
                    expand: true, // full width
                    label: l10n.onboardingGetStarted, // text
                  ),

                  SizedBox(height: _clampDouble(h * 0.012, 8, 16)), // gap
                  // ===== secondary link =====
                  AppButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      '/login',
                    ), // go login
                    type: AppButtonType.text, // link-like
                    label: l10n.onboardingAlreadyHaveAccount, // text
                  ),

                  SizedBox(
                    height: _clampDouble(h * 0.01, 6, 12),
                  ), // bottom breathing
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // helper: clamp a value between min and max
  double _clampDouble(double v, double min, double max) {
    // ensure v is within [min, max]
    if (v < min) return min; // lower bound
    if (v > max) return max; // upper bound
    return v; // within range
  }
}
