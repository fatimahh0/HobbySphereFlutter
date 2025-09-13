import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// l10n + shared widgets
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

// DI wiring
import 'package:hobby_sphere/features/authentication/data/services/registration_service.dart';
import 'package:hobby_sphere/features/authentication/data/repositories/registration_repository_impl.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/send_user_verification.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/verify_user_email_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/verify_user_phone_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/complete_user_profile.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/add_user_interests.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/resend_user_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/send_business_verification.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/verify_business_email_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/verify_business_phone_code.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/complete_business_profile.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/resend_business_code.dart';

// BLoC
import 'package:hobby_sphere/features/authentication/presentation/register/bloc/register_bloc.dart';
import 'package:hobby_sphere/features/authentication/presentation/register/bloc/register_event.dart';
import 'package:hobby_sphere/features/authentication/presentation/register/bloc/register_state.dart';

// field widgets you already have (updated below for onChanged support)
import 'package:hobby_sphere/features/authentication/presentation/login/widgets/role_selector.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/widgets/phone_input.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/widgets/email_input.dart';
import 'package:hobby_sphere/features/authentication/presentation/login/widgets/password_input.dart';

class RegisterPage extends StatelessWidget {
  final RegistrationService service;
  const RegisterPage({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    final repo = RegistrationRepositoryImpl(service);
    return BlocProvider(
      create: (_) => RegisterBloc(
        sendUserVerification: SendUserVerification(repo),
        verifyUserEmail: VerifyUserEmailCode(repo),
        verifyUserPhone: VerifyUserPhoneCode(repo),
        completeUser: CompleteUserProfile(repo),
        addInterests: AddUserInterests(repo),
        resendUser: ResendUserCode(repo),
        sendBizVerification: SendBusinessVerification(repo),
        verifyBizEmail: VerifyBusinessEmailCode(repo),
        verifyBizPhone: VerifyBusinessPhoneCode(repo),
        completeBiz: CompleteBusinessProfile(repo),
        resendBiz: ResendBusinessCode(repo),
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
  // contact step
  final _email = TextEditingController();
  final _pwd = TextEditingController();
  final _pwd2 = TextEditingController();
  final _code = TextEditingController();

  // user steps
  final _first = TextEditingController();
  final _last = TextEditingController();
  final _username = TextEditingController();

  // business steps
  final _bizName = TextEditingController();
  final _bizDesc = TextEditingController();
  final _bizWebsite = TextEditingController();

  final _picker = ImagePicker();
  bool _showAllInterests = true;
  bool _pwdObscure = true;
  bool _pwd2Obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _pwd.dispose();
    _pwd2.dispose();
    _code.dispose();
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
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: Text(t.registerTitle)),
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
        },
        builder: (context, s) {
          final bloc = context.read<RegisterBloc>();
          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 8),
                      Center(
                        child: RoleSelector(
                          value: s.roleIndex,
                          onChanged: (i) => bloc.add(RegRoleChanged(i)),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ================== Step: Contact ==================
                      if (s.step == RegStep.contact) ...[
                        if (s.usePhone)
                          PhoneInput(
                            initialIso: 'CA',
                            submittedOnce: false,
                            onChanged: (e164, _, __) =>
                                bloc.add(RegPhoneChanged(e164)),
                            onSwapToEmail: () => bloc.add(RegToggleMethod()),
                          )
                        else
                          EmailInput(
                            controller: _email,
                            validator: (_) => null,
                            onSwapToPhone: () => bloc.add(RegToggleMethod()),
                            onChanged: (v) => bloc.add(RegEmailChanged(v)),
                          ),

                        const SizedBox(height: 12),

                        // Password
                        PasswordInput(
                          controller: _pwd,
                          obscure: _pwdObscure,
                          onToggleObscure: () =>
                              setState(() => _pwdObscure = !_pwdObscure),
                          onChanged: (v) => bloc.add(RegPasswordChanged(v)),
                        ),

                        const SizedBox(height: 10),

                        // Confirm password
                        AppTextField(
                          controller: _pwd2,
                          label: t.registerConfirmPassword,
                          hint: t.registerConfirmPassword,
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
                          borderRadius: 22,
                        ),

                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () {
                            if (!s.usePhone && _email.text.trim().isEmpty) {
                              showTopToast(
                                context,
                                t.registerErrorRequired,
                                type: ToastType.error,
                                haptics: true,
                              );
                              return;
                            }
                            if (_pwd.text.length < 8) {
                              showTopToast(
                                context,
                                t.registerErrorLength,
                                type: ToastType.error,
                                haptics: true,
                              );
                              return;
                            }
                            if (_pwd.text != _pwd2.text) {
                              showTopToast(
                                context,
                                t.registerErrorMatch,
                                type: ToastType.error,
                                haptics: true,
                              );
                              return;
                            }
                            bloc
                              ..add(RegPasswordChanged(_pwd.text.trim()))
                              ..add(RegEmailChanged(_email.text.trim()))
                              ..add(RegSendVerification());
                          },
                          label: t.registerSendCode,
                          expand: true,
                        ),
                      ],

                      // ================== Step: Code (OTP) ==================
                      if (s.step == RegStep.code) ...[
                        const SizedBox(height: 6),
                        Center(
                          child: Text(
                            'Enter the 6-digit verification code',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppTextField(
                          controller: _code,
                          keyboardType: TextInputType.number,
                          textInputAction: TextInputAction.done,
                          maxLength: 6,
                          label: 'OTP',
                          hint: '------',
                          textDirection: TextDirection.ltr,
                          onChanged: (v) => bloc.add(RegCodeChanged(v)),
                          borderRadius: 20,
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          onPressed: () => bloc.add(RegVerifyCode()),
                          label: t.registerCompleteButtonsContinue,
                          expand: true,
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          onPressed: () => bloc.add(RegResendCode()),
                          type: AppButtonType.outline,
                          label: t.registerSendCode,
                          expand: true,
                        ),
                      ],

                      // ==================== USER FLOW ====================
                      if (s.step == RegStep.name) ...[
                        _label(t.registerCompleteStep1FirstName),
                        AppTextField(
                          controller: _first,
                          label: t.registerCompleteStep1FirstName,
                          onChanged: (v) => bloc.add(RegFirstNameChanged(v)),
                          borderRadius: 22,
                        ),
                        const SizedBox(height: 12),
                        _label(t.registerCompleteStep1LastName),
                        AppTextField(
                          controller: _last,
                          label: t.registerCompleteStep1LastName,
                          onChanged: (v) => bloc.add(RegLastNameChanged(v)),
                          borderRadius: 22,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () {
                            if (_first.text.trim().isEmpty) {
                              showTopToast(
                                context,
                                t.registerCompleteErrorsFirstNameRequired,
                                type: ToastType.error,
                                haptics: true,
                              );
                              return;
                            }
                            if (_last.text.trim().isEmpty) {
                              showTopToast(
                                context,
                                t.registerCompleteErrorsLastNameRequired,
                                type: ToastType.error,
                                haptics: true,
                              );
                              return;
                            }
                            context.read<RegisterBloc>().emit(
                              s.copyWith(step: RegStep.username),
                            );
                          },
                          label: t.registerCompleteButtonsContinue,
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.username) ...[
                        _label(t.registerCompleteStep2ChooseUsername),
                        AppTextField(
                          controller: _username,
                          label: t.registerCompleteStep2Username,
                          helper:
                              '${t.registerCompleteStep2UsernameHint1}\n${t.registerCompleteStep2UsernameHint2}\n${t.registerCompleteStep2UsernameHint3}',
                          onChanged: (v) => bloc.add(RegUsernameChanged(v)),
                          borderRadius: 22,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () {
                            if (_username.text.trim().isEmpty) {
                              showTopToast(
                                context,
                                t.registerCompleteErrorsUsernameRequired,
                                type: ToastType.error,
                                haptics: true,
                              );
                              return;
                            }
                            context.read<RegisterBloc>().emit(
                              s.copyWith(step: RegStep.profile),
                            );
                          },
                          label: t.registerCompleteButtonsContinue,
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.profile) ...[
                        const SizedBox(height: 8),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final img = await _picker.pickImage(
                                source: ImageSource.gallery,
                              );
                              context.read<RegisterBloc>().add(
                                RegPickUserImage(img),
                              );
                            },
                            child: Column(
                              children: [
                                CircleAvatar(
                                  radius: 54,
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.surfaceVariant,
                                  backgroundImage: s.userImage != null
                                      ? Image.file(
                                          File(s.userImage!.path),
                                        ).image
                                      : null,
                                  child: s.userImage == null
                                      ? const Icon(Icons.person, size: 48)
                                      : null,
                                ),
                                const SizedBox(height: 6),
                                Text(t.registerAddProfilePhoto),
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
                          onPressed: () {
                            if (_first.text.trim().isEmpty ||
                                _last.text.trim().isEmpty) {
                              showTopToast(
                                context,
                                t.registerCompleteErrorsGeneric,
                                type: ToastType.error,
                              );
                              return;
                            }
                            context.read<RegisterBloc>().add(
                              RegSubmitUserProfile(),
                            );
                          },
                          label: t.registerCompleteButtonsFinish,
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.interests)
                        _InterestsGrid(
                          t: t,
                          showAll: _showAllInterests,
                          onToggleShow: () => setState(
                            () => _showAllInterests = !_showAllInterests,
                          ),
                          selected: s.interests,
                          onToggle: (id) => context.read<RegisterBloc>().add(
                            RegToggleInterest(id),
                          ),
                          onSubmit: () => context.read<RegisterBloc>().add(
                            RegSubmitInterests(),
                          ),
                        ),

                      // ==================== BUSINESS FLOW ====================
                      if (s.step == RegStep.bizName) ...[
                        _label(t.registerBusinessName),
                        AppTextField(
                          controller: _bizName,
                          label: t.registerCompleteStep1BusinessName,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessNameChanged(v),
                          ),
                          borderRadius: 22,
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () {
                            if (_bizName.text.trim().isEmpty) {
                              showTopToast(
                                context,
                                t.registerCompleteErrorsBusinessNameRequired,
                                type: ToastType.error,
                                haptics: true,
                              );
                              return;
                            }
                            context.read<RegisterBloc>().emit(
                              s.copyWith(step: RegStep.bizDetails),
                            );
                          },
                          label: t.registerCompleteButtonsContinue,
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.bizDetails) ...[
                        _label(t.registerCompleteStep2BusinessDescription),
                        AppTextField(
                          controller: _bizDesc,
                          label: t.registerDescription,
                          helper:
                              '${t.registerCompleteStep2DescriptionHint1}\n${t.registerCompleteStep2DescriptionHint2}',
                          maxLines: 4,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessDescChanged(v),
                          ),
                          borderRadius: 18,
                        ),
                        const SizedBox(height: 12),
                        _label(t.registerCompleteStep2WebsiteUrl),
                        AppTextField(
                          controller: _bizWebsite,
                          label: t.registerWebsite,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessWebsiteChanged(v),
                          ),
                          borderRadius: 22,
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
                        _label(t.registerCompleteStep3BusinessLogo),
                        _PickBox(
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
                        _label(t.registerSelectBanner),
                        _PickBox(
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
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w700),
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

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

class _PickBox extends StatelessWidget {
  final String label;
  final VoidCallback onPick;
  const _PickBox({required this.label, required this.onPick});

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onPick,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        height: 110,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: cs.surfaceVariant.withOpacity(.35),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: cs.outlineVariant),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.image_outlined),
            const SizedBox(width: 8),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _InterestsGrid extends StatelessWidget {
  final AppLocalizations t;
  final bool showAll;
  final VoidCallback onToggleShow;
  final Set<int> selected;
  final void Function(int) onToggle;
  final VoidCallback onSubmit;

  const _InterestsGrid({
    required this.t,
    required this.showAll,
    required this.onToggleShow,
    required this.selected,
    required this.onToggle,
    required this.onSubmit,
  });

  static const _all = [
    {'id': 1, 'name': 'FITNESS'},
    {'id': 2, 'name': 'COOKING'},
    {'id': 3, 'name': 'TRAVEL'},
    {'id': 4, 'name': 'GAMING'},
    {'id': 5, 'name': 'THEATER'},
    {'id': 6, 'name': 'LANGUAGE'},
    {'id': 7, 'name': 'PHOTOGRAPHY'},
    {'id': 8, 'name': 'DIY'},
    {'id': 9, 'name': 'BEAUTY'},
    {'id': 10, 'name': 'FINANCE'},
    {'id': 11, 'name': 'OTHER'},
  ];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final items = showAll ? _all : _all.take(6).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'What are you into?',
          textAlign: TextAlign.center,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: items.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.2,
          ),
          itemBuilder: (_, i) {
            final it = items[i];
            final active = selected.contains(it['id']);
            return InkWell(
              onTap: () => onToggle(it['id'] as int),
              child: Container(
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? cs.primary : cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? cs.primary : cs.outlineVariant,
                  ),
                ),
                child: Text(
                  it['name'] as String,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: active ? cs.onPrimary : cs.onSurface,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 10),
        Align(
          alignment: Alignment.centerRight,
          child: TextButton(
            onPressed: onToggleShow,
            child: Text(
              showAll
                  ? t.registerCompleteButtonsSeeLess
                  : t.registerCompleteButtonsSeeAll,
            ),
          ),
        ),
        const SizedBox(height: 8),
        AppButton(
          onPressed: onSubmit,
          label: t.registerCompleteButtonsContinue,
          expand: true,
        ),
      ],
    );
  }
}
