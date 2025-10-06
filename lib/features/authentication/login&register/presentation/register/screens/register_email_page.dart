// ======================= register_email_page.dart — Flutter 3.35.x =======================
// Email registration flow + camera/gallery image picker for user photo, business logo, banner.
// Role is preserved via Navigator args. Image preview is reliable using FileImage and Bloc state.

import 'dart:io'; // File for local image preview
import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart'; // PlatformException for picker errors
import 'package:flutter_bloc/flutter_bloc.dart'; // BLoC
import 'package:image_picker/image_picker.dart'; // Image picker

// Usecases for interests
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/get_activity_types.dart'; // interests

// Bloc + events + states
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_bloc.dart'; // bloc
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_event.dart'; // events
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_state.dart'; // state

// Common small widgets
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/widgets/password_input.dart'; // password field
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/widgets/interests_grid.dart'; // interests grid
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/widgets/role_selector.dart'; // role pills
import '../widgets/login_link.dart'; // login link
import '../widgets/guidelines.dart'; // password rules
import '../widgets/otp_boxes.dart'; // 6 code boxes
import '../widgets/pill_field.dart'; // rounded text field
import '../widgets/pick_box.dart'; // file picker tile

// l10n + shared UI
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // button
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // input
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast

// DI: services + repos
import 'package:hobby_sphere/features/authentication/login&register/data/services/registration_service.dart'; // service
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/registration_repository_impl.dart'; // reg repo
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/interests_repository_impl.dart'; // interests repo

// Usecases: user
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/send_user_verification.dart'; // send user code
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_user_email_code.dart'; // verify user email
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_user_phone_code.dart'; // verify user phone
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/complete_user_profile.dart'; // complete user
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/add_user_interests.dart'; // add interests
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/resend_user_code.dart'; // resend user

// Usecases: business
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/send_business_verification.dart'; // send biz code
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_business_email_code.dart'; // verify biz email
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_business_phone_code.dart'; // verify biz phone
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/complete_business_profile.dart'; // complete biz
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/resend_business_code.dart'; // resend biz

// ======================= Public wrapper =======================

class RegisterEmailPage extends StatelessWidget {
  final RegistrationService service; // backend service
  final int initialRoleIndex; // default role (0=user, 1=business)

  const RegisterEmailPage({
    super.key, // key
    required this.service, // inject service
    this.initialRoleIndex = 0, // default to user if none passed
  });

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments; // read route args
    final passedRoleIndex = (args is Map && args['roleIndex'] is int)
        ? (args['roleIndex'] as int) // use passed role if any
        : initialRoleIndex; // else fallback

    final regRepo = RegistrationRepositoryImpl(service); // reg repo
    final interestsRepo = InterestsRepositoryImpl(service); // interests repo

    return BlocProvider(
      create: (_) => RegisterBloc(
        // user usecases
        sendUserVerification: SendUserVerification(regRepo),
        verifyUserEmail: VerifyUserEmailCode(regRepo),
        verifyUserPhone: VerifyUserPhoneCode(regRepo),
        completeUser: CompleteUserProfile(regRepo),
        addInterests: AddUserInterests(regRepo),
        resendUser: ResendUserCode(regRepo),
        // business usecases
        sendBizVerification: SendBusinessVerification(regRepo),
        verifyBizEmail: VerifyBusinessEmailCode(regRepo),
        verifyBizPhone: VerifyBusinessPhoneCode(regRepo),
        completeBiz: CompleteBusinessProfile(regRepo),
        resendBiz: ResendBusinessCode(regRepo),
        // interests
        getActivityTypes: GetActivityTypes(interestsRepo),
      )..add(RegRoleChanged(passedRoleIndex)), // set role immediately
      child: const _RegisterEmailView(), // UI
    );
  }
}

// ======================= Internal stateful view =======================

class _RegisterEmailView extends StatefulWidget {
  const _RegisterEmailView(); // ctor
  @override
  State<_RegisterEmailView> createState() => _RegisterEmailViewState(); // state
}

class _RegisterEmailViewState extends State<_RegisterEmailView> {
  // Contact + password controllers
  final _email = TextEditingController(); // email input
  final _pwd = TextEditingController(); // password input
  final _pwd2 = TextEditingController(); // confirm input

  // OTP controllers/nodes
  final _otpCtrls = List.generate(6, (_) => TextEditingController()); // 6 boxes
  final _otpNodes = List.generate(6, (_) => FocusNode()); // 6 nodes

