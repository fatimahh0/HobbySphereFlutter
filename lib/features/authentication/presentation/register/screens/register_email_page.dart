// register_email_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// l10n + shared
import 'package:hobby_sphere/l10n/app_localizations.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

// DI
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

// routes (for "Log in" link)
import 'package:hobby_sphere/app/router/router.dart' show Routes;

// Your password widget; if you don't have it, swap with AppTextField
import 'package:hobby_sphere/features/authentication/presentation/login/widgets/password_input.dart';

class RegisterEmailPage extends StatelessWidget {
  final RegistrationService service;

  /// pass the chosen role from the first “select role” screen (0 = user, 1 = business)
  final int initialRoleIndex;
  const RegisterEmailPage({
    super.key,
    required this.service,
    this.initialRoleIndex = 0,
  });

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
  // contact
  final _email = TextEditingController();
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

  final _picker = ImagePicker();

  // local UI
  bool _stagePassword = false; // email page -> password page (same route)
  bool _pwdObscure = true;
  bool _pwd2Obscure = true;
  bool _newsletterOptIn = false;
  bool _showAllInterests = true;

  @override
  void initState() {
    super.initState();

    // Force EMAIL mode on this page (if bloc defaults to phone).
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<RegisterBloc>();
      if (bloc.state.usePhone) {
        bloc.add(RegToggleMethod()); // toggle to email
      }
    });

    // Keep buttons' enabled state in sync while typing
    _pwd.addListener(_update);
    _pwd2.addListener(_update);
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

  void _update() => setState(() {});

  bool _isValidEmail(String v) =>
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim());

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    final emailReady = _isValidEmail(_email.text);
    final signUpReady =
        _isValidEmail(_email.text) &&
        _pwd.text.length >= 8 &&
        _pwd.text == _pwd2.text;

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
                ? (t.registerSuccessUser)
                : (t.registerSuccessBusiness);
            showTopToast(context, msg, type: ToastType.success);
          }

          // Optional: pre-fill OTP if backend auto-filled it
          if (s.code.length == 6) {
            for (int i = 0; i < 6; i++) {
              _otpCtrls[i].text = s.code[i];
            }
          }
        },
        builder: (context, s) {
          final bloc = context.read<RegisterBloc>();

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
                      Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 16),
                        child: Text(
                          !_stagePassword && s.step == RegStep.contact
                              ? 'Enter email'
                              : 'Sign up',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),

                      // ================== CONTACT (EMAIL PATH) ==================
                      if (s.step == RegStep.contact) ...[
                        if (!_stagePassword) ...[
                          AppTextField(
                            controller: _email,
                            label: 'Email address',
                            hint: 'Email address',
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.done,
                            borderRadius: 28,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "You'll receive a verification code via email. "
                            "Your email may be used for account security and discovery depending on your settings.",
                            style: theme.textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 16),
                          AppButton(
                            onPressed: emailReady
                                ? () => setState(() => _stagePassword = true)
                                : null,
                            label: 'Continue',
                            expand: true,
                          ),
                          const SizedBox(height: 12),
                          _LoginLink(),
                        ] else ...[
                          Text(
                            'Create password',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 8),

                          // If you don't have PasswordInput, replace with AppTextField (obscure:true)
                          PasswordInput(
                            controller: _pwd,
                            obscure: _pwdObscure,
                            onToggleObscure: () =>
                                setState(() => _pwdObscure = !_pwdObscure),
                          ),
                          const SizedBox(height: 10),

                          AppTextField(
                            controller: _pwd2,
                            label: 'Enter password',
                            hint: 'Enter password',
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
                          const _Guidelines(),
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
                                  'Get trending content and updates by email',
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
                                        'Please enter a valid email',
                                        type: ToastType.error,
                                        haptics: true,
                                      );
                                      return;
                                    }
                                    // guard: ensure bloc is on EMAIL mode
                                    if (s.usePhone) bloc.add(RegToggleMethod());

                                    bloc.add(
                                      RegEmailChanged(_email.text.trim()),
                                    );
                                    bloc.add(
                                      RegPasswordChanged(_pwd.text.trim()),
                                    );
                                    bloc.add(RegSendVerification());
                                  }
                                : null,
                            label: 'Sign Up',
                            expand: true,
                          ),
                          const SizedBox(height: 12),
                          _LoginLink(),
                        ],
                      ],

                      // ================== OTP ==================
                      if (s.step == RegStep.code) ...[
                        const SizedBox(height: 12),
                        Text(
                          'Enter the 6-digit verification code',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        _OtpBoxes(
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
                          label: 'Verify',
                          expand: true,
                        ),
                        const SizedBox(height: 10),
                        AppButton(
                          onPressed: () =>
                              context.read<RegisterBloc>().add(RegResendCode()),
                          type: AppButtonType.outline,
                          label: 'Resend Code',
                          expand: true,
                        ),
                      ],

                      // ================== USER FLOW ==================
                      if (s.step == RegStep.name) ...[
                        const SizedBox(height: 16),
                        _pillLabel(context, "What's your name?"),
                        const SizedBox(height: 12),
                        _pillField(
                          controller: _first,
                          label: 'First Name',
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegFirstNameChanged(v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _pillField(
                          controller: _last,
                          label: 'Last Name',
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegLastNameChanged(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.username),
                          ),
                          label: 'Continue',
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.username) ...[
                        const SizedBox(height: 16),
                        _pillLabel(context, 'Choose a username'),
                        const SizedBox(height: 12),
                        _pillField(
                          controller: _username,
                          label: 'Username',
                          helper:
                              '• Must be unique\n• No spaces or symbols\n• Between 3–15 characters',
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegUsernameChanged(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.profile),
                          ),
                          label: 'Continue',
                          expand: true,
                        ),
                      ],

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
                          title: const Text('Public Profile'),
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().add(
                            RegSubmitUserProfile(),
                          ),
                          label: 'Finish',
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.interests)
                        _InterestsGrid(
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

                      // ================== BUSINESS FLOW ==================
                      if (s.step == RegStep.bizName) ...[
                        const SizedBox(height: 16),
                        _pillLabel(context, 'Business Name'),
                        const SizedBox(height: 12),
                        _pillField(
                          controller: _bizName,
                          label: 'Business',
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessNameChanged(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.bizDetails),
                          ),
                          label: 'Continue',
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.bizDetails) ...[
                        const SizedBox(height: 8),
                        _label(context, 'Business Description'),
                        AppTextField(
                          controller: _bizDesc,
                          label: 'Description',
                          maxLines: 4,
                          borderRadius: 18,
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessDescChanged(v),
                          ),
                        ),
                        const SizedBox(height: 12),
                        _label(context, 'Website URL (optional)'),
                        _pillField(
                          controller: _bizWebsite,
                          label: 'Website',
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessWebsiteChanged(v),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.bizProfile),
                          ),
                          label: 'Continue',
                          expand: true,
                        ),
                      ],

                      if (s.step == RegStep.bizProfile) ...[
                        _label(context, 'Business Logo'),
                        _PickBox(
                          label: 'Select logo',
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
                        _label(context, 'Business Banner'),
                        _PickBox(
                          label: 'Select banner',
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
                          label: 'Finish',
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
                                ? (t.registerSuccessUser)
                                : (t.registerSuccessBusiness),
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

  // ===== small UI helpers (pill fields / labels) =====
  Widget _pillField({
    required TextEditingController controller,
    required String label,
    String? helper,
    ValueChanged<String>? onChanged,
  }) {
    return AppTextField(
      controller: controller,
      label: label,
      hint: label,
      maxLines: 1,
      borderRadius: 28,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      onChanged: onChanged,
      helper: helper,
      filled: false,
    );
  }

  Widget _pillLabel(BuildContext context, String t) => Text(
    t,
    textAlign: TextAlign.center,
    style: Theme.of(
      context,
    ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
  );

  Widget _label(BuildContext context, String t) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      t,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    ),
  );
}

// ===== components =====

class _Guidelines extends StatelessWidget {
  const _Guidelines();

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodyMedium;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('• 8 characters (20 max)', style: style),
        Text(
          '• 1 letter, 1 number, 1 special character (# ? ! @)',
          style: style,
        ),
        Text('• Strong password', style: style),
      ],
    );
  }
}

