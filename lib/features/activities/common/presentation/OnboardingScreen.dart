// ===== Flutter 3.35.x =====
// lib/features/activities/common/presentation/onboarding_screen.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart'; // ✅ go_router
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;
import 'package:hobby_sphere/shared/widgets/app_button.dart';

// App routes + args
import 'package:hobby_sphere/app/router/router.dart'
    show Routes, ShellRouteArgs;
import 'package:hobby_sphere/core/constants/app_role.dart';

class OnboardingScreen extends StatefulWidget {
  final VoidCallback? onToggleTheme;
  final void Function(Locale locale)? onChangeLocale;
  final Locale? currentLocale;

  const OnboardingScreen({
    super.key,
    this.onToggleTheme,
    this.onChangeLocale,
    this.currentLocale,
  });

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  late final AnimationController _introCtrl;
  late final AnimationController _floatCtrl;
  late final Animation<double> _opacity;
  late final Animation<double> _scale;
  late final Animation<double> _yOffset;

  @override
  void initState() {
    super.initState();
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _opacity = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic);
    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutBack));
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    )..repeat(reverse: true);
    _yOffset = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));
    _introCtrl.forward();
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _openLanguageSheet(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        Widget tile(String code, String name, Locale locale) {
          final selected = widget.currentLocale?.languageCode == code;
          return ListTile(
            title: Text(name, style: theme.textTheme.bodyMedium),
            trailing: selected ? Icon(Icons.check, color: cs.primary) : null,
            onTap: () {
              Navigator.pop(ctx);
              widget.onChangeLocale?.call(locale);
            },
          );
        }

        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: cs.outlineVariant.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Text(l10n.selectLanguage, style: theme.textTheme.titleMedium),
              const SizedBox(height: 4),
              Divider(color: cs.outlineVariant),
              tile('en', 'English', const Locale('en')),
              tile('ar', 'العربية', const Locale('ar')),
              tile('fr', 'Français', const Locale('fr')),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final code = (widget.currentLocale?.languageCode ?? 'en').toUpperCase();

    final size = MediaQuery.sizeOf(context);
    final w = size.width;
    final h = size.height;
    double clamp(double v, double min, double max) =>
        v < min ? min : (v > max ? max : v);

    final horizontal = clamp(w * 0.05, 16, 24);
    final topGap = clamp(h * 0.02, 8, 20);
    final imageUpShift = clamp(h * 0.06, 28, 56);
    final ctaGap = clamp(h * 0.025, 16, 28);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  cs.primary.withOpacity(0.12),
                  cs.primary.withOpacity(0.02),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: horizontal),
              child: Column(
                children: [
                  SizedBox(height: topGap),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      AppButton(
                        onPressed: widget.onToggleTheme,
                        type: AppButtonType.secondary,
                        size: AppButtonSize.sm,
                        leading: Icon(
                          isDark ? Icons.dark_mode : Icons.light_mode,
                          size: 18,
                        ),
                        label:
                            '${l10n.changeTheme} • ${isDark ? "Dark" : "Light"}',
                      ),
                      AppButton(
                        onPressed: () => _openLanguageSheet(context),
                        type: AppButtonType.outline,
                        size: AppButtonSize.sm,
                        leading: const Icon(Icons.translate, size: 18),
                        label: ' $code ',
                      ),
                    ],
                  ),
                  SizedBox(height: clamp(h * 0.03, 18, 36)),
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: EdgeInsets.only(bottom: imageUpShift),
                        child: AnimatedBuilder(
                          animation: Listenable.merge([_introCtrl, _floatCtrl]),
                          builder: (context, _) {
                            final hh = MediaQuery.sizeOf(context).height;
                            return Opacity(
                              opacity: _opacity.value,
                              child: Transform.translate(
                                offset: Offset(0, _yOffset.value),
                                child: Transform.scale(
                                  scale: _scale.value,
                                  child: Hero(
                                    tag: 'onboarding-illustration',
                                    child: SizedBox(
                                      height: clamp(hh * 0.34, 240, 420),
                                      width: double.infinity,
                                      child: FittedBox(
                                        fit: BoxFit.contain,
                                        alignment: Alignment.center,
                                        child: Image.asset(
                                          'assets/images/Onboarding.png',
                                          filterQuality: FilterQuality.high,
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
                  SizedBox(height: clamp(h * 0.005, 6, 12)),
                  Text(
                    l10n.onboardingTitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),
                  SizedBox(height: clamp(h * 0.008, 6, 12)),
                  Text(
                    l10n.onboardingSubtitle,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.textTheme.bodyMedium?.color?.withOpacity(
                        0.75,
                      ),
                      height: 1.35,
                    ),
                  ),
                  SizedBox(height: ctaGap),

                  // ✅ Get Started → go to SHELL in guest mode using go_router
                  AppButton(
                    onPressed: () {
                      context.goNamed(
                        Routes.shell,
                        extra: ShellRouteArgs(
                          role: AppRole.user,
                          token: '', // '' => guest mode
                          businessId: 0,
                        ),
                      );
                    },
                    type: AppButtonType.primary,
                    size: AppButtonSize.lg,
                    expand: true,
                    label: l10n.onboardingGetStarted,
                  ),

                  SizedBox(height: clamp(h * 0.012, 8, 16)),

                  // ✅ Already have an account? → Login route by name
                  AppButton(
                    onPressed: () => context.goNamed(Routes.login),
                    type: AppButtonType.text,
                    label: l10n.onboardingAlreadyHaveAccount,
                  ),

                  SizedBox(height: clamp(h * 0.01, 6, 12)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