  // User profile controllers
  final _first = TextEditingController(); // first name
  final _last = TextEditingController(); // last name
  final _username = TextEditingController(); // username

  // Business profile controllers
  final _bizName = TextEditingController(); // business name
  final _bizDesc = TextEditingController(); // business description
  final _bizWebsite = TextEditingController(); // website

  // Local UI state
  final ImagePicker _picker = ImagePicker(); // one picker instance
  bool _stagePassword = false; // show password stage
  bool _pwdObscure = true; // hide/show pwd
  bool _pwd2Obscure = true; // hide/show confirm
  bool _newsletterOptIn = false; // remember info
  bool _showAllInterests = true; // expand grid
  bool _requestedInterests = false; // guard single fetch

  // ===== helper: choose Camera/Gallery then pick image =====
  Future<XFile?> _chooseAndPick(
    BuildContext context,
    AppLocalizations t,
  ) async {
    // open bottom sheet to choose source
    final source = await showModalBottomSheet<ImageSource>(
      context: context, // context for sheet
      showDragHandle: true, // handle
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ), // rounded sheet
      builder: (_) => _ImageSourceSheet(t: t), // our small sheet widget
    ); // returns chosen ImageSource or null

    if (source == null) return null; // user canceled

    try {
      // pick image with small compression and size limit
      final picked = await _picker.pickImage(
        source: source, // camera or gallery
        imageQuality: 85, // compress a bit
        maxWidth: 1600, // limit width
        maxHeight: 1600, // limit height
      ); // returns XFile? or null
      return picked; // pass back
    } on PlatformException catch (e) {
      // show simple error toast
      showTopToast(
        context,
        '${t.globalError}: ${e.code}',
        type: ToastType.error,
      );
      return null; // fail safe
    }
  }

  @override
  void initState() {
    super.initState(); // super
    // ensure we are in EMAIL mode (not phone)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bloc = context.read<RegisterBloc>(); // bloc
      if (bloc.state.usePhone) bloc.add(RegToggleMethod()); // switch
    });
    // revalidate on password changes
    _pwd.addListener(() => setState(() {})); // refresh
    _pwd2.addListener(() => setState(() {})); // refresh
  }

  @override
  void dispose() {
    // dispose controllers/nodes
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
      RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v.trim()); // basic email

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // i18n
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors

    final emailReady = _isValidEmail(_email.text); // email ok
    final signUpReady =
        emailReady && _pwd.text.length >= 8 && _pwd.text == _pwd2.text; // valid

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // flat
        backgroundColor: theme.scaffoldBackgroundColor, // same bg
        leading: const BackButton(), // back button
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listenWhen: (p, c) => p != c, // listen on changes
        listener: (context, s) {
          if (s.error?.isNotEmpty == true) {
            showTopToast(
              context,
              s.error!,
              type: ToastType.error,
              haptics: true,
            ); // error toast
          }
          if (s.info?.isNotEmpty == true) {
            showTopToast(context, s.info!, type: ToastType.info); // info toast
          }
          if (s.step == RegStep.done) {
            final msg = s.roleIndex == 0
                ? t.registerSuccessUser
                : t.registerSuccessBusiness; // message
            showTopToast(
              context,
              msg,
              type: ToastType.success,
            ); // success toast
          }
          if (s.code.length == 6) {
            for (int i = 0; i < 6; i++) {
              _otpCtrls[i].text = s.code[i]; // sync digits
            }
          }
        },
        builder: (context, s) {
          final bloc = context.read<RegisterBloc>(); // bloc

          // lazy fetch interests when needed
          if (s.step == RegStep.interests &&
              !_requestedInterests &&
              !s.interestsLoading &&
              s.interestOptions.isEmpty) {
            _requestedInterests = true; // guard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(RegFetchInterests()); // fetch
            });
          }

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ), // page padding
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // full width
                    children: [
                      // ===== role selector (optional, keeps role visible) =====
                      Center(
                        child: RoleSelector(
                          value: s.roleIndex, // current role
                          onChanged: (i) =>
                              bloc.add(RegRoleChanged(i)), // change role
                        ),
                      ),
                      const SizedBox(height: 10), // space
                      // ===== title =====
                      Padding(
                        padding: const EdgeInsets.only(
                          top: 8,
                          bottom: 16,
                        ), // padding
                        child: Text(
                          (!_stagePassword && s.step == RegStep.contact)
                              ? t
                                    .emailRegistrationEnterEmail // initial title
                              : t.registerTitle, // generic title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                      ),

                      // ===== CONTACT (EMAIL) =====
                      if (s.step == RegStep.contact) ...[
                        if (!_stagePassword) ...[
                          AppTextField(
                            controller: _email, // email
                            label: t.emailRegistrationEmailPlaceholder, // label
                            hint: t.emailRegistrationEmailPlaceholder, // hint
                            keyboardType:
                                TextInputType.emailAddress, // keyboard
                            textInputAction: TextInputAction.done, // action
                            borderRadius: 28, // style
                            onChanged: (_) => setState(() {}), // refresh
                          ),
                          const SizedBox(height: 10), // space
                          Text(
                            t.emailRegistrationEmailDesc,
                            style: theme.textTheme.bodyMedium,
                          ), // helper
                          const SizedBox(height: 16), // space
                          AppButton(
                            onPressed: emailReady
                                ? () => setState(() => _stagePassword = true)
                                : null, // continue
                            label: t.emailRegistrationContinue, // label
                            expand: true, // full width
                          ),
                          const SizedBox(height: 12), // space
                          const LoginLink(), // link
                        ] else ...[
                          // ===== PASSWORD STAGE =====
                          Text(
                            t.emailRegistrationCreatePassword, // title
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ), // bold
                          ),
                          const SizedBox(height: 8), // space
                          PasswordInput(
                            controller: _pwd, // password
                            obscure: _pwdObscure, // hide
                            onToggleObscure: () => setState(
                              () => _pwdObscure = !_pwdObscure,
                            ), // toggle
                          ),
                          const SizedBox(height: 10), // space
                          AppTextField(
                            controller: _pwd2, // confirm
                            label: t.registerConfirmPassword, // label
                            hint:
                                t.emailRegistrationPasswordPlaceholder, // hint
                            prefix: const Icon(Icons.lock_outline), // icon
                            suffix: IconButton(
                              icon: Icon(
                                _pwd2Obscure
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                              ), // eye
                              onPressed: () => setState(
                                () => _pwd2Obscure = !_pwd2Obscure,
                              ), // toggle
                            ),
                            obscure: _pwd2Obscure, // hide
                            textInputAction: TextInputAction.done, // action
                            borderRadius: 28, // style
                          ),
                          const SizedBox(height: 10), // space
                          const Guidelines(), // rules
                          const SizedBox(height: 8), // space
                          Row(
                            children: [
                              Checkbox(
                                value: _newsletterOptIn, // flag
                                onChanged: (v) => setState(
                                  () => _newsletterOptIn = (v ?? false),
                                ), // toggle
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(6),
                                ), // shape
                              ),
                              Expanded(
                                child: Text(
                                  t.emailRegistrationSaveInfo,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ), // text
                            ],
                          ),
                          const SizedBox(height: 8), // space
                          AppButton(
                            onPressed: signUpReady
                                ? () {
                                    if (!_isValidEmail(_email.text)) {
                                      showTopToast(
                                        context,
                                        t.emailRegistrationErrorGeneric,
                                        type: ToastType.error,
                                        haptics: true,
                                      ); // invalid email
                                      return; // stop
                                    }
                                    if (s.usePhone)
                                      bloc.add(
                                        RegToggleMethod(),
                                      ); // ensure email mode
                                    bloc
                                      ..add(
                                        RegEmailChanged(_email.text.trim()),
                                      ) // set email
                                      ..add(
                                        RegPasswordChanged(_pwd.text.trim()),
                                      ) // set pwd
                                      ..add(
                                        RegSendVerification(),
                                      ); // send code (role-aware)
                                  }
                                : null, // disabled
                            label: t.emailRegistrationSignUp, // label
                            expand: true, // full
                          ),
                          const SizedBox(height: 12), // space
                          const LoginLink(), // link
                        ],
                      ],

                      // ===== OTP =====
                      if (s.step == RegStep.code) ...[
                        const SizedBox(height: 12), // space
                        Text(
                          t.emailRegistrationVerificationSent, // text
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        const SizedBox(height: 18), // space
                        OtpBoxes(
                          ctrls: _otpCtrls, // ctrls
                          nodes: _otpNodes, // nodes
                          onChanged: (code) => context.read<RegisterBloc>().add(
                            RegCodeChanged(code),
                          ), // update
                        ),
                        const SizedBox(height: 20), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().add(
                            RegVerifyCode(),
                          ), // verify
                          label: t.verifyVerifyBtn, // label
                          expand: true, // full
                        ),
                        const SizedBox(height: 10), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().add(
                            RegResendCode(),
                          ), // resend
                          type: AppButtonType.outline, // outline
                          label: t.verifyResendBtn, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== USER: NAME =====
                      if (s.step == RegStep.name) ...[
                        const SizedBox(height: 16), // space
                        Text(
                          t.registerCompleteStep1FirstNameQuestion, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        const SizedBox(height: 12), // space
                        PillField(
                          controller: _first, // first
                          label: t.registerCompleteStep1FirstName, // label
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegFirstNameChanged(v),
                          ), // update
                        ),
                        const SizedBox(height: 12), // space
                        PillField(
                          controller: _last, // last
                          label: t.registerCompleteStep1LastName, // label
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegLastNameChanged(v),
                          ), // update
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.username),
                          ), // next
                          label: t.registerCompleteButtonsContinue, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== USER: USERNAME =====
                      if (s.step == RegStep.username) ...[
                        const SizedBox(height: 16), // space
                        Text(
                          t.registerCompleteStep2ChooseUsername, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        const SizedBox(height: 12), // space
                        PillField(
                          controller: _username, // username
                          label: t.registerCompleteStep2Username, // label
                          helper:
                              '${t.registerCompleteStep2UsernameHint1}\n'
                              '${t.registerCompleteStep2UsernameHint2}\n'
                              '${t.registerCompleteStep2UsernameHint3}', // helper
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegUsernameChanged(v),
                          ), // update
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.profile),
                          ), // next
                          label: t.registerCompleteButtonsContinue, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== USER: PROFILE (with Camera/Gallery) =====
                      if (s.step == RegStep.profile) ...[
                        const SizedBox(height: 12), // space
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final img = await _chooseAndPick(
                                context,
                                t,
                              ); // open sheet + pick
                              if (img == null) return; // canceled
                              context.read<RegisterBloc>().add(
                                RegPickUserImage(img),
                              ); // save in bloc
                              showTopToast(
                                context,
                                t.registerAddProfilePhoto,
                                type: ToastType.info,
                              ); // info toast
                            },
                            child: Stack(
                              clipBehavior:
                                  Clip.none, // allow clear button outside
                              children: [
                                CircleAvatar(
                                  radius: 56, // size
                                  backgroundColor: cs.surfaceVariant, // bg
                                  // show image if present using FileImage to refresh properly
                                  backgroundImage:
                                      (s.userImage != null &&
                                          s.userImage!.path.isNotEmpty)
                                      ? FileImage(
                                          File(s.userImage!.path),
                                        ) // preview
                                      : null, // else null
                                  child:
                                      (s.userImage == null ||
                                          s.userImage!.path.isEmpty)
                                      ? const Icon(
                                          Icons.person,
                                          size: 48,
                                        ) // placeholder
                                      : null, // else none
                                ),
                                if (s.userImage != null &&
                                    s
                                        .userImage!
                                        .path
                                        .isNotEmpty) // clear button
                                  Positioned(
                                    right: -4,
                                    top: -4, // corner
                                    child: InkWell(
                                      onTap: () => context
                                          .read<RegisterBloc>()
                                          .add(RegPickUserImage(null)), // clear
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
                                        ), // icon
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12), // space
                        SwitchListTile(
                          value: s.userPublic, // flag
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegUserPublicToggled(v),
                          ), // toggle
                          title: Text(
                            t.registerCompleteStep3PublicProfile,
                          ), // label
                        ),
                        const SizedBox(height: 8), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().add(
                            RegSubmitUserProfile(),
                          ), // submit
                          label: t.registerCompleteButtonsFinish, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== USER: INTERESTS (REMOTE) =====
                      if (s.step == RegStep.interests) ...[
                        if (s.interestsLoading) ...[
                          const SizedBox(height: 24), // space
                          const Center(
                            child: CircularProgressIndicator(),
                          ), // loader
                          const SizedBox(height: 24), // space
                        ] else if ((s.interestsError ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8), // space
                          Center(
                            child: Text(
                              t.interestLoadError, // generic error
                              textAlign: TextAlign.center, // center
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: theme.colorScheme.error,
                              ), // red
                            ),
                          ),
                          const SizedBox(height: 12), // space
                          AppButton(
                            onPressed: () => context.read<RegisterBloc>().add(
                              RegFetchInterests(),
                            ), // retry
                            label: t.buttonsContinue, // "Continue"
                            expand: true, // full
                          ),
                        ] else ...[
                          InterestsGridRemote(
                            items: s.interestOptions, // options
                            selected: s.interests, // selected ids
                            showAll: _showAllInterests, // expand flag
                            onToggleShow: () => setState(
                              () => _showAllInterests = !_showAllInterests,
                            ), // toggle
                            onToggle: (id) => context.read<RegisterBloc>().add(
                              RegToggleInterest(id),
                            ), // toggle interest
                            onSubmit: () => context.read<RegisterBloc>().add(
                              RegSubmitInterests(),
                            ), // submit
                          ),
                        ],
                      ],

                      // ===== BUSINESS: NAME =====
                      if (s.step == RegStep.bizName) ...[
                        const SizedBox(height: 16), // space
                        Text(
                          t.registerCompleteStep1BusinessName, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        const SizedBox(height: 12), // space
                        PillField(
                          controller: _bizName, // name
                          label: t.registerBusinessName, // label
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessNameChanged(v),
                          ), // update
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.bizDetails),
                          ), // next
                          label: t.registerCompleteButtonsContinue, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== BUSINESS: DETAILS =====
                      if (s.step == RegStep.bizDetails) ...[
                        const SizedBox(height: 8), // space
                        Text(
                          t.registerCompleteStep2BusinessDescription, // title
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        AppTextField(
                          controller: _bizDesc, // desc
                          label: t.registerDescription, // label
                          maxLines: 4, // textarea
                          borderRadius: 18, // round
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessDescChanged(v),
                          ), // update
                        ),
                        const SizedBox(height: 12), // space
                        Text(
                          t.registerCompleteStep2WebsiteUrl, // title
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        PillField(
                          controller: _bizWebsite, // url
                          label: t.registerWebsite, // label
                          onChanged: (v) => context.read<RegisterBloc>().add(
                            RegBusinessWebsiteChanged(v),
                          ), // update
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.bizProfile),
                          ), // next
                          label: t.registerCompleteButtonsContinue, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== BUSINESS: PROFILE (Camera/Gallery for logo + banner) =====
                      if (s.step == RegStep.bizProfile) ...[
                        Text(
                          t.registerSelectLogo, // title
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        PickBox(
                          label: t.registerSelectLogo, // tile label
                          onPick: () async {
                            final img = await _chooseAndPick(
                              context,
                              t,
                            ); // choose source
                            if (img == null) return; // canceled
                            context.read<RegisterBloc>().add(
                              RegPickBusinessLogo(img),
                            ); // save
                          },
                        ),
                        const SizedBox(height: 12), // space
                        Text(
                          t.registerSelectBanner, // title
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        PickBox(
                          label: t.registerSelectBanner, // tile label
                          onPick: () async {
                            final img = await _chooseAndPick(
                              context,
                              t,
                            ); // choose source
                            if (img == null) return; // canceled
                            context.read<RegisterBloc>().add(
                              RegPickBusinessBanner(img),
                            ); // save
                          },
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().add(
                            RegSubmitBusinessProfile(),
                          ), // submit
                          label: t.registerCompleteButtonsFinish, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== DONE =====
                      if (s.step == RegStep.done) ...[
                        const SizedBox(height: 40), // space
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: cs.primary,
                        ), // big icon
                        const SizedBox(height: 10), // space
                        Center(
                          child: Text(
                            s.roleIndex == 0
                                ? t.registerSuccessUser
                                : t.registerSuccessBusiness, // text
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ), // bold
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Loading overlay
                if (context.watch<RegisterBloc>().state.loading)
                  Container(
                    color: Colors.black.withOpacity(.12), // dim
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // compact
                        children: [
                          const CircularProgressIndicator(), // spinner
                          const SizedBox(height: 10), // space
                          Text(t.emailRegistrationLoading), // text
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

// ======================= Bottom sheet for image source =======================
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
            const SizedBox(height: 12), // space
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined), // icon
              title: Text(t.registerPickFromCamera), // "Take photo"
              onTap: () =>
                  Navigator.pop(context, ImageSource.camera), // choose camera
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined), // icon
              title: Text(t.registerPickFromGallery), // "Choose from gallery"
              onTap: () =>
                  Navigator.pop(context, ImageSource.gallery), // choose gallery
            ),
            const SizedBox(height: 4), // small space
          ],
        ),
      ),
    );
  }
}
