// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart'; // core
import 'package:shared_preferences/shared_preferences.dart'; // remember seen onboarding
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // reusable AppButton

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key}); // constructor

  @override
  State<OnboardingPage> createState() => _OnboardingPageState(); // create state
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController(); // pager controller
  int _index = 0; // current page index

  late final AnimationController _bgCtrl; // background gradient animator

  @override
  void initState() {
    super.initState(); // call parent
    _bgCtrl = AnimationController(
      vsync: this, // ticker
      duration: const Duration(seconds: 8), // slow loop
    )..repeat(reverse: true); // back & forth
  }

  @override
  void dispose() {
    _bgCtrl.dispose(); // free anim
    _pageCtrl.dispose(); // free pager
    super.dispose(); // call parent
  }

  // clamp helper: keep v within [min..max]
  double _clamp(double v, double min, double max) {
    if (v < min) return min; // lower bound
    if (v > max) return max; // upper bound
    return v; // in range
  }

  // lighten/darken color a bit using HSL (for gradient)
  Color _tint(Color c, double delta) {
    final hsl = HSLColor.fromColor(c); // convert to HSL
    final l = (hsl.lightness + delta).clamp(0.0, 1.0); // new lightness
    return hsl.withLightness(l).toColor(); // back to Color
  }

  // mark onboarding as seen in SharedPreferences
  Future<void> _markSeen() async {
    final sp = await SharedPreferences.getInstance(); // prefs
    await sp.setBool('seen_onboarding', true); // save flag
  }

  // primary continue action (after last page)
  Future<void> _continueAsGuest() async {
    await _markSeen(); // set flag
    if (!mounted) return; // safety
    Navigator.pushReplacementNamed(context, '/onboardingScreen'); // go next
  }

  // go to next page or finish if last
  void _next() {
    if (_index < 2) {
      // not last page
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300), // anim dur
        curve: Curves.easeOut, // easing
      );
    } else {
      _continueAsGuest(); // finish onboarding
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // color scheme

    final size = MediaQuery.sizeOf(context); // screen size
    final w = size.width; // width
    final h = size.height; // height

    // responsive paddings / sizes (clamped to keep nice feel)
    final sidePad = _clamp(w * 0.05, 16, 24); // horizontal padding
    final topPad = _clamp(h * 0.02, 8, 20); // top safe space
    final cardDia = _clamp(w * 0.42, 120, 220); // icon circle diameter
    final iconSize = _clamp(w * 0.20, 64, 110); // icon size
    final dotHeight = _clamp(h * 0.010, 8, 10); // dot height
    final dotWidthActive = _clamp(w * 0.06, 20, 28); // active dot width
    final dotWidth = _clamp(w * 0.020, 6, 10); // normal dot width
    final barVPad = _clamp(h * 0.012, 8, 14); // bottom bar vertical padding
    final gapTitle = _clamp(h * 0.035, 22, 40); // gap under circle
    final gapSubtitle = _clamp(h * 0.015, 10, 18); // gap under title
    final gapAfterSubtitle = _clamp(h * 0.004, 6, 10); // tiny bottom gap
    final btnHeight = _clamp(h * 0.058, 44, 52); // right button height
    final radius = _clamp(w * 0.03, 10, 16); // button radius

    // use theme primary based gradient that adapts to light/dark
    final primary = cs.primary; // base primary
    final onPrimary = cs.onPrimary; // contrast color
    final lighter = _tint(primary, 0.16); // lighter shade
    final darker = _tint(primary, -0.12); // darker shade

    // slides content (icons + texts)
    final slides = [
      (icon: Icons.explore, title: t.onbTitle1, subtitle: t.onbSubtitle1),
      (
        icon: Icons.event_available,
        title: t.onbTitle2,
        subtitle: t.onbSubtitle2,
      ),
      (icon: Icons.people_alt, title: t.onbTitle3, subtitle: t.onbSubtitle3),
    ];

    // ---------- animated gradient background ----------
    Widget buildBg() => AnimatedBuilder(
      animation: _bgCtrl, // listen to controller
      builder: (context, _) {
        final v = _bgCtrl.value; // 0..1..0
        final c1 = Color.lerp(primary, lighter, v)!; // blend 1
        final c2 = Color.lerp(primary, darker, 1 - v)!; // blend 2
        final begin = Alignment(-0.9 + v * 0.5, -1.0); // move start
        final end = Alignment(0.9 - v * 0.5, 1.0); // move end
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: begin,
              end: end,
              colors: [c1, c2],
            ), // animated gradient
          ),
        );
      },
    );

    // ---------- dots indicator (responsive) ----------
    Widget buildDots() => Row(
      mainAxisAlignment: MainAxisAlignment.center, // center row
      children: List.generate(slides.length, (i) {
        final active = i == _index; // is current index?
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250), // smooth
          margin: EdgeInsets.symmetric(
            horizontal: _clamp(w * 0.01, 3, 6),
          ), // space
          width: active ? dotWidthActive : dotWidth, // active wider
          height: dotHeight, // height
          decoration: BoxDecoration(
            color: onPrimary.withOpacity(active ? 0.95 : 0.45), // opacity
            borderRadius: BorderRadius.circular(999), // pill
          ),
        );
      }),
    );

    // ---------- bottom bar (uses AppButton + responsive) ----------
    Widget buildBottomBar() {
      final isLast = _index == slides.length - 1; // last page?
      return SafeArea(
        top: false, // only bottom safe
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            sidePad - 4,
            barVPad,
            sidePad - 4,
            barVPad,
          ), // responsive padding
          child: Row(
            children: [
              // SKIP on left (hidden on last page)
              if (!isLast)
                AppButton(
                  onPressed: _continueAsGuest, // skip action
                  type: AppButtonType.text, // text style
                  size: AppButtonSize.md, // medium
                  label: t.onbSkip, // text
                  // make text visible on primary background
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    color: onPrimary, // contrast
                    fontWeight: FontWeight.w600, // semi-bold
                  ),
                )
              else
                SizedBox(width: _clamp(w * 0.02, 8, 12)), // keep layout aligned
              // DOTS in center
              Expanded(child: buildDots()), // dots grow
              // NEXT / GET STARTED button on right
              SizedBox(
                height: btnHeight, // responsive height
                child: AppButton(
                  onPressed: _next, // next or finish
                  type: AppButtonType.secondary, // neutral on top of primary bg
                  size: AppButtonSize.md, // medium
                  label: isLast ? t.onbGetStarted : t.onbNext, // dynamic text
                  // override to fit neutral chip look
                  borderRadius: radius, // responsive radius
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ---------- single slide (responsive sizes) ----------
    Widget buildSlide(int i) {
      final s = slides[i]; // slide tuple
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePad), // responsive sides
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // center slide
          children: [
            // circular card with main icon (scale-in)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1.0), // small pop
              duration: const Duration(milliseconds: 400), // fast
              curve: Curves.easeOut, // ease
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child), // apply scale
              child: Container(
                width: cardDia, // responsive diameter
                height: cardDia, // responsive diameter
                decoration: BoxDecoration(
                  color: onPrimary.withOpacity(0.15), // soft fill
                  shape: BoxShape.circle, // circle
                  border: Border.all(
                    color: onPrimary.withOpacity(0.25),
                    width: 2,
                  ), // subtle ring
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.25), // soft shadow
                      blurRadius: _clamp(w * 0.06, 16, 26), // blur responsive
                      offset: const Offset(0, 8), // drop
                    ),
                  ],
                ),
                child: Icon(
                  s.icon,
                  size: iconSize,
                  color: onPrimary,
                ), // responsive icon
              ),
            ),

            SizedBox(height: gapTitle), // gap under circle
            // Title (fade-in)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1), // fade
              duration: const Duration(milliseconds: 350), // fast
              curve: Curves.easeOut, // ease
              builder: (_, o, child) =>
                  Opacity(opacity: o, child: child), // apply fade
              child: Text(
                s.title, // title text
                textAlign: TextAlign.center, // center
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: onPrimary, // contrast on primary bg
                  fontWeight: FontWeight.w700, // bold
                  letterSpacing: 0.3, // tiny tracking
                  fontSize: _clamp(w * 0.055, 18, 24), // responsive title size
                ),
              ),
            ),

            SizedBox(height: gapSubtitle), // gap
            // Subtitle (fade-in)
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1), // fade
              duration: const Duration(milliseconds: 450), // slower
              curve: Curves.easeOut, // ease
              builder: (_, o, child) =>
                  Opacity(opacity: o, child: child), // apply fade
              child: Text(
                s.subtitle, // subtitle text
                textAlign: TextAlign.center, // center
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onPrimary.withOpacity(0.95), // almost white
                  height: 1.45, // line height
                  fontSize: _clamp(
                    w * 0.04,
                    13,
                    16,
                  ), // responsive subtitle size
                ),
              ),
            ),

            SizedBox(height: gapAfterSubtitle), // tiny gap
          ],
        ),
      );
    }

    // ---------- UI tree ----------
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, // fill screen
        children: [
          buildBg(), // animated primary gradient
          Column(
            children: [
              SizedBox(height: topPad), // top breathing
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl, // controller
                  itemCount: slides.length, // 3 slides
                  onPageChanged: (i) =>
                      setState(() => _index = i), // update index
                  itemBuilder: (_, i) => buildSlide(i), // slide builder
                ),
              ),
              buildBottomBar(), // responsive bottom bar with AppButton
            ],
          ),
        ],
      ),
    );
  }
}
