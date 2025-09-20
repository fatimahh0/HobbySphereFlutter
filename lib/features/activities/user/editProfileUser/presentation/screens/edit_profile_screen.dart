// ===== Flutter 3.35.x =====
// EditProfileScreen — contact is either phone OR email (no toggle).

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';

import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/l10n/app_localizations.dart';

import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';

import '../bloc/edit_profile_bloc.dart';
import '../bloc/edit_profile_state.dart';
import '../bloc/edit_profile_event.dart';

class EditProfileScreen extends StatefulWidget {
  final String token;
  final int userId;

  const EditProfileScreen({
    super.key,
    required this.token,
    required this.userId,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  final _firstCtrl = TextEditingController();
  final _lastCtrl = TextEditingController();
  final _usernameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _newPwdCtrl = TextEditingController();
  final _confirmPwdCtrl = TextEditingController();

  String? _phoneE164;
  String? _initialIso = "US";

  bool _inited = false;
  bool _usePhone = false; // chosen automatically from user data
  File? _pickedImage;
  bool _removeImage = false;

  final _deletePwdCtrl = TextEditingController();

  @override
  void dispose() {
    _firstCtrl.dispose();
    _lastCtrl.dispose();
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _newPwdCtrl.dispose();
    _confirmPwdCtrl.dispose();
    _deletePwdCtrl.dispose();
    super.dispose();
  }

  String _fullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    final base = (g.appServerRoot ?? '').replaceFirst(RegExp(r'/api/?$'), '');
    return "$base$path";
  }

  Future<void> _pickImage() async {
    final cs = Theme.of(context).colorScheme;
    showModalBottomSheet(
      context: context,
      backgroundColor: cs.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final t = AppLocalizations.of(ctx)!;
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _circleAction(
                  icon: Icons.photo_camera,
                  color: cs.primary,
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final img = await ImagePicker().pickImage(
                        source: ImageSource.camera,
                        maxWidth: 1600,
                        imageQuality: 85,
                      );
                      if (!mounted) return;
                      if (img != null) {
                        setState(() {
                          _pickedImage = File(img.path);
                          _removeImage = false;
                        });
                        showTopToast(
                          context,
                          t.editProfileImageSelectedSuccess,
                          type: ToastType.success,
                        );
                      } else {
                        showTopToast(
                          context,
                          t.editProfileImageSelectionCancelled,
                        );
                      }
                    } catch (_) {
                      showTopToast(
                        context,
                        t.editProfileImageSelectionError,
                        type: ToastType.error,
                      );
                    }
                  },
                ),
                _circleAction(
                  icon: Icons.photo_library,
                  color: cs.primary,
                  onTap: () async {
                    Navigator.pop(ctx);
                    try {
                      final img = await ImagePicker().pickImage(
                        source: ImageSource.gallery,
                        maxWidth: 2000,
                        imageQuality: 85,
                      );
                      if (!mounted) return;
                      if (img != null) {
                        setState(() {
                          _pickedImage = File(img.path);
                          _removeImage = false;
                        });
                        showTopToast(
                          context,
                          t.editProfileImageSelectedSuccess,
                          type: ToastType.success,
                        );
                      } else {
                        showTopToast(
                          context,
                          t.editProfileImageSelectionCancelled,
                        );
                      }
                    } catch (_) {
                      showTopToast(
                        context,
                        t.editProfileImageSelectionError,
                        type: ToastType.error,
                      );
                    }
                  },
                ),
                _circleAction(
                  icon: Icons.delete_forever_rounded,
                  color: Theme.of(context).colorScheme.error,
                  onTap: () {
                    Navigator.pop(ctx);
                    _confirmRemoveImage();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _circleAction({
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final cs = Theme.of(context).colorScheme;
    return CircleAvatar(
      radius: 26,
      backgroundColor: color.withOpacity(0.14),
      child: IconButton(
        icon: Icon(icon, color: color),
        onPressed: onTap,
        splashRadius: 28,
        tooltip: '',
        color: cs.onPrimary,
      ),
    );
  }

  void _confirmRemoveImage() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editProfileDeleteProfileImage),
        content: Text(t.editProfileDeleteProfileImageConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.editProfileCancel),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              setState(() {
                _pickedImage = null;
                _removeImage = true;
              });
              context.read<EditProfileBloc>().add(
                DeleteProfileImagePressed(widget.token, widget.userId),
              );
            },
            child: Text(t.editProfileDelete),
          ),
        ],
      ),
    );
  }

  bool _validateAndSubmit() {
    final t = AppLocalizations.of(context)!;

    if (!(_formKey.currentState?.validate() ?? false)) return false;

    if (_newPwdCtrl.text.isNotEmpty &&
        _newPwdCtrl.text != _confirmPwdCtrl.text) {
      showTopToast(
        context,
        t.editProfilePasswordMismatch,
        type: ToastType.error,
        haptics: true,
      );
      return false;
    }

    if (_usePhone) {
      if (_phoneE164 == null || _phoneE164!.trim().isEmpty) {
        showTopToast(
          context,
          t.loginErrorRequired,
          type: ToastType.error,
          haptics: true,
        );
        return false;
      }
    } else {
      final email = _emailCtrl.text.trim();
      if (email.isEmpty ||
          !RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)) {
        showTopToast(
          context,
          t.editProfileEmailInvalid,
          type: ToastType.error,
          haptics: true,
        );
        return false;
      }
    }
    return true;
  }

  void _onSave() {
    if (!_validateAndSubmit()) return;

    context.read<EditProfileBloc>().add(
      SaveEditProfile(
        token: widget.token,
        userId: widget.userId,
        firstName: _firstCtrl.text.trim(),
        lastName: _lastCtrl.text.trim(),
        username: _usernameCtrl.text.trim().isEmpty
            ? null
            : _usernameCtrl.text.trim(),
        email: _usePhone ? null : _emailCtrl.text.trim(),
        phoneNumber: _usePhone ? _phoneE164 : null,
        newPassword: _newPwdCtrl.text.isNotEmpty ? _newPwdCtrl.text : null,
        imagePath: _pickedImage?.path,
        removeImage: _removeImage,
      ),
    );
  }

  void _confirmDeleteAccount() {
    final t = AppLocalizations.of(context)!;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(t.editProfileDeleteConfirmTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(t.editProfileDeleteConfirmMsg),
            const SizedBox(height: 12),
            AppPasswordField(
              controller: _deletePwdCtrl,
              label: t.editProfileCurrentPassword,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(t.editProfileCancel),
          ),
          ElevatedButton(
            onPressed: () {
              final pwd = _deletePwdCtrl.text.trim();
              if (pwd.isEmpty) {
                showTopToast(
                  context,
                  t.editProfilePasswordRequired,
                  type: ToastType.error,
                  haptics: true,
                );
                return;
              }
              Navigator.pop(ctx);
              context.read<EditProfileBloc>().add(
                DeleteAccountPressed(widget.token, widget.userId, pwd),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
              foregroundColor: Theme.of(context).colorScheme.onError,
            ),
            child: Text(t.editProfileDelete),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<EditProfileBloc, EditProfileState>(
      listener: (ctx, state) {
        if (state is EditProfileLoaded && state.updated) {
          showTopToast(
            context,
            t.editProfileUpdateSuccess,
            type: ToastType.success,
          );
        }
        if (state is EditProfileError) {
          showTopToast(
            context,
            state.message,
            type: ToastType.error,
            haptics: true,
          );
        }
      },
      builder: (ctx, state) {
        if (state is EditProfileLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is EditProfileLoaded) {
          final u = state.user;

          // one-time populate
          if (!_inited) {
            _firstCtrl.text = u.firstName;
            _lastCtrl.text = u.lastName;
            _usernameCtrl.text = u.username ?? '';
            _emailCtrl.text = u.email ?? '';
            _phoneE164 = u.phoneNumber;

            // decide contact type once: prefer phone if present
            _usePhone = (u.phoneNumber != null && u.phoneNumber!.isNotEmpty);
            _inited = true;
          }

          return Scaffold(
            appBar: AppBar(title: Text(t.editProfileTitle), centerTitle: false),
            body: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                children: [
                  // ===== Avatar =====
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 54,
                        backgroundColor: cs.surfaceVariant,
                        backgroundImage: _pickedImage != null
                            ? FileImage(_pickedImage!)
                            : (u.profileImageUrl != null
                                      ? NetworkImage(
                                          _fullUrl(u.profileImageUrl),
                                        )
                                      : null)
                                  as ImageProvider<Object>?,
                        child:
                            (u.profileImageUrl == null && _pickedImage == null)
                            ? Icon(Icons.person, size: 54, color: cs.outline)
                            : null,
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: FloatingActionButton.small(
                          heroTag: 'pickProfile',
                          onPressed: _pickImage,
                          backgroundColor: cs.primary,
                          foregroundColor: cs.onPrimary,
                          child: const Icon(Icons.edit),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  // ===== Form =====
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _firstCtrl,
                          label: t.editProfileFirstName,
                          margin: const EdgeInsets.only(bottom: 14),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? t.loginErrorRequired
                              : null,
                        ),
                        AppTextField(
                          controller: _lastCtrl,
                          label: t.editProfileLastName,
                          margin: const EdgeInsets.only(bottom: 14),
                          validator: (v) => (v == null || v.trim().isEmpty)
                              ? t.loginErrorRequired
                              : null,
                        ),
                        AppTextField(
                          controller: _usernameCtrl,
                          label: t.editProfileUsername,
                          margin: const EdgeInsets.only(bottom: 14),
                        ),

                        // ===== Contact: one field only (no toggle) =====
                        if (_usePhone)
                          Material(
                            color: cs.surface,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(22),
                              side: BorderSide(
                                color: cs.outlineVariant,
                                width: 1,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                              ),
                              child: IntlPhoneField(
                                initialCountryCode: _initialIso,
                                initialValue: _phoneE164,
                                decoration: InputDecoration(
                                  labelText: t.editProfileContact,
                                  border: InputBorder.none,
                                  counterText: '',
                                ),
                                onChanged: (p) {
                                  _phoneE164 = p.completeNumber;
                                  _initialIso = p.countryISOCode;
                                },
                                pickerDialogStyle: PickerDialogStyle(
                                  searchFieldInputDecoration: InputDecoration(
                                    prefixIcon: const Icon(Icons.search),
                                    hintText: t.searchPlaceholder,
                                  ),
                                ),
                              ),
                            ),
                          )
                        else
                          AppTextField(
                            controller: _emailCtrl,
                            label: t.editProfileEmail,
                            margin: const EdgeInsets.only(bottom: 6),
                            validator: (v) {
                              final s = v?.trim() ?? '';
                              if (s.isEmpty) return t.loginErrorRequired;
                              final ok = RegExp(
                                r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                              ).hasMatch(s);
                              return ok ? null : t.editProfileEmailInvalid;
                            },
                          ),

                        // ===== New password =====
                        AppPasswordField(
                          controller: _newPwdCtrl,
                          label: t.editProfileNewPassword,
                          margin: const EdgeInsets.only(top: 6, bottom: 12),
                        ),
                        AppPasswordField(
                          controller: _confirmPwdCtrl,
                          label: t.confirmPassword,
                          margin: const EdgeInsets.only(bottom: 22),
                        ),
                      ],
                    ),
                  ),

                  // ===== Save / Delete =====
                  AppButton(
                    label: t.editProfileSaveChanges,
                    expand: true,
                    onPressed: _onSave,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: t.editProfileDeleteAccount,
                    type: AppButtonType.outline,
                    expand: true,
                    onPressed: _confirmDeleteAccount,
                  ),
                ],
              ),
            ),
          );
        }

        return const Scaffold();
      },
    );
  }
}
