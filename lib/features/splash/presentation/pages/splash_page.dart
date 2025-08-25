import 'package:flutter/material.dart'; // Flutter core
import 'package:shared_preferences/shared_preferences.dart'; // read "seen_onboarding"
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/theme/app_theme.dart'; // AppColors / AppTypography

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final AnimationController _bgPulseCtrl;
  late final Animation<double> _progress;
  double _pageOpacity = 1.0;

  @override
  void initState() {
    super.initState();

    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..forward();

    _progress = CurvedAnimation(parent: _progressCtrl, curve: Curves.easeInOut);

    _bgPulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);

    _progressCtrl.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _pageOpacity = 0.0);
        await Future.delayed(const Duration(milliseconds: 240));
        if (!mounted) return;

        final sp = await SharedPreferences.getInstance();
        final seen = sp.getBool('seen_onboarding') ?? false;

        final next = seen ? '/onboardingScreen' : '/onboarding';
        if (!mounted) return;
        Navigator.pushReplacementNamed(context, next);
      }
    });
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    _bgPulseCtrl.dispose();
    super.dispose();
  }

  Color _adjustLightness(Color c, double delta) {
    final hsl = HSLColor.fromColor(c);
    return hsl.withLightness((hsl.lightness + delta).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final primary = AppColors.primary; // use theme primary
    final lighter = _adjustLightness(primary, 0.14);
    final darker = _adjustLightness(primary, -0.14);

    return Scaffold(
      backgroundColor: AppColors.background, // theme background
      body: AnimatedOpacity(
        opacity: _pageOpacity,
        duration: const Duration(milliseconds: 240),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // ===== Animated Gradient Background =====
            AnimatedBuilder(
              animation: _bgPulseCtrl,
              builder: (context, _) {
                final t = _bgPulseCtrl.value;
                final c1 = Color.lerp(primary, lighter, t)!;
                final c2 = Color.lerp(primary, darker, 1 - t)!;
                final begin = Alignment(-0.8 + t * 0.6, -0.9);
                final end = Alignment(0.8 - t * 0.6, 0.9);
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: begin,
                      end: end,
                      colors: [c1, c2],
                    ),
                  ),
                );
              },
            ),

            // ===== Center Logo + Title =====
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 112,
                    height: 112,
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withOpacity(
                        0.12,
                      ), // from theme
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.onPrimary.withOpacity(0.28),
                        width: 1.4,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.text.withOpacity(0.16),
                          blurRadius: 18,
                          spreadRadius: 2,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.sports_soccer,
                      size: 56,
                      color: AppColors.onPrimary, // theme onPrimary
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    l10n.appTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.onPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.4,
                    ),
                  ),
                ],
              ),
            ),

            // ===== Bottom Progress Bar + Percentage =====
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: AnimatedBuilder(
                animation: _progress,
                builder: (context, _) {
                  final percent = (_progress.value * 100).toInt();
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        "$percent%",
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      LinearProgressIndicator(
                        value: _progress.value,
                        minHeight: 8,
                        backgroundColor: AppColors.onPrimary.withOpacity(0.22),
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary,
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
