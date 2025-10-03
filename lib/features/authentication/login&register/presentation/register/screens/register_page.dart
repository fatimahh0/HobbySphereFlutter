// ======================= register_page.dart — Flutter 3.35.x =======================
// Phone-first registration flow with smooth, pro UI.
// - Step A: enter phone → continue
// - Step B: password fields slide in → sign up (sends code)
// - Step C: OTP verify → proceed to profile steps (name, username, photo, interests)
// Uses your existing RegisterBloc + widgets (RoleSelector, PhoneInput, PasswordInput, etc.)

// ---- core dart/flutter ----
import 'dart:io'; // for File images preview
import 'package:flutter/material.dart'; // base UI
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc provider/consumer
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/get_activity_types.dart';
import 'package:image_picker/image_picker.dart'; // pick images

// ---- shared widgets you already have ----
import 'package:hobby_sphere/shared/widgets/phone_input.dart'; // phone field
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // primary/outline buttons
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // text fields
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // top toast

// ---- login/register shared widgets ----
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/widgets/role_selector.dart'; // user/business pills
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/widgets/password_input.dart'; // password input
import '../widgets/login_link.dart'; // "Already have an account?"
import '../widgets/guidelines.dart'; // password rules helper
import '../widgets/otp_boxes.dart'; // 6 boxes for code input
import '../widgets/pill_field.dart'; // rounded text field
import '../widgets/pick_box.dart'; // image picker tile
import '../widgets/divider_with_text.dart'; // "or" divider
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/widgets/interests_grid.dart'; // remote interests grid

// ---- bloc: events / states / bloc ----
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_bloc.dart'; // main bloc
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_event.dart'; // events
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_state.dart'; // state

// ---- DI: services / repos / usecases ----
import 'package:hobby_sphere/features/authentication/login&register/data/services/registration_service.dart'; // service to call backend
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/registration_repository_impl.dart'; // repo impl
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/interests_repository_impl.dart'; // interests repo

import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/send_user_verification.dart'; // usecases...
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

// ---- l10n ----
import 'package:hobby_sphere/l10n/app_localizations.dart'; // localized strings

// ---- routes ----
import 'package:hobby_sphere/app/router/router.dart'
    show Routes; // for "continue with email" nav

// ======================= Public entry widget =======================

class RegisterPage extends StatelessWidget {
  // the backend service passed from caller (so you can swap easily)
  final RegistrationService service; // holds http logic
  const RegisterPage({super.key, required this.service}); // ctor

  @override
  Widget build(BuildContext context) {
    // build repositories from the service
    final regRepo = RegistrationRepositoryImpl(service); // register repo
    final interestsRepo = InterestsRepositoryImpl(service); // interests repo

    // provide the RegisterBloc to subtree
    return BlocProvider(
      // create the bloc with all needed usecases
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
      child: const _RegisterView(), // actual UI view
    );
  }
}

// ======================= Internal stateful view =======================

class _RegisterView extends StatefulWidget {
  const _RegisterView(); // simple ctor
  @override
  State<_RegisterView> createState() => _RegisterViewState(); // create state
}

class _RegisterViewState extends State<_RegisterView> {
  // ---- controllers for inputs ----
  final _pwd = TextEditingController(); // password
  final _pwd2 = TextEditingController(); // confirm password
  final _otpCtrls = List.generate(6, (_) => TextEditingController()); // 6 boxes
  final _otpNodes = List.generate(6, (_) => FocusNode()); // focus nodes

  final _first = TextEditingController(); // first name
  final _last = TextEditingController(); // last name
  final _username = TextEditingController(); // username

  final _bizName = TextEditingController(); // business name
  final _bizDesc = TextEditingController(); // business description
  final _bizWebsite = TextEditingController(); // website

  // ---- local ui state ----
  final _picker = ImagePicker(); // image picker
  bool _pwdObscure = true; // hide/show pwd
  bool _pwd2Obscure = true; // hide/show confirm
  bool _rememberMe = true; // save login info
  bool _showAllInterests = true; // expand interests grid
  String _e164Phone = ''; // normalized phone
  bool _showPasswordStage = false; // toggle password section
  bool _requestedInterests = false; // guard single fetch

  @override
  void dispose() {
    // dispose all controllers + nodes to avoid leaks
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
    super.dispose(); // call super
  }

