// Flutter 3.35.x — simple & professional
// Every line has a simple comment. Uses latest stable Flutter.

import 'dart:io'; // File for local previews
import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart'; // PlatformException
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:image_picker/image_picker.dart'; // camera/gallery

// i18n + routes
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/app/router/router.dart' show Routes; // routes

// shared widgets (use your own implementations)
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // button
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // text field
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast
import 'package:hobby_sphere/shared/widgets/phone_input.dart'; // phone input
import '../../login/widgets/role_selector.dart'; // role pills
import '../../login/widgets/password_input.dart'; // password field
import '../widgets/pill_field.dart'; // rounded field
import '../widgets/otp_boxes.dart'; // 6 boxes
import '../widgets/divider_with_text.dart'; // divider text
import '../widgets/interests_grid.dart'; // interests grid

// DI: services + repos (you already have them)
import '../../../data/services/registration_service.dart'; // http service
import '../../../data/repositories/registration_repository_impl.dart'; // repo
import '../../../data/repositories/interests_repository_impl.dart'; // repo

// usecases
import '../../../domain/usecases/register/send_user_verification.dart';
import '../../../domain/usecases/register/verify_user_email_code.dart';
import '../../../domain/usecases/register/verify_user_phone_code.dart';
import '../../../domain/usecases/register/complete_user_profile.dart';
import '../../../domain/usecases/register/add_user_interests.dart';
import '../../../domain/usecases/register/resend_user_code.dart';
import '../../../domain/usecases/register/send_business_verification.dart';
import '../../../domain/usecases/register/verify_business_email_code.dart';
import '../../../domain/usecases/register/verify_business_phone_code.dart';
import '../../../domain/usecases/register/complete_business_profile.dart';
import '../../../domain/usecases/register/resend_business_code.dart';
import '../../../domain/usecases/register/get_activity_types.dart';

// bloc
import '../bloc/register_bloc.dart'; // bloc
import '../bloc/register_event.dart'; // events
import '../bloc/register_state.dart'; // state

// ===== Public entry (injects bloc) =====
class RegisterPage extends StatelessWidget {
  final RegistrationService service; // backend service
  const RegisterPage({super.key, required this.service}); // ctor

  @override
  Widget build(BuildContext context) {
    // build repos from service
    final regRepo = RegistrationRepositoryImpl(service); // reg repo
    final interestsRepo = InterestsRepositoryImpl(service); // interests repo

    return BlocProvider(
      // create bloc with all usecases
      create: (_) => RegisterBloc(
        // user
        sendUserVerification: SendUserVerification(regRepo),
        verifyUserEmail: VerifyUserEmailCode(regRepo),
        verifyUserPhone: VerifyUserPhoneCode(regRepo),
        completeUser: CompleteUserProfile(regRepo),
        addInterests: AddUserInterests(regRepo),
        resendUser: ResendUserCode(regRepo),
        // business
        sendBizVerification: SendBusinessVerification(regRepo),
        verifyBizEmail: VerifyBusinessEmailCode(regRepo),
        verifyBizPhone: VerifyBusinessPhoneCode(regRepo),
        completeBiz: CompleteBusinessProfile(regRepo),
        resendBiz: ResendBusinessCode(regRepo),
        // interest options
        getActivityTypes: GetActivityTypes(interestsRepo),
      ),
      child: const _RegisterView(), // child view
    );
  }
}

// ===== View (stateful) =====
class _RegisterView extends StatefulWidget {
  const _RegisterView(); // ctor
  @override
  State<_RegisterView> createState() => _RegisterViewState(); // state
}

class _RegisterViewState extends State<_RegisterView> {
  // text controllers
  final _pwd = TextEditingController(); // password
  final _pwd2 = TextEditingController(); // confirm
  final _otpCtrls = List.generate(6, (_) => TextEditingController()); // 6 boxes
  final _otpNodes = List.generate(6, (_) => FocusNode()); // 6 nodes

  final _first = TextEditingController(); // first
  final _last = TextEditingController(); // last
  final _username = TextEditingController(); // username

  final _bizName = TextEditingController(); // business name
  final _bizDesc = TextEditingController(); // business desc
  final _bizWebsite = TextEditingController(); // website

