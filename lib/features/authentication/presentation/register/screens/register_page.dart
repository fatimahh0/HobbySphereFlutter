// ===== Flutter 3.35.x =====
// Phone-first registration (first screen matches your mock) + l10n-only strings

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/authentication/presentation/register/widgets/interests_grid.dart';
import 'package:image_picker/image_picker.dart';

// l10n + shared widgets
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

// DI: services + repos + usecases
import 'package:hobby_sphere/features/authentication/data/services/registration_service.dart';
import 'package:hobby_sphere/features/authentication/data/repositories/registration_repository_impl.dart';
import 'package:hobby_sphere/features/authentication/data/repositories/interests_repository_impl.dart';

import 'package:hobby_sphere/features/authentication/domain/usecases/register/send_user_verification.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/verify_user_email_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/verify_user_phone_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/complete_user_profile.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/add_user_interests.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/resend_user_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/send_business_verification.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/verify_business_email_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/verify_business_phone_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/complete_business_profile.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/resend_business_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/get_activity_types.dart';

// Bloc
import 'package:hobby_sphere/features/authentication/presentation/register/bloc/register_bloc.dart';
import 'package:hobby_sphere/features/authentication/presentation/register/bloc/register_event.dart';
import 'package:hobby_sphere/features/authentication/presentation/register/bloc/register_state.dart';

// existing login widgets
import 'package:hobby_sphere/features/authentication/presentation/login/widgets/role_selector.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/widgets/phone_input.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/widgets/password_input.dart';

// routes
import 'package:hobby_sphere/app/router/router.dart' show Routes;

// small shared widgets
import '../widgets/login_link.dart';
import '../widgets/guidelines.dart';
import '../widgets/otp_boxes.dart';
import '../widgets/pill_field.dart';
import '../widgets/pick_box.dart';
import '../widgets/divider_with_text.dart';


class RegisterPage extends StatelessWidget {
  final RegistrationService service;
  const RegisterPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final regRepo = RegistrationRepositoryImpl(service);
    final interestsRepo = InterestsRepositoryImpl(service);

    return BlocProvider(
      create: (_) => RegisterBloc(
        sendUserVerification: SendUserVerification(regRepo),
        verifyUserEmail: VerifyUserEmailCode(regRepo),
        verifyUserPhone: VerifyUserPhoneCode(regRepo),
        completeUser: CompleteUserProfile(regRepo),
        addInterests: AddUserInterests(regRepo),
        resendUser: ResendUserCode(regRepo),
        sendBizVerification: SendBusinessVerification(regRepo),
        verifyBizEmail: VerifyBusinessEmailCode(regRepo),
        verifyBizPhone: VerifyBusinessPhoneCode(regRepo),
        completeBiz: CompleteBusinessProfile(regRepo),
        resendBiz: ResendBusinessCode(regRepo),
        getActivityTypes: GetActivityTypes(interestsRepo),
      ),
      child: const _RegisterView(),
    );
  }
}

class _RegisterView extends StatefulWidget {
  const _RegisterView();
  @override
  State<_RegisterView> createState() => _RegisterViewState();
}

class _RegisterViewState extends State<_RegisterView> {
  // password stage
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();

  // otp
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _otpNodes = List.generate(6, (_) => FocusNode());

  // user
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _username = TextEditingController();

  // business
  final _bizName = TextEditingController();
  final _bizDesc = TextEditingController();
  final _bizWebsite = TextEditingController();

  // local ui
  final _picker = ImagePicker();
  bool _pwdObscure = true;
  bool _pwd2Obscure = true;
  bool _rememberMe = true;
  bool _showAllInterests = true;
  String _e164Phone = '';
  bool _phoneStagePassword = false;

  bool _requestedInterests = false;

