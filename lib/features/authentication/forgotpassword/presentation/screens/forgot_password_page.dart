// Flutter 3.35.x — simple, clean, and professional.
// Every line has a small comment.

import 'package:flutter/material.dart'; // UI
import 'package:flutter_bloc/flutter_bloc.dart'; // bloc

import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/bloc/forgot_bloc.dart';
import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/bloc/forgot_event.dart';
import 'package:hobby_sphere/features/authentication/forgotpassword/presentation/bloc/forgot_state.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart'; // toast
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'; // AppTextField
import 'package:hobby_sphere/shared/widgets/app_text_field.dart'
    show AppPasswordField; // AppPasswordField

import '../../data/services/forgot_service.dart'; // service
import '../../data/repositories/forgot_repository_impl.dart'; // repo impl
import '../../domain/usecases/send_reset_code.dart'; // uc
import '../../domain/usecases/verify_reset_code.dart'; // uc
import '../../domain/usecases/update_password.dart'; // uc

/// Page argument to choose role (optional).
class ForgotPasswordArgs {
  final bool isBusiness; // true -> business, false -> user
  const ForgotPasswordArgs({this.isBusiness = false}); // default user
}

/// Entry widget to provide BLoC + DI.
class ForgotPasswordPage extends StatelessWidget {
  // optional args
  final ForgotPasswordArgs? args; // role arg
  const ForgotPasswordPage({super.key, this.args}); // ctor

  @override
  Widget build(BuildContext context) {
    // build services + repo + use cases
    final service = ForgotService(); // http service
    final repo = ForgotRepositoryImpl(service); // repository
    final sendUC = SendResetCode(repo); // UC1
    final verifyUC = VerifyResetCode(repo); // UC2
    final updateUC = UpdatePassword(repo); // UC3

    // provide BLoC to UI
    return BlocProvider(
      // create BLoC with role from args
      create: (_) => ForgotBloc(
        sendResetCode: sendUC, // inject
        verifyResetCode: verifyUC, // inject
        updatePassword: updateUC, // inject
        isBusiness: args?.isBusiness ?? false, // initial role
      ),
      child: const _ForgotView(), // render view
    );
  }
}

/// Internal stateful view for form handling.
class _ForgotView extends StatefulWidget {
  const _ForgotView(); // ctor
  @override
  State<_ForgotView> createState() => _ForgotViewState(); // state
}

class _ForgotViewState extends State<_ForgotView> {
  // controllers for fields
  final _email = TextEditingController(); // email ctrl
  final _code = TextEditingController(); // code ctrl
  final _pwd = TextEditingController(); // new pwd ctrl

  @override
  void dispose() {
    // clean controllers
    _email.dispose(); // email
    _code.dispose(); // code
    _pwd.dispose(); // pwd
    super.dispose(); // parent
  }

