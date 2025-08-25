import 'package:flutter/material.dart'; // core
import 'package:shared_preferences/shared_preferences.dart'; // remember seen onboarding
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/theme/app_theme.dart'; // AppColors / AppTypography

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key}); // stateful

  @override
  State<OnboardingPage> createState() => _OnboardingPageState(); // create state
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController(); // controls pages
  int _index = 0; // current page index

  late final AnimationController _bgCtrl; // gradient motion

  @override
  void initState() {
    super.initState(); // call parent
    _bgCtrl = AnimationController(
      vsync: this, // ticker
      duration: const Duration(seconds: 8), // slow premium loop
    )..repeat(reverse: true); // back & forth
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); // free bg controller
    _pageCtrl.dispose(); // free page controller
    super.dispose(); // parent
  }

  // lighten/darken a color a bit (keeps hue/saturation) – used for gradient
  Color _tint(Color c, double delta) {
    final hsl = HSLColor.fromColor(c); // convert to HSL
    final l = (hsl.lightness + delta).clamp(0.0, 1.0); // adjust lightness
    return hsl.withLightness(l).toColor(); // back to Color
  }

  // mark onboarding as seen
  Future<void> _markSeen() async {
    final sp = await SharedPreferences.getInstance(); // prefs
    await sp.setBool('seen_onboarding', true); // save flag
  }

  // primary action on last page → continue as guest (home)
  Future<void> _continueAsGuest() async {
    await _markSeen(); // store once
    if (!mounted) return; // safety
    Navigator.pushReplacementNamed(
      context,
      '/onboardingScreen',
    ); // go to home (guest)
  }

  // next page or (if last) continue as guest
  void _next() {
    if (_index < 2) {
      _pageCtrl.nextPage(
        // go next
        duration: const Duration(milliseconds: 300), // duration
        curve: Curves.easeOut, // curve
      );
    } else {
      _continueAsGuest(); // last → continue
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final theme = Theme.of(context); // current theme
    final cs = theme.colorScheme; // color scheme (light/dark aware)

    // use theme’s primary (not hardcoded) so it adapts to brand + mode
    final primary = cs.primary; // brand primary
    final onPrimary = cs.onPrimary; // readable text on primary
    final lighter = _tint(primary, 0.16); // lighter shade of primary
    final darker = _tint(primary, -0.12); // darker shade of primary

    // slides with icons
    final slides = [
      (icon: Icons.explore, title: t.onbTitle1, subtitle: t.onbSubtitle1),
      (
        icon: Icons.event_available,
        title: t.onbTitle2,
        subtitle: t.onbSubtitle2,
      ),
      (icon: Icons.people_alt, title: t.onbTitle3, subtitle: t.onbSubtitle3),
    ];

    // ---------- animated gradient background (from theme.primary shades) ----------
    Widget buildBg() => AnimatedBuilder(
      animation: _bgCtrl, // listen to bg
      builder: (context, _) {
        final v = _bgCtrl.value; // 0..1..0
        final c1 = Color.lerp(primary, lighter, v)!; // primary→lighter
        final c2 = Color.lerp(primary, darker, 1 - v)!; // primary→darker
        final begin = Alignment(-0.9 + v * 0.5, -1.0); // subtle motion
        final end = Alignment(0.9 - v * 0.5, 1.0); // subtle motion
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin, // start
              end: end, // end
              colors: [c1, c2], // two brand shades
            ),
          ),
        );
      },
    );

    // ---------- dots indicator (uses onPrimary for contrast) ----------
    Widget buildDots() => Row(
      mainAxisAlignment: MainAxisAlignment.center, // center
      children: List.generate(slides.length, (i) {
        final active = i == _index; // current?
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250), // animate change
          margin: const EdgeInsets.symmetric(horizontal: 4), // spacing
          width: active ? 24 : 8, // pill vs dot
          height: 8, // height
          decoration: BoxDecoration(
            color: onPrimary.withOpacity(
              active ? 0.95 : 0.45,
            ), // use themed contrast color
            borderRadius: BorderRadius.circular(999), // capsule
          ),
        );
      }),
    );

    // ---------- bottom bar (buttons styled from theme) ----------
    Widget buildBottomBar() {
      final isLast = _index == slides.length - 1; // last page?
      return SafeArea(
        // avoid insets
        top: false, // only bottom
        child: Padding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 8), // padding
          child: Column(
            mainAxisSize: MainAxisSize.min, // compact
            children: [
              Row(
                children: [
                  // SKIP (left) – visible on pages 0/1
                  if (!isLast)
                    TextButton(
                      onPressed: _continueAsGuest, // skip → home guest
                      style: TextButton.styleFrom(
                        foregroundColor: onPrimary, // themed contrast color
                      ),
                      child: Text(
                        t.onbSkip, // "Skip"
                        style: AppTypography.textTheme.labelLarge?.copyWith(
                          color: onPrimary, // text uses onPrimary
                          fontWeight: FontWeight.w600, // semi-bold
                        ),
                      ),
                    )
                  else
                    const SizedBox(width: 8), // align when hidden
                  // DOTS (center)
                  Expanded(child: buildDots()), // dots row
                  // NEXT / GET STARTED (right)
                  SizedBox(
                    height: 44, // button height
                    child: ElevatedButton(
                      onPressed: _next, // action
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            cs.surface, // surface bg (respects theme)
                        foregroundColor: cs.primary, // brand text/icon
                        elevation: 0, // flat
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: AnimatedSwitcher(
                        // switch label
                        duration: const Duration(milliseconds: 180),
                        transitionBuilder: (c, a) =>
                            FadeTransition(opacity: a, child: c),
                        child: Text(
                          isLast ? t.onbGetStarted : t.onbNext, // label
                          key: ValueKey<bool>(isLast), // key for switch
                          style: AppTypography.textTheme.labelLarge,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    // ---------- single slide with icon + texts (uses theme colors) ----------
    Widget buildSlide(int i) {
      final s = slides[i]; // slide data
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20), // side padding
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // vertical center
          children: [
            // Icon inside circular card (subtle scale-in)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1.0), // 92% → 100%
              duration: const Duration(milliseconds: 400), // time
              curve: Curves.easeOut, // easing
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: 160,
                height: 160, // circle size
                decoration: BoxDecoration(
                  color: onPrimary.withOpacity(
                    0.15,
                  ), // soft tint from onPrimary
                  shape: BoxShape.circle, // circle
                  border: Border.all(
                    color: onPrimary.withOpacity(0.25), // ring using onPrimary
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: cs.shadow.withOpacity(0.25), // theme shadow
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(
                  s.icon,
                  size: 80,
                  color: onPrimary,
                ), // icon color from theme
              ),
            ),

            const SizedBox(height: 28), // spacing
            // Title (fade‑in) – use theme text with onPrimary color
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              builder: (_, o, child) => Opacity(opacity: o, child: child),
              child: Text(
                s.title,
                textAlign: TextAlign.center,
                style:
                    (theme.textTheme.headlineSmall ??
                            AppTypography.textTheme.headlineSmall)
                        ?.copyWith(
                          color: onPrimary, // text uses onPrimary
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.3,
                        ),
              ),
            ),

            const SizedBox(height: 12), // spacing
            // Subtitle (fade‑in) – use theme text with softer onPrimary
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              builder: (_, o, child) => Opacity(opacity: o, child: child),
              child: Text(
                s.subtitle,
                textAlign: TextAlign.center,
                style:
                    (theme.textTheme.bodyMedium ??
                            AppTypography.textTheme.bodyMedium)
                        ?.copyWith(
                          color: onPrimary.withOpacity(0.95), // soft contrast
                          height: 1.45,
                        ),
              ),
            ),
          ],
        ),
      );
    }

    // ---------- UI tree ----------
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // fill
        children: [
          buildBg(), // animated gradient (primary shades)
          // content: pages + bottom actions
          Column(
            children: [
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl, // controller
                  itemCount: slides.length, // three slides
                  onPageChanged: (i) => setState(() => _index = i), // update
                  itemBuilder: (_, i) => buildSlide(i), // build slide
                ),
              ),
              buildBottomBar(), // actions
            ],
          ),
        ],
      ),
    );
  }
}