  @override
  void dispose() {
    _pwd.dispose();
    _pwd2.dispose();
    for (final c in _otpCtrls) c.dispose();
    for (final n in _otpNodes) n.dispose();
    _first.dispose();
    _last.dispose();
    _username.dispose();
    _bizName.dispose();
    _bizDesc.dispose();
    _bizWebsite.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    const bigRadius = 28.0;

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        leading: const BackButton(),
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listenWhen: (p, c) => p != c,
        listener: (context, s) {
          if (s.error?.isNotEmpty == true) {
            showTopToast(
              context,
              s.error!,
              type: ToastType.error,
              haptics: true,
            );
          }
          if (s.info?.isNotEmpty == true) {
            showTopToast(context, s.info!, type: ToastType.info);
          }
          if (s.step == RegStep.done) {
            showTopToast(
              context,
              s.roleIndex == 0
                  ? t.registerSuccessUser
                  : t.registerSuccessBusiness,
              type: ToastType.success,
            );
          }
          if (s.code.length == 6) {
            for (var i = 0; i < 6; i++) _otpCtrls[i].text = s.code[i];
          }
        },
        builder: (context, s) {
          final bloc = context.read<RegisterBloc>();

          final phoneContinueReady =
              !_phoneStagePassword && _e164Phone.isNotEmpty;
          final phoneSignUpReady =
              _phoneStagePassword &&
              _pwd.text.length >= 8 &&
              _pwd.text == _pwd2.text;

          // fetch remote interests on entering that step
          if (s.step == RegStep.interests &&
              !_requestedInterests &&
              !s.interestsLoading &&
              s.interestOptions.isEmpty) {
            _requestedInterests = true;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(RegFetchInterests());
            });
          }

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ===== FIRST SCREEN (all l10n) =====
                      if (s.step == RegStep.contact) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.selectMethodTitle, // "Sign up"
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),

                        // User / Business pills (your RoleSelector widget)
                        Center(
                          child: RoleSelector(
                            value: s.roleIndex,
                            onChanged: (i) => bloc.add(RegRoleChanged(i)),
                            // If your RoleSelector supports custom labels, pass:
                            // userLabel: t.selectMethodRoleUser,
                            // businessLabel: t.selectMethodRoleBusiness,
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Phone input (placeholder handled inside widget; if it accepts, pass the l10n)
                        PhoneInput(
                          initialIso: 'CA',
                          submittedOnce: false,
                          onChanged: (e164, _, __) {
                            setState(() => _e164Phone = e164 ?? '');
                            bloc.add(RegPhoneChanged(e164 ?? ''));
                          },
                          onSwapToEmail: () => Navigator.pushNamed(
                            context,
                            Routes.registerEmail,
                          ),
                          // placeholder: t.selectMethodPhonePlaceholder, // if supported
                        ),

                        const SizedBox(height: 16),

                        AppButton(
                          onPressed: phoneContinueReady
                              ? () => setState(() => _phoneStagePassword = true)
                              : null,
                          label: t.selectMethodContinue, // "Continue"
                          expand: true,
                        ),

                        const SizedBox(height: 16),
                        DividerWithText(text: t.selectMethodOr), // "or"
                        const SizedBox(height: 12),

                        _ProviderButton(
                          icon: Icons.mail_outline,
                          label: t
                              .selectMethodContinueWithEmail, // "Continue with Email"
                          onPressed: () => Navigator.pushNamed(
                            context,
                            Routes.registerEmail,
                          ),
                        ),
                        const SizedBox(height: 12),
                        _ProviderButton(
                          icon: Icons.g_mobiledata, // placeholder G icon
                          label: t
                              .selectMethodContinueWithGoogle, // "Continue with Google"
                          onPressed: () => showTopToast(
                            context,
                            t.globalSuccess,
                          ), // wire your Google SSO here
                        ),
                        const SizedBox(height: 12),
                        _ProviderButton(
                          icon: Icons.facebook,
                          label: t
                              .selectMethodContinueWithFacebook, // "Continue with Facebook"
                          onPressed: () => showTopToast(
                            context,
                            t.globalSuccess,
                          ), // wire your FB SSO here
                        ),

                        const SizedBox(height: 18),
                        const LoginLink(), // uses l10n: alreadyHaveAccount + signIn
                        const SizedBox(height: 8),
                      ],

                      // ===== Stage B: password + Sign Up =====
                      if (s.step == RegStep.contact && _phoneStagePassword) ...[
                        const SizedBox(height: 6),
                        Text(
                          t.selectMethodCreatePassword, // "Create password"
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        PasswordInput(
                          controller: _pwd,
                          obscure: _pwdObscure,
                          onToggleObscure: () =>
                              setState(() => _pwdObscure = !_pwdObscure),
                          onChanged: (_) => setState(() {}),
                        ),
                        const SizedBox(height: 10),
                        AppTextField(
                          controller: _pwd2,
                          label: t.registerConfirmPassword, // reuses l10n
                          hint: t.emailRegistrationPasswordPlaceholder,
                          prefix: const Icon(Icons.lock_outline),
                          suffix: IconButton(
                            icon: Icon(
                              _pwd2Obscure
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () =>
                                setState(() => _pwd2Obscure = !_pwd2Obscure),
                          ),
                          obscure: _pwd2Obscure,
                          textInputAction: TextInputAction.done,
                          borderRadius: 28,
                        ),
                        const SizedBox(height: 10),
                        // This widget already uses l10n (emailRegistrationRule1/2 ...)
                        const Guidelines(),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _rememberMe,
                              onChanged: (v) =>
                                  setState(() => _rememberMe = v ?? true),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            Expanded(
                              child: Text(
                                t.selectMethodSaveInfo, // "Save login info..."
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          onPressed: phoneSignUpReady
                              ? () {
                                  bloc.add(
                                    RegPasswordChanged(_pwd.text.trim()),
                                  );
                                  bloc.add(RegSendVerification());
                                }
                              : null,
                          label: t.selectMethodSignUp, // "Sign Up"
                          expand: true,
                        ),
                        const SizedBox(height: 18),
                        const LoginLink(),
                      ],

                      // ===== OTP =====
                      if (s.step == RegStep.code) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.verifyEnterCode, // "Enter the 6-digit verification code"
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        OtpBoxes(
                          ctrls: _otpCtrls,
                          nodes: _otpNodes,
                          onChanged: (code) => context.read<RegisterBloc>().add(
                            RegCodeChanged(code),
                          ),
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          onPressed: () =>
                              context.read<RegisterBloc>().add(RegVerifyCode()),
                          label: t.verifyVerifyBtn, // "Verify"
                          expand: true,
                        ),
                        const SizedBox(height: 10),
                        AppButton(
                          onPressed: () =>
                              context.read<RegisterBloc>().add(RegResendCode()),
                          type: AppButtonType.outline,
                          label: t.verifyResendBtn, // "Resend Code"
                          expand: true,
                        ),
                      ],

                      // ===== USER: Name =====
                      if (s.step == RegStep.name) ...[
                        const SizedBox(height: 16),
                        Text(
                          t.registerCompleteStep1FirstNameQuestion,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PillField(
                          controller: _first,
                          label: t.registerCompleteStep1FirstName,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegFirstNameChanged(v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        PillField(
                          controller: _last,
                          label: t.registerCompleteStep1LastName,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegLastNameChanged(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.username),
                          ),
                          label: t.registerCompleteButtonsContinue,
                          expand: true,
                        ),
                      ],

                      // ===== USER: Username =====
                      if (s.step == RegStep.username) ...[
                        const SizedBox(height: 16),
                        Text(
                          t.registerCompleteStep2ChooseUsername,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PillField(
                          controller: _username,
                          label: t.registerCompleteStep2Username,
                          helper:
                              '${t.registerCompleteStep2UsernameHint1}\n'
                              '${t.registerCompleteStep2UsernameHint2}\n'
                              '${t.registerCompleteStep2UsernameHint3}',
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegUsernameChanged(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.profile),
                          ),
                          label: t.registerCompleteButtonsContinue,
                          expand: true,
                        ),
                      ],

                      // ===== USER: Profile =====
                      if (s.step == RegStep.profile) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final img = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              context.read<RegisterBloc>().add(
                                RegPickUserImage(img),
                              );
                              showTopToast(
                                context,
                                t.registerAddProfilePhoto,
                                type: ToastType.info,
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none,
                              children: [
                                CircleAvatar(
                                  radius: 56,
                                  backgroundColor: cs.surfaceVariant,
                                  backgroundImage: s.userImage != null
                                      ? Image.file(
                                          File(s.userImage!.path),
                                        ).image
                                      : null,
                                  child: s.userImage == null
                                      ? const Icon(Icons.person, size: 48)
                                      : null,
                                ),
                                if (s.userImage != null)
                                  Positioned(
                                    right: -4,
                                    top: -4,
                                    child: InkWell(
                                      onTap: () => context
                                          .read<RegisterBloc>()
                                          .add(RegPickUserImage(null)),
                                      child: Container(
                                        width: 26,
                                        height: 26,
                                        decoration: BoxDecoration(
                                          color: cs.error,
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: cs.onError,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: s.userPublic,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegUserPublicToggled(v),
                          ),
                          title: Text(t.registerCompleteStep3PublicProfile),
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().add(
                            RegSubmitUserProfile(),
                          ),
                          label: t.registerCompleteButtonsFinish,
                          expand: true,
                        ),
                      ],

                      // ===== USER: Interests (remote + l10n) =====
                      if (s.step == RegStep.interests) ...[
                        if (s.interestsLoading) ...[
                          const SizedBox(height: 24),
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 24),
                        ] else if ((s.interestsError ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              t.interestLoadError, // use generic interest error key
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            onPressed: () => context.read<RegisterBloc>().add(
                              RegFetchInterests(),
                            ),
                            label: t
                                .selectMethodContinue, // closest: “Continue” as retry
                            expand: true,
                          ),
                        ] else ...[
                          InterestsGridRemote(
                            items: s.interestOptions,
                            selected: s.interests,
                            showAll: _showAllInterests,
                            onToggleShow: () => setState(
                              () => _showAllInterests = !_showAllInterests,
                            ),
                            onToggle: (id) => context.read<RegisterBloc>().add(
                              RegToggleInterest(id),
                            ),
                            onSubmit: () => context.read<RegisterBloc>().add(
                              RegSubmitInterests(),
                            ),
                          ),
                        ],
                      ],

                      // ===== BUSINESS: Name / Details / Profile =====
                      if (s.step == RegStep.bizName) ...[
                        const SizedBox(height: 16),
                        Text(
                          t.registerCompleteStep1BusinessName,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        PillField(
                          controller: _bizName,
                          label: t.registerBusinessName,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessNameChanged(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.bizDetails),
                          ),
                          label: t.registerCompleteButtonsContinue,
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.bizDetails) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.registerCompleteStep2BusinessDescription,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        AppTextField(
                          controller: _bizDesc,
                          label: t.registerDescription,
                          maxLines: 4,
                          borderRadius: 18,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessDescChanged(v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.registerCompleteStep2WebsiteUrl,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PillField(
                          controller: _bizWebsite,
                          label: t.registerWebsite,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessWebsiteChanged(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.bizProfile),
                          ),
                          label: t.registerCompleteButtonsContinue,
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.bizProfile) ...[
                        Text(
                          t.registerSelectLogo,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PickBox(
                          label: t.registerSelectLogo,
                          onPick: () async {
                            final img = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            context.read<RegisterBloc>().add(
                              RegPickBusinessLogo(img),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        Text(
                          t.registerSelectBanner,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        PickBox(
                          label: t.registerSelectBanner,
                          onPick: () async {
                            final img = await _picker.pickImage(
                              source: ImageSource.gallery,
                            );
                            context.read<RegisterBloc>().add(
                              RegPickBusinessBanner(img),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().add(
                            RegSubmitBusinessProfile(),
                          ),
                          label: t.registerCompleteButtonsFinish,
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.done) ...[
                        const SizedBox(height: 40),
                        Icon(Icons.check_circle, size: 64, color: cs.primary),
                        const SizedBox(height: 10),
                        Center(
                          child: Text(
                            s.roleIndex == 0
                                ? t.registerSuccessUser
                                : t.registerSuccessBusiness,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                if (s.loading)
                  Container(
                    color: Colors.black.withOpacity(.12),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 10),
                          Text(t.registerCompleteButtonsSubmitting),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ===== Outlined provider button (Email / Google / Facebook) =====
class _ProviderButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback? onPressed;
  const _ProviderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return SizedBox(
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cs.outlineVariant),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: Icon(icon),
        label: Align(alignment: Alignment.centerLeft, child: Text(label)),
      ),
    );
  }
}
