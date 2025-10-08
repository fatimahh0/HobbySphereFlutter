// ===== Flutter 3.35.x =====
// lib/features/activities/common/presentation/onboarding_page.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ GoRouter
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/app/router/router.dart'
    show Routes; // ✅ route names

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});
  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage>
    with SingleTickerProviderStateMixin {
  final PageController _pageCtrl = PageController();
  int _index = 0;

  late final AnimationController _bgCtrl;

  @override
  void initState() {
    super.initState();
    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _bgCtrl.dispose();
    _pageCtrl.dispose();
    super.dispose();
  }

  double _clamp(double v, double min, double max) =>
      v < min ? min : (v > max ? max : v);

  Color _tint(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  Future<void> _markSeen() async {
    final sp = await SharedPreferences.getInstance();
    await sp.setBool('seen_onboarding', true);
  }

  Future<void> _continueAsGuest() async {
    await _markSeen();
    if (!mounted) return;
    // ✅ GoRouter navigation by name (no Navigator.pushReplacementNamed)
    context.goNamed(Routes.onboardingScreen);
  }

  void _next() {
    if (_index < 2) {
      _pageCtrl.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else {
      _continueAsGuest();
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;

    final sidePad = _clamp(w * 0.05, 16, 24);
    final topPad = _clamp(h * 0.02, 8, 20);
    final cardDia = _clamp(w * 0.42, 120, 220);
    final iconSize = _clamp(w * 0.20, 64, 110);
    final dotHeight = _clamp(h * 0.010, 8, 10);
    final dotWidthActive = _clamp(w * 0.06, 20, 28);
    final dotWidth = _clamp(w * 0.020, 6, 10);
    final barVPad = _clamp(h * 0.012, 8, 14);
    final gapTitle = _clamp(h * 0.035, 22, 40);
    final gapSubtitle = _clamp(h * 0.015, 10, 18);
    final gapAfterSubtitle = _clamp(h * 0.004, 6, 10);
    final btnHeight = _clamp(h * 0.058, 44, 52);
    final radius = _clamp(w * 0.03, 10, 16);

    final primary = cs.primary;
    final onPrimary = cs.onPrimary;
    final lighter = _tint(primary, 0.16);
    final darker = _tint(primary, -0.12);

    final slides = [
      (icon: Icons.explore, title: t.onbTitle1, subtitle: t.onbSubtitle1),
      (
        icon: Icons.event_available,
        title: t.onbTitle2,
        subtitle: t.onbSubtitle2,
      ),
      (icon: Icons.people_alt, title: t.onbTitle3, subtitle: t.onbSubtitle3),
    ];

    Widget buildBg() => AnimatedBuilder(
      animation: _bgCtrl,
      builder: (context, _) {
        final v = _bgCtrl.value;
        final c1 = Color.lerp(primary, lighter, v)!;
        final c2 = Color.lerp(primary, darker, 1 - v)!;
        final begin = Alignment(-0.9 + v * 0.5, -1.0);
        final end = Alignment(0.9 - v * 0.5, 1.0);
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(begin: begin, end: end, colors: [c1, c2]),
          ),
        );
      },
    );

    Widget buildDots() => Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(slides.length, (i) {
        final active = i == _index;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          margin: EdgeInsets.symmetric(horizontal: _clamp(w * 0.01, 3, 6)),
          width: active ? dotWidthActive : dotWidth,
          height: dotHeight,
          decoration: BoxDecoration(
            color: onPrimary.withOpacity(active ? 0.95 : 0.45),
            borderRadius: BorderRadius.circular(999),
          ),
        );
      }),
    );

    Widget buildBottomBar() {
      final isLast = _index == slides.length - 1;
      return SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            sidePad - 4,
            barVPad,
            sidePad - 4,
            barVPad,
          ),
          child: Row(
            children: [
              if (!isLast)
                AppButton(
                  onPressed: _continueAsGuest,
                  type: AppButtonType.text,
                  size: AppButtonSize.md,
                  label: t.onbSkip,
                  textStyle: theme.textTheme.labelLarge?.copyWith(
                    color: onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )
              else
                SizedBox(width: _clamp(w * 0.02, 8, 12)),
              Expanded(child: buildDots()),
              SizedBox(
                height: btnHeight,
                child: AppButton(
                  onPressed: _next,
                  type: AppButtonType.secondary,
                  size: AppButtonSize.md,
                  label: isLast ? t.onbGetStarted : t.onbNext,
                  borderRadius: radius,
                ),
              ),
            ],
          ),
        ),
      );
    }

    Widget buildSlide(int i) {
      final s = slides[i];
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: sidePad),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.92, end: 1.0),
              duration: const Duration(milliseconds: 400),
              curve: Curves.easeOut,
              builder: (_, scale, child) =>
                  Transform.scale(scale: scale, child: child),
              child: Container(
                width: cardDia,
                height: cardDia,
                decoration: BoxDecoration(
                  color: onPrimary.withOpacity(0.15),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: onPrimary.withOpacity(0.25),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: theme.shadowColor.withOpacity(0.25),
                      blurRadius: _clamp(w * 0.06, 16, 26),
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(s.icon, size: iconSize, color: onPrimary),
              ),
            ),
            SizedBox(height: gapTitle),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOut,
              builder: (_, o, child) => Opacity(opacity: o, child: child),
              child: Text(
                s.title,
                textAlign: TextAlign.center,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: onPrimary,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  fontSize: _clamp(w * 0.055, 18, 24),
                ),
              ),
            ),
            SizedBox(height: gapSubtitle),
            TweenAnimationBuilder<double>(
              tween: Tween(begin: 0, end: 1),
              duration: const Duration(milliseconds: 450),
              curve: Curves.easeOut,
              builder: (_, o, child) => Opacity(opacity: o, child: child),
              child: Text(
                s.subtitle,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: onPrimary.withOpacity(0.95),
                  height: 1.45,
                  fontSize: _clamp(w * 0.04, 13, 16),
                ),
              ),
            ),
            SizedBox(height: gapAfterSubtitle),
          ],
        ),
      );
    }

    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          buildBg(),
          Column(
            children: [
              SizedBox(height: topPad),
              Expanded(
                child: PageView.builder(
                  controller: _pageCtrl,
                  itemCount: slides.length,
                  onPageChanged: (i) => setState(() => _index = i),
                  itemBuilder: (_, i) => buildSlide(i),
                ),
              ),
              buildBottomBar(),
            ],
          ),
        ],
      ),
    );
  }
}