  // local UI flags
  final ImagePicker _picker = ImagePicker(); // single picker instance
  bool _pwdObscure = true; // hide/show password
  bool _pwd2Obscure = true; // hide/show confirm
  bool _showPasswordStage = false; // phone flow step 2
  bool _requestedInterests = false; // one-time fetch guard
  bool _showAllInterests = true; // expand list
  String _e164Phone = ''; // current phone

  // helper: choose camera or gallery then pick
  Future<XFile?> _chooseAndPick({
    required BuildContext context,
    required AppLocalizations t,
  }) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context, // show bottom sheet
      showDragHandle: true, // drag handle
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ), // rounded
      ),
      builder: (_) => _ImageSourceSheet(t: t), // picker sheet
    );
    if (source == null) return null; // user closed

    try {
      final x = await _picker.pickImage(
        source: source, // camera/gallery
        imageQuality: 85, // compress a bit
        maxWidth: 1600,
        maxHeight: 1600, // downscale
      );
      return x; // can be null (cancel)
    } on PlatformException catch (e) {
      showTopToast(
        context,
        '${t.globalError}: ${e.code}',
        type: ToastType.error,
      ); // toast
      return null; // fail safe
    }
  }

  @override
  void dispose() {
    // dispose all controllers/nodes
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
    final t = AppLocalizations.of(context)!; // i18n
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // flat
        backgroundColor: theme.scaffoldBackgroundColor, // match bg
        leading: const BackButton(), // back
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listenWhen: (p, c) => p != c, // listen on any change
        listener: (context, s) {
          if (s.error?.isNotEmpty == true) {
            showTopToast(
              context,
              s.error!,
              type: ToastType.error,
              haptics: true,
            ); // show error
          }
          if (s.info?.isNotEmpty == true) {
            showTopToast(context, s.info!, type: ToastType.info); // info
          }
          if (s.code.length == 6) {
            for (var i = 0; i < 6; i++) {
              _otpCtrls[i].text = s.code[i]; // copy digits to boxes
            }
          }
        },
        builder: (context, s) {
          final bloc = context.read<RegisterBloc>(); // bloc shortcut

          // compute button states
          final phoneContinueReady =
              !_showPasswordStage && _e164Phone.isNotEmpty; // valid phone
          final phoneSignUpReady =
              _showPasswordStage &&
              _pwd.text.length >= 8 &&
              _pwd.text == _pwd2.text; // pwd ok

          // lazy load interests once when step opens
          if (s.step == RegStep.interests &&
              !_requestedInterests &&
              !s.interestsLoading &&
              s.interestOptions.isEmpty) {
            _requestedInterests = true; // guard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(const RegFetchInterests()); // fetch
            });
          }

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ), // page pad
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // full width
                    children: [
                      // ===== CONTACT (phone-first) =====
                      if (s.step == RegStep.contact) ...[
                        const SizedBox(height: 8), // space
                        Text(
                          t.selectMethodTitle, // title
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Center(
                          child: RoleSelector(
                            value: s.roleIndex, // selected role
                            onChanged: (i) =>
                                bloc.add(RegRoleChanged(i)), // change role
                          ),
                        ),
                        const SizedBox(height: 20),
                        PhoneInput(
                          initialIso: 'CA', // default
                          submittedOnce: false, // visuals
                          onChanged: (e164, _, __) {
                            setState(() => _e164Phone = e164 ?? ''); // save
                            bloc.add(
                              RegPhoneChanged(e164 ?? ''),
                            ); // update bloc
                          },
                          onSwapToEmail: () => Navigator.pushNamed(
                            context,
                            Routes.registerEmail, // your route
                            arguments: {'roleIndex': s.roleIndex}, // keep role
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 220), // smooth
                          crossFadeState: _showPasswordStage
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst,
                          firstChild: const SizedBox(height: 12), // placeholder
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              const SizedBox(height: 18),
                              Text(
                                t.selectMethodCreatePassword,
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              PasswordInput(
                                controller: _pwd, // password
                                obscure: _pwdObscure, // hide/show
                                onToggleObscure: () => setState(
                                  () => _pwdObscure = !_pwdObscure,
                                ), // toggle
                                onChanged: (_) => setState(() {}), // refresh
                              ),
                              const SizedBox(height: 10),
                              AppTextField(
                                controller: _pwd2, // confirm
                                label: t.registerConfirmPassword,
                                hint: t.emailRegistrationPasswordPlaceholder,
                                prefix: const Icon(Icons.lock_outline),
                                suffix: IconButton(
                                  icon: Icon(
                                    _pwd2Obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ),
                                  onPressed: () => setState(
                                    () => _pwd2Obscure = !_pwd2Obscure,
                                  ),
                                ),
                                obscure: _pwd2Obscure,
                                textInputAction: TextInputAction.done,
                                borderRadius: 28,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                        AppButton(
                          onPressed: _showPasswordStage
                              ? (phoneSignUpReady
                                    ? () {
                                        bloc.add(
                                          RegPasswordChanged(_pwd.text.trim()),
                                        ); // set pwd
                                        bloc.add(
                                          const RegSendVerification(),
                                        ); // send code
                                      }
                                    : null)
                              : (phoneContinueReady
                                    ? () =>
                                          setState(
                                            () => _showPasswordStage = true,
                                          ) // go to password stage
                                    : null),
                          label: _showPasswordStage
                              ? t.selectMethodSignUp
                              : t.selectMethodContinue,
                          expand: true,
                        ),
                        const SizedBox(height: 16),
                      ],

                      // ===== CODE (OTP) =====
                      if (s.step == RegStep.code) ...[
                        const SizedBox(height: 8),
                        Text(
                          t.verifyEnterCode,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 18),
                        OtpBoxes(
                          ctrls: _otpCtrls, // controllers
                          nodes: _otpNodes, // nodes
                          onChanged: (code) =>
                              bloc.add(RegCodeChanged(code)), // update
                          onCompleted: (_) =>
                              bloc.add(const RegVerifyCode()), // verify
                        ),
                        const SizedBox(height: 20),
                        AppButton(
                          onPressed: () =>
                              bloc.add(const RegVerifyCode()), // verify
                          label: t.verifyVerifyBtn,
                          expand: true,
                        ),
                        const SizedBox(height: 10),
                        AppButton(
                          onPressed: () =>
                              bloc.add(const RegResendCode()), // resend
                          type: AppButtonType.outline,
                          label: t.verifyResendBtn,
                          expand: true,
                        ),
                      ],

                      // ===== USER: name =====
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
                          onChanged: (v) => bloc.add(RegFirstNameChanged(v)),
                        ),
                        const SizedBox(height: 12),
                        PillField(
                          controller: _last,
                          label: t.registerCompleteStep1LastName,
                          onChanged: (v) => bloc.add(RegLastNameChanged(v)),
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

                      // ===== USER: username =====
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
                          onChanged: (v) => bloc.add(RegUsernameChanged(v)),
                        ),
                        // show red error text if it mentions "username"
                        if ((s.error?.toLowerCase().contains('username') ??
                            false))
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              s.error!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
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

                      // ===== USER: profile (avatar + public) =====
                      if (s.step == RegStep.profile) ...[
                        const SizedBox(height: 12),
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final img = await _chooseAndPick(
                                context: context,
                                t: t,
                              ); // pick
                              if (img == null) return; // cancel safe
                              bloc.add(RegPickUserImage(img)); // store
                              showTopToast(
                                context,
                                t.registerAddProfilePhoto,
                                type: ToastType.info,
                              ); // toast
                            },
                            child: Stack(
                              clipBehavior: Clip.none, // allow badge overflow
                              children: [
                                CircleAvatar(
                                  radius: 56, // size
                                  backgroundColor: cs.surfaceVariant, // bg
                                  backgroundImage:
                                      (s.userImage != null &&
                                          s.userImage!.path.isNotEmpty)
                                      ? FileImage(
                                          File(s.userImage!.path),
                                        ) // show picked
                                      : null, // else no bg
                                  child:
                                      (s.userImage == null ||
                                          s.userImage!.path.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          size: 48,
                                        ) // placeholder
                                      : null, // nothing when image
                                ),
                                if (s.userImage != null &&
                                    s.userImage!.path.isNotEmpty)
                                  Positioned(
                                    right: -4,
                                    top: -4, // corner
                                    child: InkWell(
                                      onTap: () => bloc.add(
                                        const RegPickUserImage(null),
                                      ), // clear avatar
                                      child: Container(
                                        width: 26,
                                        height: 26, // size
                                        decoration: BoxDecoration(
                                          color: cs.error,
                                          shape: BoxShape.circle,
                                        ), // red
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: cs.onError,
                                        ), // X
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          value: s.userPublic, // toggle value
                          onChanged: (v) =>
                              bloc.add(RegUserPublicToggled(v)), // dispatch
                          title: Text(
                            t.registerCompleteStep3PublicProfile,
                          ), // label
                        ),
                        const SizedBox(height: 8),
                        AppButton(
                          onPressed: () => bloc.add(
                            const RegSubmitUserProfile(),
                          ), // submit user profile
                          label: t.registerCompleteButtonsFinish,
                          expand: true,
                        ),
                      ],

                      // ===== USER: interests =====
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
                                color: cs.error,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          AppButton(
                            onPressed: () =>
                                bloc.add(const RegFetchInterests()),
                            label: t.selectMethodContinue,
                            expand: true,
                          ),
                        ] else ...[
                          InterestsGridRemote(
                            items: s.interestOptions, // options
                            selected: s.interests, // chosen
                            showAll: _showAllInterests, // expand
                            onToggleShow: () => setState(
                              () => _showAllInterests = !_showAllInterests,
                            ),
                            onToggle: (id) =>
                                bloc.add(RegToggleInterest(id)), // toggle
                            onSubmit: () =>
                                bloc.add(const RegSubmitInterests()), // submit
                          ),
                        ],
                      ],

                      // ===== BUSINESS: name =====
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
                          onChanged: (v) => bloc.add(RegBusinessNameChanged(v)),
                        ),
                        // show red error text if it mentions "name"
                        if ((s.error?.toLowerCase().contains('name') ?? false))
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              s.error!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
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

                      // ===== BUSINESS: details =====
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
                          errorText:
                              (s.error?.toLowerCase().contains('description') ??
                                  false)
                              ? s.error
                              : null,
                          onChanged: (v) => bloc.add(RegBusinessDescChanged(v)),
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
                          onChanged: (v) =>
                              bloc.add(RegBusinessWebsiteChanged(v)),
                        ),
                        // show red error if it mentions website or url
                        if ((s.error?.toLowerCase().contains('website') ??
                                false) ||
                            (s.error?.toLowerCase().contains('url') ?? false))
                          Padding(
                            padding: const EdgeInsets.only(top: 6),
                            child: Text(
                              s.error!,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: Theme.of(context).colorScheme.error,
                                  ),
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

                      // ===== BUSINESS: profile (logo + banner) with LIVE PREVIEW =====
                      if (s.step == RegStep.bizProfile) ...[
                        // ---- Logo ----
                        Text(
                          t.registerSelectLogo,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PickPreviewTile(
                          file:
                              (s.bizLogo != null && s.bizLogo!.path.isNotEmpty)
                              ? File(s.bizLogo!.path)
                              : null, // show logo
                          label: t.registerSelectLogo,
                          onPick: () async {
                            final img = await _chooseAndPick(
                              context: context,
                              t: t,
                            ); // pick
                            bloc.add(RegPickBusinessLogo(img)); // store
                          },
                          onClear: (s.bizLogo == null)
                              ? null
                              : () => bloc.add(
                                  const RegPickBusinessLogo(null),
                                ), // clear
                        ),

                        const SizedBox(height: 12),

                        // ---- Banner ----
                        Text(
                          t.registerSelectBanner,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        _PickPreviewTile(
                          file:
                              (s.bizBanner != null &&
                                  s.bizBanner!.path.isNotEmpty)
                              ? File(s.bizBanner!.path)
                              : null, // show banner
                          label: t.registerSelectBanner,
                          onPick: () async {
                            final img = await _chooseAndPick(
                              context: context,
                              t: t,
                            ); // pick
                            bloc.add(RegPickBusinessBanner(img)); // store
                          },
                          onClear: (s.bizBanner == null)
                              ? null
                              : () => bloc.add(
                                  const RegPickBusinessBanner(null),
                                ), // clear
                          isWide: true, // wider tile for banner
                          aspectRatio: 16 / 9, // banner shape
                        ),

                        // ---- show media errors if any ----
                        if ((s.error?.toLowerCase().contains('logo') ??
                                false) ||
                            (s.error?.toLowerCase().contains('banner') ??
                                false))
                          Padding(
                            padding: const EdgeInsets.only(top: 6, bottom: 8),
                            child: Text(
                              s.error!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: cs.error,
                              ),
                            ),
                          ),

                        const SizedBox(height: 16),
                        AppButton(
                          onPressed: () => bloc.add(
                            const RegSubmitBusinessProfile(),
                          ), // submit business profile
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

                // ===== Loading overlay =====
                if (context.watch<RegisterBloc>().state.loading)
                  Container(
                    color: Colors.black.withOpacity(.12), // dim background
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const CircularProgressIndicator(), // spinner
                          const SizedBox(height: 10),
                          Text(
                            t.registerCompleteButtonsSubmitting,
                          ), // "Submitting..."
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

// ===== helper: bottom sheet for image source =====
class _ImageSourceSheet extends StatelessWidget {
  final AppLocalizations t; // i18n
  const _ImageSourceSheet({required this.t}); // ctor

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16), // padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content
          children: [
            Container(
              width: 44,
              height: 4, // small handle
              decoration: BoxDecoration(
                color: cs.outlineVariant, // muted
                borderRadius: BorderRadius.circular(2), // rounded
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined), // camera icon
              title: Text(t.registerPickFromCamera), // "Take photo"
              onTap: () => Navigator.pop(
                context,
                ImageSource.camera,
              ), // close with camera
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined), // gallery icon
              title: Text(t.registerPickFromGallery), // "Choose from gallery"
              onTap: () => Navigator.pop(
                context,
                ImageSource.gallery,
              ), // close with gallery
            ),
            const SizedBox(height: 4),
          ],
        ),
      ),
    );
  }
}

// ===== helper: image pick + preview tile (used for logo & banner) =====
class _PickPreviewTile extends StatelessWidget {
  final File? file; // local image file (nullable)
  final String label; // tile label
  final VoidCallback onPick; // open picker
  final VoidCallback? onClear; // clear image (nullable)
  final bool isWide; // wide layout flag
  final double? aspectRatio; // aspect ratio

  const _PickPreviewTile({
    required this.file, // file (can be null)
    required this.label, // text
    required this.onPick, // pick action
    this.onClear, // clear action
    this.isWide = false, // default square
    this.aspectRatio, // optional ratio
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    final hasImage = file != null; // whether we have an image

    final content = hasImage
        ? Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12), // rounded
                child: AspectRatio(
                  aspectRatio: aspectRatio ?? 1, // square or custom
                  child: Image.file(
                    file!, // file to show
                    fit: BoxFit.cover, // cover fill
                  ),
                ),
              ),
              if (onClear != null)
                Positioned(
                  right: 8,
                  top: 8, // small close at corner
                  child: InkWell(
                    onTap: onClear, // clear
                    child: Container(
                      width: 28,
                      height: 28, // size
                      decoration: BoxDecoration(
                        color: cs.error, // red bg
                        shape: BoxShape.circle, // circle
                      ),
                      child: Icon(
                        Icons.close,
                        size: 18,
                        color: cs.onError,
                      ), // white X
                    ),
                  ),
                ),
            ],
          )
        : Container(
            height: isWide ? 140 : 100, // height
            decoration: BoxDecoration(
              border: Border.all(color: cs.outlineVariant), // thin border
              borderRadius: BorderRadius.circular(12), // rounded
            ),
            alignment: Alignment.center, // center
            child: Row(
              mainAxisSize: MainAxisSize.min, // wrap
              children: [
                const Icon(Icons.add_a_photo_outlined), // icon
                const SizedBox(width: 8),
                Text(label), // label
              ],
            ),
          );

    return InkWell(
      onTap: onPick, // pick on tap
      borderRadius: BorderRadius.circular(12), // ripple shape
      child: content, // show content
    );
  }
}
