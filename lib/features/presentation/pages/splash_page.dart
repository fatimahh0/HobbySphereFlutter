import 'package:flutter/material.dart'; // Flutter core
import 'package:shared_preferences/shared_preferences.dart'; // local storage
import 'package:hobby_sphere/l10n/app_localizations.dart'
    show AppLocalizations; // i18n
import 'package:hobby_sphere/theme/app_theme.dart'; // AppColors / AppTypography

// OPTIONAL but recommended: use the same TokenStore the login uses
import 'package:hobby_sphere/core/auth/token_store.dart'; // read saved token/role
import 'package:hobby_sphere/core/network/api_client.dart'; // set bearer on app start

class SplashPage extends StatefulWidget {
  const SplashPage({super.key}); // widget ctor

  @override
  State<SplashPage> createState() => _SplashPageState(); // state
}

class _SplashPageState extends State<SplashPage> with TickerProviderStateMixin {
  late final AnimationController _progressCtrl; // controls the bar
  late final AnimationController _bgPulseCtrl; // controls the bg pulse
  late final Animation<double> _progress; // curved progress value
  double _pageOpacity = 1.0; // fade out before navigation

  @override
  void initState() {
    super.initState(); // call parent

    _progressCtrl = AnimationController(
      vsync: this, // ticker
      duration: const Duration(seconds: 3), // total splash time
    )..forward(); // start animation

    _progress = CurvedAnimation(
      parent: _progressCtrl, // base controller
      curve: Curves.easeInOut, // smooth
    );

    _bgPulseCtrl = AnimationController(
      vsync: this, // ticker
      duration: const Duration(milliseconds: 1800), // pulse period
    )..repeat(reverse: true); // loop back & forth

    _progressCtrl.addStatusListener((status) async {
      // listen when done
      if (status == AnimationStatus.completed && mounted) {
        setState(() => _pageOpacity = 0.0); // fade out the page
        await Future.delayed(const Duration(milliseconds: 240)); // tiny wait
        if (!mounted) return; // safety

        // === Decide where to go next ===
        final nextRoute = await _computeNextRoute(); // pick route
        if (!mounted) return; // safety again

        // use removeUntil to clear stack (no back to splash/onboarding)
        Navigator.of(context).pushNamedAndRemoveUntil(nextRoute, (r) => false);
      }
    });
  }

  // Decide the next route based on token + role or onboarding status.
  Future<String> _computeNextRoute() async {
    // ✅ Prefer TokenStore (same as login) so both read/write are identical
    final saved = await TokenStore.read(); // (token, role)
    final token = saved.token; // read token
    // normalize role: lowercase + trim (handles "Business", " BUSINESS "…)
    final role = (saved.role ?? 'user').trim().toLowerCase();

    // If we have a token → set bearer + skip onboarding → go to home by role
    if (token != null && token.trim().isNotEmpty) {
      ApiClient().setToken(token); // ✅ set bearer for first API calls
      return (role == 'business') ? '/business/home' : '/user/home';
    }

    // No token → follow onboarding choice (read once here)
    final sp = await SharedPreferences.getInstance();
    final seen = sp.getBool('seen_onboarding') ?? false; // did user see it?
    // Keep your mapping
    return seen ? '/onboardingScreen' : '/onboarding';
  }

  @override
  void dispose() {
    _progressCtrl.dispose(); // free progress controller
    _bgPulseCtrl.dispose(); // free bg controller
    super.dispose(); // parent
  }

  // Small helper to lighten/darken a color (for the gradient).
  Color _adjustLightness(Color c, double delta) {
    final hsl = HSLColor.fromColor(c); // convert to HSL
    return hsl
        .withLightness((hsl.lightness + delta).clamp(0.0, 1.0)) // clamp range
        .toColor(); // back to Color
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!; // strings
    final primary = AppColors.primary; // brand color
    final lighter = _adjustLightness(primary, 0.14); // lighter tone
    final darker = _adjustLightness(primary, -0.14); // darker tone

    return Scaffold(
      backgroundColor: AppColors.background, // theme background
      body: AnimatedOpacity(
        opacity: _pageOpacity, // fade out before navigation
        duration: const Duration(milliseconds: 240), // fade speed
        child: Stack(
          fit: StackFit.expand, // fill screen
          children: [
            // ===== Animated Gradient Background =====
            AnimatedBuilder(
              animation: _bgPulseCtrl, // listen to pulse
              builder: (context, _) {
                final t = _bgPulseCtrl.value; // 0..1
                final c1 = Color.lerp(primary, lighter, t)!; // color A
                final c2 = Color.lerp(primary, darker, 1 - t)!; // color B
                final begin = Alignment(-0.8 + t * 0.6, -0.9); // start align
                final end = Alignment(0.8 - t * 0.6, 0.9); // end align
                return Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: begin, // gradient start
                      end: end, // gradient end
                      colors: [c1, c2], // two tones
                    ),
                  ),
                );
              },
            ),

            // ===== Center Logo + Title =====
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min, // compact
                children: [
                  Container(
                    width: 112, // circle size
                    height: 112, // circle size
                    decoration: BoxDecoration(
                      color: AppColors.onPrimary.withOpacity(0.12), // soft bg
                      shape: BoxShape.circle, // round
                      border: Border.all(
                        color: AppColors.onPrimary.withOpacity(0.28), // ring
                        width: 1.4, // ring width
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.text.withOpacity(0.16), // shadow
                          blurRadius: 18, // blur
                          spreadRadius: 2, // spread
                          offset: const Offset(0, 6), // drop
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.sports_soccer, // placeholder icon
                      size: 56, // icon size
                      color: AppColors.onPrimary, // contrast color
                    ),
                  ),
                  const SizedBox(height: 18), // space
                  Text(
                    l10n.appTitle, // app title (localized)
                    textAlign: TextAlign.center, // center text
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.onPrimary, // contrast
                      fontWeight: FontWeight.w700, // bold
                      letterSpacing: 0.4, // tracking
                    ),
                  ),
                ],
              ),
            ),

            // ===== Bottom Progress Bar + Percentage =====
            Positioned(
              left: 0, // stretch
              right: 0, // stretch
              bottom: 0, // stick to bottom
              child: AnimatedBuilder(
                animation: _progress, // listen to progress
                builder: (context, _) {
                  final percent = (_progress.value * 100).toInt(); // 0..100
                  return Column(
                    mainAxisSize: MainAxisSize.min, // compact
                    children: [
                      Text(
                        "$percent%", // show percentage
                        style: AppTypography.textTheme.bodyMedium?.copyWith(
                          color: AppColors.onPrimary, // contrast
                          fontWeight: FontWeight.w600, // semi-bold
                        ),
                      ),
                      LinearProgressIndicator(
                        value: _progress.value, // bar value
                        minHeight: 8, // bar height
                        backgroundColor: AppColors.onPrimary.withOpacity(
                          0.22,
                        ), // track
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppColors.onPrimary, // fill
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