  @override
  Widget build(BuildContext context) {
    // local helpers: theme + strings
    final t = AppLocalizations.of(context)!; // l10n instance
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colorscheme

    // Scaffold = base page
    return Scaffold(
      // clean appbar
      appBar: AppBar(
        elevation: 0, // flat
        backgroundColor: theme.scaffoldBackgroundColor, // match bg
        leading: const BackButton(), // back arrow
      ),
      // Main bloc consumer (listen for toasts + rebuild UI)
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listenWhen: (p, c) => p != c, // listen when state changes
        listener: (context, s) {
          // show error toast if any error text
          if (s.error?.isNotEmpty == true) {
            showTopToast(
              context,
              s.error!,
              type: ToastType.error,
              haptics: true,
            );
          }
          // show info toast if any info text
          if (s.info?.isNotEmpty == true) {
            showTopToast(context, s.info!, type: ToastType.info);
          }
          // success toast after final done
          if (s.step == RegStep.done) {
            showTopToast(
              context,
              s.roleIndex == 0
                  ? t.registerSuccessUser
                  : t.registerSuccessBusiness,
              type: ToastType.success,
            );
          }
          // sync bloc code into the 6 OTP boxes
          if (s.code.length == 6) {
            for (var i = 0; i < 6; i++) {
              _otpCtrls[i].text = s.code[i]; // set each box
            }
          }
        },
        builder: (context, s) {
          // read bloc
          final bloc = context.read<RegisterBloc>(); // quick access

          // decide if "Continue" allowed (phone only)
          final phoneContinueReady =
              !_showPasswordStage && _e164Phone.isNotEmpty;
          // decide if "Sign Up" allowed (passwords valid)
          final phoneSignUpReady =
              _showPasswordStage &&
              _pwd.text.length >= 8 &&
              _pwd.text == _pwd2.text;

          // lazy fetch of interests when entering that step
          if (s.step == RegStep.interests &&
              !_requestedInterests &&
              !s.interestsLoading &&
              s.interestOptions.isEmpty) {
            _requestedInterests = true; // lock
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(RegFetchInterests()); // trigger fetch
            });
          }

          // main content (scrollable)
          return SafeArea(
            child: Stack(
              children: [
                // scroll for smaller screens
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ), // page padding
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch, // full width
                    children: [
                      // =================== STEP: CONTACT (phone-first) ===================
                      if (s.step == RegStep.contact) ...[
                        const SizedBox(height: 8), // spacing
                        Text(
                          t.selectMethodTitle, // "Sign up"
                          textAlign: TextAlign.center, // center title
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700, // bold
                          ),
                        ),
                        const SizedBox(height: 18), // spacing
                        // Role selector: user/business pills
                        Center(
                          child: RoleSelector(
                            value: s.roleIndex, // selected index
                            onChanged: (i) =>
                                bloc.add(RegRoleChanged(i)), // fire event
                          ),
                        ),
                        const SizedBox(height: 20), // spacing
                        // Phone field
                        PhoneInput(
                          initialIso:
                              'CA', // default country code (change if needed)
                          submittedOnce: false, // validation styling
                          onChanged: (e164, _, __) {
                            setState(
                              () => _e164Phone = e164 ?? '',
                            ); // save phone
                            bloc.add(RegPhoneChanged(e164 ?? '')); // event
                          },
                          onSwapToEmail: () => Navigator.pushNamed(
                            context,
                            Routes.registerEmail, // go to email flow
                          ),
                        ),

                        // Animated slide-in of password section (pro UX)
                        AnimatedCrossFade(
                          duration: const Duration(
                            milliseconds: 220,
                          ), // quick anim
                          crossFadeState: _showPasswordStage
                              ? CrossFadeState.showSecond
                              : CrossFadeState.showFirst, // show based on flag
                          firstChild: const SizedBox(
                            height: 12,
                          ), // minimal space
                          secondChild: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.stretch, // full width
                            children: [
                              const SizedBox(height: 18), // spacing
                              Text(
                                t.selectMethodCreatePassword, // "Create password"
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.w700, // bold
                                ),
                              ),
                              const SizedBox(height: 8), // spacing
                              // Password input (with rules)
                              PasswordInput(
                                controller: _pwd, // controller
                                obscure: _pwdObscure, // hide/show
                                onToggleObscure: () => setState(
                                  () => _pwdObscure = !_pwdObscure,
                                ), // toggle
                                onChanged: (_) =>
                                    setState(() {}), // refresh validation
                              ),
                              const SizedBox(height: 10), // spacing
                              // Confirm password
                              AppTextField(
                                controller: _pwd2, // controller
                                label: t.registerConfirmPassword, // label
                                hint: t
                                    .emailRegistrationPasswordPlaceholder, // hint
                                prefix: const Icon(Icons.lock_outline), // icon
                                suffix: IconButton(
                                  icon: Icon(
                                    _pwd2Obscure
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  ), // eye icon
                                  onPressed: () => setState(
                                    () => _pwd2Obscure = !_pwd2Obscure,
                                  ), // toggle
                                ),
                                obscure: _pwd2Obscure, // hide/show
                                textInputAction:
                                    TextInputAction.done, // ime action
                                borderRadius: 28, // pill look
                              ),
                              const SizedBox(height: 10), // spacing
                              const Guidelines(), // password rules helper
                              const SizedBox(height: 8), // spacing
                              // Save login info checkbox
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe, // value
                                    onChanged: (v) => setState(
                                      () => _rememberMe = v ?? true,
                                    ), // toggle
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                        6,
                                      ), // rounded
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      t.selectMethodSaveInfo, // "Save login info..."
                                      style: theme
                                          .textTheme
                                          .bodyMedium, // text style
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 12), // spacing
                        // Primary sticky action (Continue or Sign up depending on stage)
                        AppButton(
                          onPressed: _showPasswordStage
                              ? (phoneSignUpReady
                                    ? () {
                                        bloc.add(
                                          RegPasswordChanged(_pwd.text.trim()),
                                        ); // pass pwd
                                        bloc.add(
                                          RegSendVerification(),
                                        ); // send code
                                      }
                                    : null)
                              : (phoneContinueReady
                                    ? () =>
                                          setState(
                                            () => _showPasswordStage = true,
                                          ) // reveal password
                                    : null),
                          label: _showPasswordStage
                              ? t
                                    .selectMethodSignUp // "Sign Up"
                              : t.selectMethodContinue, // "Continue"
                          expand: true, // full width
                        ),

                        const SizedBox(height: 14), // spacing
                        // Only show SSO / Email buttons before password stage (clean UI)
                        if (!_showPasswordStage) ...[
                          DividerWithText(text: t.selectMethodOr), // "or"
                          const SizedBox(height: 10), // spacing
                          _ProviderButton(
                            icon: Icons.mail_outline, // mail icon
                            label: t.selectMethodContinueWithEmail, // label
                            onPressed: () => Navigator.pushNamed(
                              context,
                              Routes.registerEmail, // go email registration
                            ),
                          ),
                          const SizedBox(height: 10), // spacing
                          _ProviderButton(
                            icon: Icons.g_mobiledata, // google placeholder
                            label: t.selectMethodContinueWithGoogle, // label
                            onPressed: () => showTopToast(
                              context,
                              t.globalSuccess,
                            ), // TODO SSO
                          ),
                          const SizedBox(height: 10), // spacing
                          _ProviderButton(
                            icon: Icons.facebook, // fb icon
                            label: t.selectMethodContinueWithFacebook, // label
                            onPressed: () => showTopToast(
                              context,
                              t.globalSuccess,
                            ), // TODO SSO
                          ),
                        ],

                        const SizedBox(height: 16), // spacing
                        const LoginLink(), // "Already have an account?"
                        const SizedBox(height: 8), // bottom space
                      ],

                      // =================== STEP: OTP ===================
                      if (s.step == RegStep.code) ...[
                        const SizedBox(height: 8), // spacing
                        Text(
                          t.verifyEnterCode, // "Enter 6-digit code"
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700, // bold
                          ),
                        ),
                        const SizedBox(height: 18), // spacing
                        OtpBoxes(
                          ctrls: _otpCtrls, // your 6 controllers
                          nodes: _otpNodes, // your 6 nodes
                          onChanged: (code) {
                            // every change
                            context.read<RegisterBloc>().add(
                              RegCodeChanged(code),
                            );
                          },
                          onCompleted: (code) {
                            // when 6/6 filled
                            context.read<RegisterBloc>().add(RegVerifyCode());
                          },
                          // optional error from bloc
                        ),

                        const SizedBox(height: 20), // spacing
                        AppButton(
                          onPressed: () => bloc.add(RegVerifyCode()), // verify
                          label: t.verifyVerifyBtn, // "Verify"
                          expand: true, // full width
                        ),
                        const SizedBox(height: 10), // spacing
                        AppButton(
                          onPressed: () => bloc.add(RegResendCode()), // resend
                          type: AppButtonType.outline, // outline style
                          label: t.verifyResendBtn, // "Resend Code"
                          expand: true, // full width
                        ),
                      ],

                      // =================== USER: NAME ===================
                      if (s.step == RegStep.name) ...[
                        const SizedBox(height: 16), // spacing
                        Text(
                          t.registerCompleteStep1FirstNameQuestion, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700, // bold
                          ),
                        ),
                        const SizedBox(height: 12), // spacing
                        PillField(
                          controller: _first, // first name
                          label: t.registerCompleteStep1FirstName, // label
                          onChanged: (v) =>
                              bloc.add(RegFirstNameChanged(v)), // event
                        ),
                        const SizedBox(height: 12), // spacing
                        PillField(
                          controller: _last, // last name
                          label: t.registerCompleteStep1LastName, // label
                          onChanged: (v) =>
                              bloc.add(RegLastNameChanged(v)), // event
                        ),
                        const SizedBox(height: 16), // spacing
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.username), // next step
                          ),
                          label:
                              t.registerCompleteButtonsContinue, // "Continue"
                          expand: true, // full width
                        ),
                      ],

                      // =================== USER: USERNAME ===================
                      if (s.step == RegStep.username) ...[
                        const SizedBox(height: 16), // spacing
                        Text(
                          t.registerCompleteStep2ChooseUsername, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700, // bold
                          ),
                        ),
                        const SizedBox(height: 12), // spacing
                        PillField(
                          controller: _username, // username
                          label: t.registerCompleteStep2Username, // label
                          helper:
                              '${t.registerCompleteStep2UsernameHint1}\n'
                              '${t.registerCompleteStep2UsernameHint2}\n'
                              '${t.registerCompleteStep2UsernameHint3}', // hints
                          onChanged: (v) =>
                              bloc.add(RegUsernameChanged(v)), // event
                        ),
                        const SizedBox(height: 16), // spacing
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.profile), // next step
                          ),
                          label:
                              t.registerCompleteButtonsContinue, // "Continue"
                          expand: true, // full width
                        ),
                      ],

                      // =================== USER: PROFILE ===================
                      if (s.step == RegStep.profile) ...[
                        const SizedBox(height: 12), // spacing
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              final img = await _picker.pickImage(
                                source:
                                    ImageSource.gallery, // pick from gallery
                              );
                              bloc.add(RegPickUserImage(img)); // event
                              showTopToast(
                                context,
                                t.registerAddProfilePhoto, // info toast
                                type: ToastType.info,
                              );
                            },
                            child: Stack(
                              clipBehavior: Clip.none, // allow overflow
                              children: [
                                CircleAvatar(
                                  radius: 56, // size
                                  backgroundColor:
                                      cs.surfaceVariant, // bg color
                                  backgroundImage: s.userImage != null
                                      ? Image.file(File(s.userImage!.path))
                                            .image // preview
                                      : null, // else null
                                  child: s.userImage == null
                                      ? const Icon(
                                          Icons.person,
                                          size: 48,
                                        ) // placeholder
                                      : null, // else nothing
                                ),
                                if (s.userImage !=
                                    null) // show clear button if chosen
                                  Positioned(
                                    right: -4, // offset
                                    top: -4, // offset
                                    child: InkWell(
                                      onTap: () => bloc.add(
                                        RegPickUserImage(null),
                                      ), // clear
                                      child: Container(
                                        width: 26, // size
                                        height: 26, // size
                                        decoration: BoxDecoration(
                                          color: cs.error, // red
                                          shape: BoxShape.circle, // round
                                        ),
                                        child: Icon(
                                          Icons.close,
                                          size: 16,
                                          color: cs.onError,
                                        ), // x
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12), // spacing
                        SwitchListTile(
                          value: s.userPublic, // public flag
                          onChanged: (v) =>
                              bloc.add(RegUserPublicToggled(v)), // toggle
                          title: Text(
                            t.registerCompleteStep3PublicProfile,
                          ), // label
                        ),
                        const SizedBox(height: 8), // spacing
                        AppButton(
                          onPressed: () =>
                              bloc.add(RegSubmitUserProfile()), // complete
                          label: t.registerCompleteButtonsFinish, // "Finish"
                          expand: true, // full width
                        ),
                      ],

                      // =================== USER: INTERESTS ===================
                      if (s.step == RegStep.interests) ...[
                        if (s.interestsLoading) ...[
                          const SizedBox(height: 24), // spacing
                          const Center(
                            child: CircularProgressIndicator(),
                          ), // loader
                          const SizedBox(height: 24), // spacing
                        ] else if ((s.interestsError ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8), // spacing
                          Center(
                            child: Text(
                              t.interestLoadError, // generic error text
                              textAlign: TextAlign.center, // center
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: cs.error,
                              ), // red
                            ),
                          ),
                          const SizedBox(height: 12), // spacing
                          AppButton(
                            onPressed: () =>
                                bloc.add(RegFetchInterests()), // retry
                            label: t.selectMethodContinue, // reuse "Continue"
                            expand: true, // full width
                          ),
                        ] else ...[
                          InterestsGridRemote(
                            items: s.interestOptions, // options from backend
                            selected: s.interests, // selected ids
                            showAll: _showAllInterests, // expand/collapse
                            onToggleShow: () => setState(
                              () => _showAllInterests =
                                  !_showAllInterests, // toggle
                            ),
                            onToggle: (id) => bloc.add(
                              RegToggleInterest(id),
                            ), // add/remove interest
                            onSubmit: () =>
                                bloc.add(RegSubmitInterests()), // save
                          ),
                        ],
                      ],

                      // =================== BUSINESS: STEPS (name → details → profile) ===================
                      if (s.step == RegStep.bizName) ...[
                        const SizedBox(height: 16), // spacing
                        Text(
                          t.registerCompleteStep1BusinessName, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        const SizedBox(height: 12), // spacing
                        PillField(
                          controller: _bizName, // controller
                          label: t.registerBusinessName, // label
                          onChanged: (v) =>
                              bloc.add(RegBusinessNameChanged(v)), // event
                        ),
                        const SizedBox(height: 16), // spacing
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.bizDetails), // next
                          ),
                          label:
                              t.registerCompleteButtonsContinue, // "Continue"
                          expand: true, // full width
                        ),
                      ],

                      if (s.step == RegStep.bizDetails) ...[
                        const SizedBox(height: 8), // spacing
                        Text(
                          t.registerCompleteStep2BusinessDescription, // title
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        AppTextField(
                          controller: _bizDesc, // controller
                          label: t.registerDescription, // label
                          maxLines: 4, // textarea style
                          borderRadius: 18, // rounded
                          onChanged: (v) =>
                              bloc.add(RegBusinessDescChanged(v)), // event
                        ),
                        const SizedBox(height: 12), // spacing
                        Text(
                          t.registerCompleteStep2WebsiteUrl, // title
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        PillField(
                          controller: _bizWebsite, // controller
                          label: t.registerWebsite, // label
                          onChanged: (v) =>
                              bloc.add(RegBusinessWebsiteChanged(v)), // event
                        ),
                        const SizedBox(height: 16), // spacing
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(
                            s.copyWith(step: RegStep.bizProfile), // next
                          ),
                          label:
                              t.registerCompleteButtonsContinue, // "Continue"
                          expand: true, // full width
                        ),
                      ],

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
                            final img = await _picker.pickImage(
                              source: ImageSource.gallery,
                            ); // pick
                            bloc.add(RegPickBusinessLogo(img)); // event
                          },
                        ),
                        const SizedBox(height: 12), // spacing
                        Text(
                          t.registerSelectBanner, // title
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w700,
                          ), // bold
                        ),
                        PickBox(
                          label: t.registerSelectBanner, // tile label
                          onPick: () async {
                            final img = await _picker.pickImage(
                              source: ImageSource.gallery,
                            ); // pick
                            bloc.add(RegPickBusinessBanner(img)); // event
                          },
                        ),
                        const SizedBox(height: 16), // spacing
                        AppButton(
                          onPressed: () =>
                              bloc.add(RegSubmitBusinessProfile()), // submit
                          label: t.registerCompleteButtonsFinish, // "Finish"
                          expand: true, // full width
                        ),
                      ],

                      // =================== DONE ===================
                      if (s.step == RegStep.done) ...[
                        const SizedBox(height: 40), // spacing
                        Icon(
                          Icons.check_circle,
                          size: 64,
                          color: cs.primary,
                        ), // big check
                        const SizedBox(height: 10), // spacing
                        Center(
                          child: Text(
                            s.roleIndex == 0
                                ? t.registerSuccessUser
                                : t.registerSuccessBusiness, // success text
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ), // bold
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // global loading overlay
                if (s.loading)
                  Container(
                    color: Colors.black.withOpacity(.12), // soft dim
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // compact
                        children: [
                          const CircularProgressIndicator(), // spinner
                          const SizedBox(height: 10), // spacing
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

// ======================= helper: outlined provider button =======================

class _ProviderButton extends StatelessWidget {
  final IconData icon; // leading icon
  final String label; // text label
  final VoidCallback? onPressed; // tap callback
  const _ProviderButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  }); // ctor

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return SizedBox(
      height: 48, // standard button height
      child: OutlinedButton.icon(
        onPressed: onPressed, // tap
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cs.outlineVariant), // thin border
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ), // rounded
        ),
        icon: Icon(icon), // icon
        label: Align(
          alignment: Alignment.centerLeft,
          child: Text(label),
        ), // left-aligned text
      ),
    );
  }
}
