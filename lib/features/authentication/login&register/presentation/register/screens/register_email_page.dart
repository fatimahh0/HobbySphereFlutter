// ===== Flutter 3.35.x =====
// Email registration screen with remote interests (all strings from l10n)

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/widgets/password_input.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_bloc.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_event.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_state.dart';
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/widgets/interests_grid.dart';

import 'package:image_picker/image_picker.dart';

// l10n + shared
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

// DI (service + repos + usecases)
import 'package:hobby_sphere/features/authentication/login&register/data/services/registration_service.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/registration_repository_impl.dart';
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/interests_repository_impl.dart';

import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/send_user_verification.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_user_email_code.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_user_phone_code.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/complete_user_profile.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/add_user_interests.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/resend_user_code.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/send_business_verification.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_business_email_code.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_business_phone_code.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/complete_business_profile.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/resend_business_code.dart';
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/get_activity_types.dart';

// Bloc


// Small widgets
import '../widgets/login_link.dart';
import '../widgets/guidelines.dart';
import '../widgets/otp_boxes.dart';
import '../widgets/pill_field.dart';
import '../widgets/pick_box.dart';


class RegisterEmailPage extends StatelessWidget {
  final RegistrationService service;
  final int initialRoleIndex; // 0=user, 1=business

  const RegisterEmailPage({
    super.key,
    required this.service,
    this.initialRoleIndex = 0,
  });

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
      )..add(RegRoleChanged(initialRoleIndex)),
      child: const _RegisterEmailView(),
    );
  }
}

class _RegisterEmailView extends StatefulWidget {
  const _RegisterEmailView();

  @override
  State<_RegisterEmailView> createState() => _RegisterEmailViewState();
}

class _RegisterEmailViewState extends State<_RegisterEmailView> {
  // Contact + password controllers
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();

  // OTP controllers/nodes
  final _otpCtrls = List.generate(6, (_) => TextEditingController());
  final _otpNodes = List.generate(6, (_) => FocusNode());

  // User profile controllers
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _username = TextEditingController();

  // Business profile controllers
  final _bizName = TextEditingController();
  final _bizDesc = TextEditingController();
  final _bizWebsite = TextEditingController();

  // Local UI state
  final _picker = ImagePicker();
  bool _stagePassword = false;
  bool _pwdObscure = true;
  bool _pwd2Obscure = true;
  bool _newsletterOptIn = false;
  bool _showAllInterests = true;

  bool _requestedInterests = false; // fire once on interests step

  @override
  void initState() {
    super.initState();
    // ensure EMAIL method
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<RegisterBloc>();
      if (bloc.state.usePhone) {
        bloc.add(RegToggleMethod());
      }
    });
    _pwd.addListener(() => setState(() {}));
    _pwd2.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _email.dispose();
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

  bool _isValidEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final emailReady = _isValidEmail(_email.text);
    final signUpReady =
        emailReady && _pwd.text.length >= 8 && _pwd.text == _pwd2.text;

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
            final msg = s.roleIndex == 0
                ? t.registerSuccessUser
                : t.registerSuccessBusiness;
            showTopToast(context, msg, type: ToastType.success);
          }
          if (s.code.length == 6) {
            for (int i = 0; i < 6; i++) {
              _otpCtrls[i].text = s.code[i];
            }
          }
        },
        builder: (context, s) {
          final bloc = context.read<RegisterBloc>();

          // interests auto-fetch
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
                      // Title switches between “enter email” and “create account”
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Text(
                          (!_stagePassword && s.step == RegStep.contact)
                              ? t.emailRegistrationEnterEmail
                              : t.registerTitle,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // ===== CONTACT (EMAIL) =====
                      if (s.step == RegStep.contact) ...[
                        if (!_stagePassword) ...[
                          AppTextField(
                            controller: _email,
                            label: t.emailRegistrationEmailPlaceholder,
                            hint: t.emailRegistrationEmailPlaceholder,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            borderRadius: 28,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            t.emailRegistrationEmailDesc,
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            onPressed: emailReady
                                ? () => setState(() => _stagePassword = true)
                                : null,
                            label: t.emailRegistrationContinue,
                            expand: true,
                          ),
                          const SizedBox(height: 12),
                          const LoginLink(),
                        ] else ...[
                          // ===== PASSWORD STAGE =====
                          Text(
                            t.emailRegistrationCreatePassword,
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
                          ),
                          const SizedBox(height: 10),
                          AppTextField(
                            controller: _pwd2,
                            label: t.registerConfirmPassword,
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
                          const Guidelines(),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Checkbox(
                                value: _newsletterOptIn,
                                onChanged: (v) => setState(
                                  () => _newsletterOptIn = v ?? false,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ),
                              ),
                              Expanded(
                                child: Text(
                                  t.emailRegistrationSaveInfo,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          AppButton(
                            onPressed: signUpReady
                                ? () {
                                    if (!_isValidEmail(_email.text)) {
                                      showTopToast(
                                        context,
                                        t.emailRegistrationErrorGeneric,
                                        type: ToastType.error,
                                        haptics: true,
                                      );
                                      return;
                                    }
                                    if (s.usePhone)
                                      bloc.add(
                                        RegToggleMethod(),
                                      ); // ensure email mode
                                    bloc
                                      ..add(RegEmailChanged(_email.text.trim()))
                                      ..add(
                                        RegPasswordChanged(_pwd.text.trim()),
                                      )
                                      ..add(RegSendVerification());
                                  }
                                : null,
                            label: t.emailRegistrationSignUp,
                            expand: true,
                          ),
                          const SizedBox(height: 12),
                          const LoginLink(),
                        ],
                      ],

                      // ===== OTP =====
                      if (s.step == RegStep.code) ...[
                        const SizedBox(height: 12),
                        Text(
                          t.emailRegistrationVerificationSent, // "Verification code sent…"
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

                      // ===== USER: NAME =====
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

                      // ===== USER: USERNAME =====
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

                      // ===== USER: PROFILE =====
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

                      // ===== USER: INTERESTS (remote) =====
                      if (s.step == RegStep.interests) ...[
                        if (s.interestsLoading) ...[
                          const SizedBox(height: 24),
                          const Center(child: CircularProgressIndicator()),
                          const SizedBox(height: 24),
                        ] else if ((s.interestsError ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Center(
                            child: Text(
                              t.interestLoadError,
                              textAlign: TextAlign.center,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            onPressed: () => context.read<RegisterBloc>().add(
                              RegFetchInterests(),
                            ),
                            label: t.buttonsContinue, // generic retry text
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

                      // ===== BUSINESS: NAME =====
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

                      // ===== BUSINESS: DETAILS =====
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

                      // ===== BUSINESS: PROFILE =====
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

                      // ===== DONE =====
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

                // Loading overlay
                if (context.watch<RegisterBloc>().state.loading)
                  Container(
                    color: Colors.black.withOpacity(.12),
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(),
                          const SizedBox(height: 10),
                          Text(t.emailRegistrationLoading),
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