  @override
  Widget build(BuildContext context) {
    // get theme and colors
    final theme = Theme.of(context); // theme
    final cs = theme.colorScheme; // color scheme

    return Scaffold(
      // page shell
      appBar: AppBar(
        // top bar
        title: const Text('Forgot Password'), // title text
      ),
      body: BlocConsumer<ForgotBloc, ForgotState>(
        // listen + build
        listenWhen: (p, c) => p != c, // only on changes
        listener: (context, s) {
          // show error toast
          if (s.error?.isNotEmpty == true) {
            showTopToast(
              context,
              s.error!,
              type: ToastType.error,
              haptics: true,
            ); // error toast
          }
          // show info toast
          if (s.info?.isNotEmpty == true) {
            showTopToast(
              context,
              s.info!,
              type: ToastType.success,
            ); // success toast
          }
        },
        builder: (context, s) {
          // get bloc
          final bloc = context.read<ForgotBloc>(); // bloc

          return Stack(
            // allow overlay
            children: [
              SingleChildScrollView(
                // scroll content
                padding: const EdgeInsets.all(16), // outer padding
                child: Column(
                  // vertical layout
                  crossAxisAlignment: CrossAxisAlignment.stretch, // full width
                  children: [
                    // role toggle row
                    Row(
                      // role row
                      children: [
                        // user pill
                        ChoiceChip(
                          // chip
                          label: const Text('User'), // text
                          selected: !s.isBusiness, // selected if user
                          onSelected: (v) =>
                              bloc.add(ForgotRoleChanged(false)), // set user
                        ),
                        const SizedBox(width: 8), // space
                        // business pill
                        ChoiceChip(
                          // chip
                          label: const Text('Business'), // text
                          selected: s.isBusiness, // selected if business
                          onSelected: (v) =>
                              bloc.add(ForgotRoleChanged(true)), // set business
                        ),
                      ],
                    ),

                    const SizedBox(height: 16), // space
                    // step header
                    Text(
                      // title
                      s.step == ForgotStep.enterEmail
                          ? 'Step 1: Enter email'
                          : s.step == ForgotStep.enterCode
                          ? 'Step 2: Enter code'
                          : 'Step 3: New password', // dynamic title
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ), // style
                    ),

                    const SizedBox(height: 12), // space

                    if (s.step == ForgotStep.enterEmail) ...[
                      // email field
                      AppTextField(
                        // shared field
                        controller: _email, // controller
                        label: 'Email', // label
                        hint: 'name@example.com', // hint
                        keyboardType: TextInputType.emailAddress, // email type
                        onChanged: (v) =>
                            bloc.add(ForgotEmailChanged(v.trim())), // track
                        filled: true, // filled style
                      ),
                      const SizedBox(height: 12), // space
                      // send button
                      FilledButton.icon(
                        // M3 button
                        onPressed: s.loading
                            ? null
                            : () => bloc.add(ForgotSendCodePressed()), // action
                        icon: const Icon(Icons.send), // icon
                        label: const Text('Send code'), // text
                      ),
                    ],

                    if (s.step == ForgotStep.enterCode) ...[
                      // email (read-only recap)
                      AppTextField(
                        // email recap
                        controller: _email, // same controller
                        label: 'Email', // label
                        hint: 'name@example.com', // hint
                        readOnly: true, // lock field
                        filled: true, // filled
                      ),
                      const SizedBox(height: 12), // space
                      // code field (6 digits)
                      AppTextField(
                        // code input
                        controller: _code, // controller
                        label: 'Code', // label
                        hint: 'Enter the code', // hint
                        keyboardType: TextInputType.number, // number keypad
                        maxLength: 6, // 6 chars
                        onChanged: (v) =>
                            bloc.add(ForgotCodeChanged(v.trim())), // track
                        filled: true, // filled
                      ),
                      const SizedBox(height: 12), // space
                      // verify button
                      FilledButton.icon(
                        // button
                        onPressed: s.loading
                            ? null
                            : () =>
                                  bloc.add(ForgotVerifyCodePressed()), // action
                        icon: const Icon(Icons.verified), // icon
                        label: const Text('Verify code'), // text
                      ),
                    ],

                    if (s.step == ForgotStep.enterNew) ...[
                      // email recap
                      AppTextField(
                        // same email
                        controller: _email, // controller
                        label: 'Email', // label
                        hint: 'name@example.com', // hint
                        readOnly: true, // lock
                        filled: true, // filled
                      ),
                      const SizedBox(height: 12), // space
                      // new password field
                      AppPasswordField(
                        // shared pwd field
                        controller: _pwd, // controller
                        label: 'New password', // label
                        hint: 'Enter new password', // hint
                        onChanged: (v) => bloc.add(
                          ForgotNewPasswordChanged(v.trim()),
                        ), // track
                      ),
                      const SizedBox(height: 12), // space
                      // update button
                      FilledButton.icon(
                        // button
                        onPressed: s.loading
                            ? null
                            : () => bloc.add(
                                ForgotUpdatePasswordPressed(),
                              ), // action
                        icon: const Icon(Icons.lock_reset), // icon
                        label: const Text('Update password'), // text
                      ),
                    ],
                  ],
                ),
              ),

              if (s.loading)
                // loading overlay
                Container(
                  // dim bg
                  color: Colors.black.withOpacity(.08), // light dim
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ), // spinner
                ),
            ],
          );
        },
      ),
    );
  }
}