class _LoginLink extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Center(
        child: Wrap(
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            const Text('Already have an account? '),
            InkWell(
              onTap: () => Navigator.of(context).pushNamed(Routes.login),
              child: Text(
                'Log in',
                style: TextStyle(
                  color: cs.primary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OtpBoxes extends StatelessWidget {
  final List<TextEditingController> ctrls;
  final List<FocusNode> nodes;
  final ValueChanged<String> onChanged;
  const _OtpBoxes({
    required this.ctrls,
    required this.nodes,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(6, (i) {
        return Container(
          width: 44,
          height: 48,
          margin: const EdgeInsets.symmetric(horizontal: 6),
          child: TextField(
            controller: ctrls[i],
            focusNode: nodes[i],
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium,
            maxLength: 1,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: InputDecoration(
              counterText: '',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.primary),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.outlineVariant),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: cs.primary, width: 1.6),
              ),
            ),
            onChanged: (v) {
              if (v.isNotEmpty && i < 5) nodes[i + 1].requestFocus();
              if (v.isEmpty && i > 0) nodes[i - 1].requestFocus();
              onChanged(ctrls.map((c) => c.text).join());
            },
          ),
        );
      }),
    );
  }
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

/// Interests with icons (compact chips)
class _InterestsGrid extends StatelessWidget {
  final bool showAll;
  final VoidCallback onToggleShow;
  final Set<int> selected;
  final void Function(int) onToggle;
  final VoidCallback onSubmit;

  const _InterestsGrid({
    required this.showAll,
    required this.onToggleShow,
    required this.selected,
    required this.onToggle,
    required this.onSubmit,
  });

  static const _all = [
    {'id': 1, 'name': 'Fitness', 'icon': Icons.fitness_center},
    {'id': 2, 'name': 'Cooking', 'icon': Icons.restaurant_menu},
    {'id': 3, 'name': 'Travel', 'icon': Icons.flight_takeoff},
    {'id': 4, 'name': 'Gaming', 'icon': Icons.sports_esports},
    {'id': 5, 'name': 'Theater', 'icon': Icons.theaters},
    {'id': 6, 'name': 'Language', 'icon': Icons.translate},
    {'id': 7, 'name': 'Photography', 'icon': Icons.camera_alt},
    {'id': 8, 'name': 'DIY', 'icon': Icons.handyman},
    {'id': 9, 'name': 'Beauty', 'icon': Icons.brush},
    {'id': 10, 'name': 'Finance', 'icon': Icons.attach_money},
    {'id': 11, 'name': 'Other', 'icon': Icons.interests},
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
            childAspectRatio: 2.6,
          ),
          itemBuilder: (_, i) {
            final it = items[i];
            final id = it['id'] as int;
            final active = selected.contains(id);
            final iconData = it['icon'] as IconData;
            return InkWell(
              onTap: () => onToggle(id),
              borderRadius: BorderRadius.circular(14),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: active ? cs.primary : cs.surface,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: active ? cs.primary : cs.outlineVariant,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      size: 20,
                      color: active ? cs.onPrimary : cs.onSurfaceVariant,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      it['name'] as String,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: active ? cs.onPrimary : cs.onSurface,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
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
            child: Text(showAll ? 'See less' : 'See all'),
          ),
        ),
        const SizedBox(height: 8),
        AppButton(onPressed: onSubmit, label: 'Continue', expand: true),
      ],
    );
  }
}
