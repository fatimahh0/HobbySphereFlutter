// ===== Flutter 3.35.x =====
import 'package:flutter/material.dart';
import 'package:hobby_sphere/theme/app_theme.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart' show AppLocalizations;

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

    // Phase 1: soft fade + scale in
    _introCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _opacity = CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutCubic);

    _scale = Tween<double>(
      begin: 0.96,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _introCtrl, curve: Curves.easeOutBack));

    // Phase 2: gentle breathing float (infinite)
    _floatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
      lowerBound: 0,
      upperBound: 1,
    )..repeat(reverse: true);

    _yOffset = Tween<double>(
      begin: -6,
      end: 6,
    ).animate(CurvedAnimation(parent: _floatCtrl, curve: Curves.easeInOut));

    // kickoff intro
    _introCtrl.forward();
  }

  @override
  void dispose() {
    _introCtrl.dispose();
    _floatCtrl.dispose();
    super.dispose();
  }

  void _openLanguageSheet(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        Widget tile(String code, String name, Locale locale) {
          final selected = widget.currentLocale?.languageCode == code;
          return ListTile(
            title: Text(name, style: AppTypography.textTheme.bodyMedium),
            trailing: selected
                ? Icon(Icons.check, color: AppColors.primary)
                : null,
            onTap: () {
              Navigator.pop(ctx);
              if (widget.onChangeLocale != null) widget.onChangeLocale!(locale);
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
                  color: AppColors.muted.withOpacity(0.35),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.selectLanguage,
                style: AppTypography.textTheme.titleMedium,
              ),
              const SizedBox(height: 4),
              Divider(color: AppColors.muted.withOpacity(0.2)),
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
    final code = (widget.currentLocale?.languageCode ?? 'en').toUpperCase();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // soft brand gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.primary.withOpacity(0.12),
                  AppColors.primary.withOpacity(0.02),
                ],
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // top actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton.icon(
                        style: TextButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: AppColors.onPrimary,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                          elevation: 0,
                        ),
                        onPressed: widget.onToggleTheme,
                        icon: const Icon(Icons.brightness_6, size: 18),
                        label: Text(l10n.changeTheme),
                      ),
                      OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          backgroundColor: AppColors.background,
                          foregroundColor: AppColors.text,
                          side: BorderSide(
                            color: AppColors.muted.withOpacity(0.4),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(28),
                          ),
                        ),
                        onPressed: () => _openLanguageSheet(context),
                        icon: const Icon(Icons.translate, size: 18),
                        label: Text(' $code '),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  // ===== IMAGE ONLY (no border, no card), animated =====
                  Expanded(
                    child: Center(
                      child: AnimatedBuilder(
                        animation: Listenable.merge([_introCtrl, _floatCtrl]),
                        builder: (context, _) {
                          return Opacity(
                            opacity: _opacity.value,
                            child: Transform.translate(
                              offset: Offset(0, _yOffset.value),
                              child: Transform.scale(
                                scale: _scale.value,
                                child: Hero(
                                  tag: 'onboarding-illustration',
                                  // If you want rounded corners without borders, keep ClipRRect.
                                  // Remove ClipRRect if you want *perfectly* raw edges.
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(18),
                                    child: AspectRatio(
                                      aspectRatio: 16 / 11,
                                      child: Image.asset(
                                        'assets/images/Onboarding.png',
                                        fit: BoxFit.cover,
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

                  const SizedBox(height: 12),

                  // title
                  Text(
                    l10n.onboardingTitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.headlineSmall?.copyWith(
                      color: AppColors.text,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.2,
                    ),
                  ),

                  const SizedBox(height: 8),

                  // subtitle
                  Text(
                    l10n.onboardingSubtitle,
                    textAlign: TextAlign.center,
                    style: AppTypography.textTheme.bodyMedium?.copyWith(
                      color: AppColors.muted,
                      height: 1.35,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // CTA
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: AppColors.onPrimary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 3,
                        shadowColor: AppColors.primary.withOpacity(0.35),
                      ),
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      child: Text(
                        l10n.onboardingGetStarted,
                        style: AppTypography.textTheme.titleMedium,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextButton(
                    onPressed: () =>
                        Navigator.pushReplacementNamed(context, '/login'),
                    child: Text(
                      l10n.onboardingAlreadyHaveAccount,
                      style: AppTypography.textTheme.bodyMedium?.copyWith(
                        color: AppColors.text,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
