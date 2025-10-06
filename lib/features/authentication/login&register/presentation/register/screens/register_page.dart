// ===== register_page.dart — Flutter 3.35.x =====
// - Fix: picked image now displays immediately.
// - Add: choose image from Camera or Gallery (for user photo, business logo, banner).
// - Safe: handles cancel/error, compresses a bit (imageQuality), and rebuilds via Bloc state.

// ---- core ----
import 'dart:io'; // File for local image preview
import 'package:flutter/material.dart'; // UI
import 'package:flutter/services.dart'; // PlatformException for picker errors
import 'package:flutter_bloc/flutter_bloc.dart'; // Bloc
import 'package:image_picker/image_picker.dart'; // pick images

// ---- domain/usecases for remote interests ----
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/get_activity_types.dart'; // interests

// ---- shared widgets ----
import 'package:hobby_sphere/shared/widgets/phone_input.dart'; // phone field
import 'package:hobby_sphere/shared/widgets/app_button.dart'; // buttons
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // text fields
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toasts

// ---- login/register widgets ----
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/widgets/role_selector.dart'; // role pills
import 'package:hobby_sphere/features/authentication/login&register/presentation/login/widgets/password_input.dart'; // password field
import '../widgets/login_link.dart'; // "Already have an account?"
import '../widgets/guidelines.dart'; // password rules
import '../widgets/otp_boxes.dart'; // 6-digit boxes
import '../widgets/pill_field.dart'; // rounded text field
import '../widgets/pick_box.dart'; // tile look box (we hook it to our picker)
import '../widgets/divider_with_text.dart'; // "or"
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/widgets/interests_grid.dart'; // interests grid

// ---- bloc ----
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_bloc.dart'; // bloc
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_event.dart'; // events
import 'package:hobby_sphere/features/authentication/login&register/presentation/register/bloc/register_state.dart'; // state

// ---- DI: services + repos ----
import 'package:hobby_sphere/features/authentication/login&register/data/services/registration_service.dart'; // http
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/registration_repository_impl.dart'; // repo
import 'package:hobby_sphere/features/authentication/login&register/data/repositories/interests_repository_impl.dart'; // repo

// ---- usecases (user) ----
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/send_user_verification.dart'; // send code
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_user_email_code.dart'; // verify email
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_user_phone_code.dart'; // verify phone
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/complete_user_profile.dart'; // complete profile
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/add_user_interests.dart'; // add interests
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/resend_user_code.dart'; // resend

// ---- usecases (business) ----
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/send_business_verification.dart'; // send code
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_business_email_code.dart'; // verify email
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/verify_business_phone_code.dart'; // verify phone
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/complete_business_profile.dart'; // complete
import 'package:hobby_sphere/features/authentication/login&register/domain/usecases/register/resend_business_code.dart'; // resend

// ---- l10n + routes ----
import 'package:hobby_sphere/l10n/app_localizations.dart'; // i18n
import 'package:hobby_sphere/app/router/router.dart' show Routes; // routes

// ======================= Public entry =======================
class RegisterPage extends StatelessWidget {
  final RegistrationService service; // backend service
  const RegisterPage({super.key, required this.service}); // ctor

  @override
  Widget build(BuildContext context) {
    final regRepo = RegistrationRepositoryImpl(service); // repo
    final interestsRepo = InterestsRepositoryImpl(service); // repo

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
      ),
      child: const _RegisterView(), // view
    );
  }
}

// ======================= View (stateful) =======================
class _RegisterView extends StatefulWidget {
  const _RegisterView(); // ctor
  @override
  State<_RegisterView> createState() => _RegisterViewState(); // state
}

class _RegisterViewState extends State<_RegisterView> {
  // ---- text controllers ----
  final _pwd = TextEditingController(); // password
  final _pwd2 = TextEditingController(); // confirm
  final _otpCtrls = List.generate(6, (_) => TextEditingController()); // 6 boxes
  final _otpNodes = List.generate(6, (_) => FocusNode()); // 6 nodes

