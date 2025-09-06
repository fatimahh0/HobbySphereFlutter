// ===== Flutter 3.35.x =====
// EditBusinessScreen — Facebook-like logo + banner editing with AppTheme + PhoneInput + Delete Modal

import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';

import 'package:hobby_sphere/core/network/globals.dart' as g;
import 'package:hobby_sphere/shared/theme/app_theme.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';
import 'package:hobby_sphere/shared/widgets/app_text_field.dart';
import 'package:hobby_sphere/l10n/app_localizations.dart';

import '../bloc/edit_business_bloc.dart';
import '../bloc/edit_business_event.dart';
import '../bloc/edit_business_state.dart';

class EditBusinessScreen extends StatefulWidget {
  final String token;
  final int businessId;

  const EditBusinessScreen({
    super.key,
    required this.token,
    required this.businessId,
  });

  @override
  State<EditBusinessScreen> createState() => _EditBusinessScreenState();
}

class _EditBusinessScreenState extends State<EditBusinessScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _websiteCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _deletePasswordCtrl = TextEditingController();

  String? _phoneE164;
  String? _initialIso = "US";

  File? _logo;
  File? _banner;

  @override
  void initState() {
    super.initState();
    context.read<EditBusinessBloc>().add(
      LoadBusiness(widget.token, widget.businessId),
    );
  }

  String _fullUrl(String? path) {
    if (path == null || path.isEmpty) return '';
    final base = (g.appServerRoot ?? '').replaceFirst(RegExp(r'/api/?$'), '');
    return "$base$path";
  }

  Future<void> _pickImage({
    required bool isLogo,
    required int businessId,
  }) async {
    final cs = Theme.of(context).colorScheme;

    showModalBottomSheet(
      context: context,
      backgroundColor: cs.background,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: Icon(Icons.photo_camera, size: 32, color: cs.primary),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final img = await ImagePicker().pickImage(
                    source: ImageSource.camera,
                  );
                  if (img != null) {
                    setState(() {
                      if (isLogo) {
                        _logo = File(img.path);
                      } else {
                        _banner = File(img.path);
                      }
                    });
                  }
                },
              ),
              IconButton(
                icon: Icon(Icons.photo_library, size: 32, color: cs.primary),
                onPressed: () async {
                  Navigator.pop(ctx);
                  final img = await ImagePicker().pickImage(
                    source: ImageSource.gallery,
                  );
                  if (img != null) {
                    setState(() {
                      if (isLogo) {
                        _logo = File(img.path);
                      } else {
                        _banner = File(img.path);
                      }
                    });
                  }
                },
              ),
              IconButton(
                icon: const Icon(
                  Icons.delete,
                  size: 32,
                  color: AppColors.error,
                ),
                onPressed: () {
                  Navigator.pop(ctx);
                  if (isLogo) {
                    context.read<EditBusinessBloc>().add(
                      RemoveLogo(widget.token, businessId),
                    );
                    setState(() => _logo = null);
                  } else {
                    context.read<EditBusinessBloc>().add(
                      RemoveBanner(widget.token, businessId),
                    );
                    setState(() => _banner = null);
                  }
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _save() {
    if (_formKey.currentState?.validate() ?? false) {
      final body = {
        "name": _nameCtrl.text,
        "email": _emailCtrl.text.isEmpty ? null : _emailCtrl.text,
        "description": _descCtrl.text,
        "phoneNumber": _phoneE164,
        "websiteUrl": _websiteCtrl.text,
        if (_passwordCtrl.text.isNotEmpty) "password": _passwordCtrl.text,
        if (_logo != null) "logo": MultipartFile.fromFileSync(_logo!.path),
        if (_banner != null)
          "banner": MultipartFile.fromFileSync(_banner!.path),
      };
      context.read<EditBusinessBloc>().add(
        SaveBusiness(widget.token, widget.businessId, body, withImages: true),
      );
    }
  }

  void _confirmDelete() {
    final tr = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(tr.deleteAccount),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(tr.editBusinessConfirmPassword),
              const SizedBox(height: 12),
              AppTextField(
                controller: _deletePasswordCtrl,
                label: tr.enterPassword,
                obscure: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(tr.cancel, style: TextStyle(color: cs.error)),
            ),
            ElevatedButton(
              onPressed: () {
                if (_deletePasswordCtrl.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(tr.editProfilePasswordRequired)),
                  );
                  return;
                }
                Navigator.pop(ctx);
                context.read<EditBusinessBloc>().add(
                  DeleteBusinessEvent(
                    widget.token,
                    widget.businessId,
                    _deletePasswordCtrl.text.trim(),
                  ),
                );
              },
              child: Text(tr.confirm),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final tr = AppLocalizations.of(context)!;
    final cs = Theme.of(context).colorScheme;

    return BlocConsumer<EditBusinessBloc, EditBusinessState>(
      listener: (ctx, state) {
        if (state is EditBusinessLoaded && state.updated) {
          Navigator.pop(context, true);
        }
        if (state is EditBusinessInitial) {
          Navigator.of(
            context,
          ).pushNamedAndRemoveUntil('/login', (route) => false);
        }
        if (state is EditBusinessError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
        }
      },
      builder: (ctx, state) {
        if (state is EditBusinessLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is EditBusinessLoaded) {
          final b = state.business;
          _nameCtrl.text = b.name;
          _emailCtrl.text = b.email ?? '';
          _websiteCtrl.text = b.websiteUrl ?? '';
          _descCtrl.text = b.description;
          _phoneE164 = b.phoneNumber;

          return Scaffold(
            appBar: AppBar(title: Text(tr.editBusinessInfo)),
            body: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  // ===== Banner =====
                  Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: _banner != null
                            ? Image.file(
                                _banner!,
                                height: 180,
                                width: double.infinity,
                                fit: BoxFit.cover,
                              )
                            : (b.bannerUrl != null
                                  ? Image.network(
                                      _fullUrl(b.bannerUrl),
                                      height: 180,
                                      width: double.infinity,
                                      fit: BoxFit.cover,
                                    )
                                  : Container(
                                      height: 180,
                                      width: double.infinity,
                                      color: cs.surfaceVariant,
                                      child: Center(
                                        child: Text(
                                          tr.editBusinessBannerHint,
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodyMedium
                                              ?.copyWith(
                                                color: AppColors.muted,
                                              ),
                                        ),
                                      ),
                                    )),
                      ),
                      Positioned(
                        right: 12,
                        bottom: 12,
                        child: CircleAvatar(
                          backgroundColor: cs.primary.withOpacity(0.8),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: cs.onPrimary),
                            onPressed: () => _pickImage(
                              isLogo: false,
                              businessId: widget.businessId,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // ===== Logo =====
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      CircleAvatar(
                        radius: 55,
                        backgroundColor: cs.surfaceVariant,
                        backgroundImage: _logo != null
                            ? FileImage(_logo!)
                            : (b.logoUrl != null
                                  ? NetworkImage(_fullUrl(b.logoUrl!))
                                  : null),
                        child: (b.logoUrl == null && _logo == null)
                            ? Icon(
                                Icons.store,
                                size: 50,
                                color: AppColors.muted,
                              )
                            : null,
                      ),
                      Positioned(
                        right: 2,
                        bottom: 2,
                        child: CircleAvatar(
                          backgroundColor: cs.primary.withOpacity(0.8),
                          child: IconButton(
                            icon: Icon(Icons.edit, color: cs.onPrimary),
                            onPressed: () => _pickImage(
                              isLogo: true,
                              businessId: widget.businessId,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // ===== Form =====
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        AppTextField(
                          controller: _nameCtrl,
                          label: tr.editBusinessBusinessName,
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                        AppTextField(
                          controller: _emailCtrl,
                          label: tr.email,
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                        IntlPhoneField(
                          initialCountryCode: _initialIso,
                          decoration: InputDecoration(
                            labelText: tr.editBusinessPhoneNumber,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          initialValue: b.phoneNumber,
                          onChanged: (p) {
                            _phoneE164 = p.completeNumber;
                            _initialIso = p.countryISOCode;
                          },
                          pickerDialogStyle: PickerDialogStyle(
                            searchFieldInputDecoration: InputDecoration(
                              prefixIcon: const Icon(Icons.search),
                              hintText: tr.searchPlaceholder,
                            ),
                          ),
                        ),
                        AppTextField(
                          controller: _websiteCtrl,
                          label: tr.editBusinessWebsite,
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                        AppTextField(
                          controller: _descCtrl,
                          label: tr.editBusinessDescription,
                          maxLines: 3,
                          margin: const EdgeInsets.only(bottom: 16),
                        ),
                        AppPasswordField(
                          controller: _passwordCtrl,
                          label: tr.editBusinessNewPassword,
                          margin: const EdgeInsets.only(bottom: 24),
                        ),
                      ],
                    ),
                  ),

                  // ===== Buttons =====
                  AppButton(
                    label: tr.editBusinessSaveChanges,
                    expand: true,
                    onPressed: _save,
                  ),
                  const SizedBox(height: 12),
                  AppButton(
                    label: tr.deleteAccount,
                    type: AppButtonType.outline,
                    expand: true,
                    onPressed: _confirmDelete,
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