  final _first = TextEditingController(); // first name
  final _last = TextEditingController(); // last name
  final _username = TextEditingController(); // username

  final _bizName = TextEditingController(); // business name
  final _bizDesc = TextEditingController(); // business desc
  final _bizWebsite = TextEditingController(); // website

  // ---- local ui state ----
  final ImagePicker _picker = ImagePicker(); // single picker instance
  bool _pwdObscure = true; // hide/show password
  bool _pwd2Obscure = true; // hide/show confirm
  bool _rememberMe = true; // remember flag
  bool _showAllInterests = true; // expand/collapse interests
  String _e164Phone = ''; // normalized phone
  bool _showPasswordStage = false; // password stage toggle
  bool _requestedInterests = false; // avoid duplicate fetch

  // ---- helpers: bottom sheet to choose camera/gallery ----
  Future<XFile?> _chooseAndPick({
    required BuildContext context, // for sheet
    required AppLocalizations t, // for labels
  }) async {
    // show bottom sheet to choose source
    final source = await showModalBottomSheet<ImageSource>(
      context: context, // current context
      showDragHandle: true, // nice handle
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ), // rounded sheet
      builder: (_) => _ImageSourceSheet(t: t), // custom widget (below)
    );

    // if user closed sheet, return null
    if (source == null) return null; // canceled

    try {
      // pick with compression + reasonable max size
      final x = await _picker.pickImage(
        source: source, // camera or gallery
        imageQuality: 85, // compress a bit
        maxWidth: 1600, // downscale
        maxHeight: 1600, // downscale
      );
      return x; // may be null (user canceled)
    } on PlatformException catch (e) {
      // show error toast if permission/other error
      showTopToast(
        context,
        '${t.globalError}: ${e.code}', // simple error text
        type: ToastType.error,
      );
      return null; // fail safe
    }
  }

  @override
  void dispose() {
    // dispose controllers/nodes to avoid leaks
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
    super.dispose(); // super
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!; // strings
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // colors

    return Scaffold(
      appBar: AppBar(
        elevation: 0, // flat
        backgroundColor: theme.scaffoldBackgroundColor, // same as bg
        leading: const BackButton(), // back arrow
      ),
      body: BlocConsumer<RegisterBloc, RegisterState>(
        listenWhen: (p, c) => p != c, // listen on change
        listener: (context, s) {
          // show error toast
          if (s.error?.isNotEmpty == true) {
            showTopToast(context, s.error!, type: ToastType.error, haptics: true);
          }
          // show info toast
          if (s.info?.isNotEmpty == true) {
            showTopToast(context, s.info!, type: ToastType.info);
          }
          // final success
          if (s.step == RegStep.done) {
            showTopToast(
              context,
              s.roleIndex == 0 ? t.registerSuccessUser : t.registerSuccessBusiness,
              type: ToastType.success,
            );
          }
          // copy code to boxes
          if (s.code.length == 6) {
            for (var i = 0; i < 6; i++) {
              _otpCtrls[i].text = s.code[i]; // copy digit
            }
          }
        },
        builder: (context, s) {
          final bloc = context.read<RegisterBloc>(); // bloc

          // compute buttons enabled
          final phoneContinueReady = !_showPasswordStage && _e164Phone.isNotEmpty; // has phone
          final phoneSignUpReady = _showPasswordStage && _pwd.text.length >= 8 && _pwd.text == _pwd2.text; // passwords ok

          // lazy fetch interests one time
          if (s.step == RegStep.interests &&
              !_requestedInterests &&
              !s.interestsLoading &&
              s.interestOptions.isEmpty) {
            _requestedInterests = true; // guard
            WidgetsBinding.instance.addPostFrameCallback((_) {
              bloc.add(RegFetchInterests()); // fetch now
            });
          }

          return SafeArea(
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8), // page padding
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch, // full width
                    children: [
                      // ===== contact (phone-first) =====
                      if (s.step == RegStep.contact) ...[
                        const SizedBox(height: 8), // space
                        Text(
                          t.selectMethodTitle, // "Sign up"
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        const SizedBox(height: 18), // space
                        Center(
                          child: RoleSelector(
                            value: s.roleIndex, // current role
                            onChanged: (i) => bloc.add(RegRoleChanged(i)), // change role
                          ),
                        ),
                        const SizedBox(height: 20), // space
                        PhoneInput(
                          initialIso: 'CA', // default country
                          submittedOnce: false,// visual validation
                          onChanged: (e164, _, __) {
                            setState(() => _e164Phone = e164 ?? ''); // store
                            bloc.add(RegPhoneChanged(e164 ?? '')); // update bloc
                          },
                          onSwapToEmail: () => Navigator.pushNamed(
                            context,
                            Routes.registerEmail, // email flow route
                            arguments: {
                              'roleIndex': context.read<RegisterBloc>().state.roleIndex, // keep role
                            },
                          ),
                        ),
                        AnimatedCrossFade(
                          duration: const Duration(milliseconds: 220), // smooth
                          crossFadeState:
                              _showPasswordStage ? CrossFadeState.showSecond : CrossFadeState.showFirst, // stage
                          firstChild: const SizedBox(height: 12), // spacer
                          secondChild: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch, // full width
                            children: [
                              const SizedBox(height: 18), // space
                              Text(
                                t.selectMethodCreatePassword, // title
                                style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), // bold
                              ),
                              const SizedBox(height: 8), // space
                              PasswordInput(
                                controller: _pwd, // pwd
                                obscure: _pwdObscure, // hide/show
                                onToggleObscure: () => setState(() => _pwdObscure = !_pwdObscure), // toggle
                                onChanged: (_) => setState(() {}), // refresh validity
                              ),
                              const SizedBox(height: 10), // space
                              AppTextField(
                                controller: _pwd2, // confirm
                                label: t.registerConfirmPassword, // label
                                hint: t.emailRegistrationPasswordPlaceholder, // hint
                                prefix: const Icon(Icons.lock_outline), // icon
                                suffix: IconButton(
                                  icon: Icon(_pwd2Obscure ? Icons.visibility_off : Icons.visibility), // eye
                                  onPressed: () => setState(() => _pwd2Obscure = !_pwd2Obscure), // toggle
                                ),
                                obscure: _pwd2Obscure, // hide
                                textInputAction: TextInputAction.done, // ime
                                borderRadius: 28, // pill
                              ),
                              const SizedBox(height: 10), // space
                              const Guidelines(), // rules
                              const SizedBox(height: 8), // space
                              Row(
                                children: [
                                  Checkbox(
                                    value: _rememberMe, // value
                                    onChanged: (v) => setState(() => _rememberMe = v ?? true), // toggle
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), // shape
                                  ),
                                  Expanded(child: Text(t.selectMethodSaveInfo, style: theme.textTheme.bodyMedium)), // text
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12), // space
                        AppButton(
                          onPressed: _showPasswordStage
                              ? (phoneSignUpReady
                                  ? () {
                                      bloc.add(RegPasswordChanged(_pwd.text.trim())); // set pwd
                                      bloc.add(RegSendVerification()); // send code (role aware)
                                    }
                                  : null)
                              : (phoneContinueReady
                                  ? () => setState(() => _showPasswordStage = true) // show password stage
                                  : null),
                          label: _showPasswordStage ? t.selectMethodSignUp : t.selectMethodContinue, // label
                          expand: true, // full width
                        ),
                        const SizedBox(height: 14), // space
                        if (!_showPasswordStage) ...[
                          DividerWithText(text: t.selectMethodOr), // "or"
                          const SizedBox(height: 10), // space
                          _ProviderButton(
                            icon: Icons.mail_outline, // icon
                            label: t.selectMethodContinueWithEmail, // label
                            onPressed: () => Navigator.pushNamed(
                              context,
                              Routes.registerEmail, // email flow
                              arguments: {'roleIndex': context.read<RegisterBloc>().state.roleIndex}, // keep role
                            ),
                          ),
                          const SizedBox(height: 10), // space
                          _ProviderButton(
                            icon: Icons.g_mobiledata, // placeholder
                            label: t.selectMethodContinueWithGoogle, // label
                            onPressed: () => showTopToast(context, t.globalSuccess), // TODO integrate
                          ),
                          const SizedBox(height: 10), // space
                          _ProviderButton(
                            icon: Icons.facebook, // placeholder
                            label: t.selectMethodContinueWithFacebook, // label
                            onPressed: () => showTopToast(context, t.globalSuccess), // TODO integrate
                          ),
                        ],
                        const SizedBox(height: 16), // space
                        const LoginLink(), // to login
                        const SizedBox(height: 8), // bottom space
                      ],

                      // ===== code (OTP) =====
                      if (s.step == RegStep.code) ...[
                        const SizedBox(height: 8), // space
                        Text(
                          t.verifyEnterCode, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        const SizedBox(height: 18), // space
                        OtpBoxes(
                          ctrls: _otpCtrls, // ctrls
                          nodes: _otpNodes, // nodes
                          onChanged: (code) => context.read<RegisterBloc>().add(RegCodeChanged(code)), // update
                          onCompleted: (_) => context.read<RegisterBloc>().add(RegVerifyCode()), // verify
                        ),
                        const SizedBox(height: 20), // space
                        AppButton(
                          onPressed: () => bloc.add(RegVerifyCode()), // verify
                          label: t.verifyVerifyBtn, // label
                          expand: true, // full width
                        ),
                        const SizedBox(height: 10), // space
                        AppButton(
                          onPressed: () => bloc.add(RegResendCode()), // resend
                          type: AppButtonType.outline, // outline
                          label: t.verifyResendBtn, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== user: name =====
                      if (s.step == RegStep.name) ...[
                        const SizedBox(height: 16), // space
                        Text(
                          t.registerCompleteStep1FirstNameQuestion, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        const SizedBox(height: 12), // space
                        PillField(
                          controller: _first, // first
                          label: t.registerCompleteStep1FirstName, // label
                          onChanged: (v) => bloc.add(RegFirstNameChanged(v)), // update
                        ),
                        const SizedBox(height: 12), // space
                        PillField(
                          controller: _last, // last
                          label: t.registerCompleteStep1LastName, // label
                          onChanged: (v) => bloc.add(RegLastNameChanged(v)), // update
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(s.copyWith(step: RegStep.username)), // next
                          label: t.registerCompleteButtonsContinue, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== user: username =====
                      if (s.step == RegStep.username) ...[
                        const SizedBox(height: 16), // space
                        Text(
                          t.registerCompleteStep2ChooseUsername, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        const SizedBox(height: 12), // space
                        PillField(
                          controller: _username, // username
                          label: t.registerCompleteStep2Username, // label
                          helper: '${t.registerCompleteStep2UsernameHint1}\n'
                              '${t.registerCompleteStep2UsernameHint2}\n'
                              '${t.registerCompleteStep2UsernameHint3}', // hints
                          onChanged: (v) => bloc.add(RegUsernameChanged(v)), // update
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(s.copyWith(step: RegStep.profile)), // next
                          label: t.registerCompleteButtonsContinue, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== user: profile (with camera/gallery) =====
                      if (s.step == RegStep.profile) ...[
                        const SizedBox(height: 12), // space
                        Center(
                          child: GestureDetector(
                            onTap: () async {
                              // open sheet, pick camera/gallery
                              final img = await _chooseAndPick(context: context, t: t); // returns XFile?
                              if (img == null) return; // canceled
                              // send to bloc (bloc must store XFile in state.userImage and emit)
                              bloc.add(RegPickUserImage(img)); // update state
                              // small info toast
                              showTopToast(context, t.registerAddProfilePhoto, type: ToastType.info); // toast
                            },
                            child: Stack(
                              clipBehavior: Clip.none, // allow badge overflow
                              children: [
                                CircleAvatar(
                                  radius: 56, // size
                                  backgroundColor: cs.surfaceVariant, // bg
                                  // use FileImage so preview updates when state changes
                                  backgroundImage: (s.userImage != null && s.userImage!.path.isNotEmpty)
                                      ? FileImage(File(s.userImage!.path)) // show picked image
                                      : null, // else null
                                  child: (s.userImage == null || s.userImage!.path.isEmpty)
                                      ? const Icon(Icons.person, size: 48) // placeholder
                                      : null, // else nothing
                                ),
                                // small "X" to clear image
                                if (s.userImage != null && s.userImage!.path.isNotEmpty)
                                  Positioned(
                                    right: -4, // x
                                    top: -4, // y
                                    child: InkWell(
                                      onTap: () => bloc.add(RegPickUserImage(null)), // clear
                                      child: Container(
                                        width: 26, height: 26, // size
                                        decoration: BoxDecoration(color: cs.error, shape: BoxShape.circle), // red
                                        child: Icon(Icons.close, size: 16, color: cs.onError), // X
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12), // space
                        SwitchListTile(
                          value: s.userPublic, // public/private
                          onChanged: (v) => bloc.add(RegUserPublicToggled(v)), // toggle
                          title: Text(t.registerCompleteStep3PublicProfile), // label
                        ),
                        const SizedBox(height: 8), // space
                        AppButton(
                          onPressed: () => bloc.add(RegSubmitUserProfile()), // finish profile
                          label: t.registerCompleteButtonsFinish, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== user: interests =====
                      if (s.step == RegStep.interests) ...[
                        if (s.interestsLoading) ...[
                          const SizedBox(height: 24), // space
                          const Center(child: CircularProgressIndicator()), // loader
                          const SizedBox(height: 24), // space
                        ] else if ((s.interestsError ?? '').isNotEmpty) ...[
                          const SizedBox(height: 8), // space
                          Center(
                            child: Text(
                              t.interestLoadError, // error text
                              textAlign: TextAlign.center, // center
                              style: theme.textTheme.bodyMedium?.copyWith(color: cs.error), // red
                            ),
                          ),
                          const SizedBox(height: 12), // space
                          AppButton(
                            onPressed: () => bloc.add(RegFetchInterests()), // retry
                            label: t.selectMethodContinue, // reuse
                            expand: true, // full
                          ),
                        ] else ...[
                          InterestsGridRemote(
                            items: s.interestOptions, // options
                            selected: s.interests, // chosen ids
                            showAll: _showAllInterests, // flag
                            onToggleShow: () => setState(() => _showAllInterests = !_showAllInterests), // toggle
                            onToggle: (id) => bloc.add(RegToggleInterest(id)), // toggle item
                            onSubmit: () => bloc.add(RegSubmitInterests()), // submit
                          ),
                        ],
                      ],

                      // ===== business: name =====
                      if (s.step == RegStep.bizName) ...[
                        const SizedBox(height: 16), // space
                        Text(
                          t.registerCompleteStep1BusinessName, // title
                          textAlign: TextAlign.center, // center
                          style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        const SizedBox(height: 12), // space
                        PillField(
                          controller: _bizName, // name
                          label: t.registerBusinessName, // label
                          onChanged: (v) => bloc.add(RegBusinessNameChanged(v)), // update
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(s.copyWith(step: RegStep.bizDetails)), // next
                          label: t.registerCompleteButtonsContinue, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== business: details =====
                      if (s.step == RegStep.bizDetails) ...[
                        const SizedBox(height: 8), // space
                        Text(
                          t.registerCompleteStep2BusinessDescription, // title
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        AppTextField(
                          controller: _bizDesc, // desc
                          label: t.registerDescription, // label
                          maxLines: 4, // textarea
                          borderRadius: 18, // rounded
                          onChanged: (v) => bloc.add(RegBusinessDescChanged(v)), // update
                        ),
                        const SizedBox(height: 12), // space
                        Text(
                          t.registerCompleteStep2WebsiteUrl, // title
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        PillField(
                          controller: _bizWebsite, // url
                          label: t.registerWebsite, // label
                          onChanged: (v) => bloc.add(RegBusinessWebsiteChanged(v)), // update
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => context.read<RegisterBloc>().emit(s.copyWith(step: RegStep.bizProfile)), // next
                          label: t.registerCompleteButtonsContinue, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== business: profile (logo + banner with camera/gallery) =====
                      if (s.step == RegStep.bizProfile) ...[
                        Text(
                          t.registerSelectLogo, // title
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        PickBox(
                          label: t.registerSelectLogo, // tile text
                          onPick: () async {
                            final img = await _chooseAndPick(context: context, t: t); // choose source
                            if (img == null) return; // canceled
                            bloc.add(RegPickBusinessLogo(img)); // set logo
                          },
                        ),
                        const SizedBox(height: 12), // space
                        Text(
                          t.registerSelectBanner, // title
                          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), // bold
                        ),
                        PickBox(
                          label: t.registerSelectBanner, // tile text
                          onPick: () async {
                            final img = await _chooseAndPick(context: context, t: t); // choose source
                            if (img == null) return; // canceled
                            bloc.add(RegPickBusinessBanner(img)); // set banner
                          },
                        ),
                        const SizedBox(height: 16), // space
                        AppButton(
                          onPressed: () => bloc.add(RegSubmitBusinessProfile()), // submit
                          label: t.registerCompleteButtonsFinish, // label
                          expand: true, // full
                        ),
                      ],

                      // ===== done =====
                      if (s.step == RegStep.done) ...[
                        const SizedBox(height: 40), // space
                        Icon(Icons.check_circle, size: 64, color: cs.primary), // big check
                        const SizedBox(height: 10), // space
                        Center(
                          child: Text(
                            s.roleIndex == 0 ? t.registerSuccessUser : t.registerSuccessBusiness, // text
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700), // bold
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // loading overlay
                if (context.watch<RegisterBloc>().state.loading)
                  Container(
                    color: Colors.black.withOpacity(.12), // dim
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // compact
                        children: [
                          const CircularProgressIndicator(), // spinner
                          const SizedBox(height: 10), // space
                          Text(t.registerCompleteButtonsSubmitting), // "Submitting..."
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

// ======================= helper: provider button (unchanged) =======================
class _ProviderButton extends StatelessWidget {
  final IconData icon; // icon
  final String label; // text
  final VoidCallback? onPressed; // action
  const _ProviderButton({required this.icon, required this.label, required this.onPressed}); // ctor

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return SizedBox(
      height: 48, // standard height
      child: OutlinedButton.icon(
        onPressed: onPressed, // tap
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: cs.outlineVariant), // thin border
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)), // rounded
        ),
        icon: Icon(icon), // icon
        label: Align(alignment: Alignment.centerLeft, child: Text(label)), // left text
      ),
    );
  }
}

// ======================= helper: bottom sheet for image source =======================
class _ImageSourceSheet extends StatelessWidget {
  final AppLocalizations t; // i18n
  const _ImageSourceSheet({required this.t}); // ctor

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme; // colors
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16), // sheet padding
        child: Column(
          mainAxisSize: MainAxisSize.min, // wrap content
          children: [
            Container(
              width: 44, height: 4, // small handle
              decoration: BoxDecoration(
                color: cs.outlineVariant, // muted
                borderRadius: BorderRadius.circular(2), // rounded
              ),
            ),
            const SizedBox(height: 12), // space
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined), // camera icon
              title: Text(t.registerPickFromCamera), // "Take photo" (add to l10n if missing)
              onTap: () => Navigator.pop(context, ImageSource.camera), // return camera
            ),
            ListTile(
              leading: const Icon(Icons.photo_outlined), // gallery icon
              title: Text(t.registerPickFromGallery), // "Choose from gallery" (add to l10n if missing)
              onTap: () => Navigator.pop(context, ImageSource.gallery), // return gallery
            ),
            const SizedBox(height: 4), // small space
          ],
        ),
      ),
    );
  }
}
