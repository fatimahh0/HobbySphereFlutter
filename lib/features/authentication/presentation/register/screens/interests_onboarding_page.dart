import 'dart:async';
import 'package:flutter/material.dart';
import 'package:hobby_sphere/core/network/globals.dart' as g;

import 'package:hobby_sphere/features/authentication/data/services/registration_service.dart';
import 'package:hobby_sphere/features/authentication/data/repositories/registration_repository_impl.dart';
import 'package:hobby_sphere/features/authentication/data/repositories/interests_repository_impl.dart';

import 'package:hobby_sphere/features/authentication/domain/entities/activity_type.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/get_activity_types.dart';
import 'package:hobby_sphere/features/authentication/domain/usecases/register/add_user_interests.dart';

import 'package:hobby_sphere/features/authentication/presentation/register/widgets/interests_grid.dart';
import 'package:hobby_sphere/shared/widgets/top_toast.dart';
import 'package:hobby_sphere/shared/widgets/app_button.dart';

class InterestsOnboardingPage extends StatefulWidget {
  final int userId;
  const InterestsOnboardingPage({super.key, required this.userId});

  @override
  State<InterestsOnboardingPage> createState() => _InterestsOnboardingPageState();
}

class _InterestsOnboardingPageState extends State<InterestsOnboardingPage> {
  late final RegistrationService _svc;
  late final GetActivityTypes _getTypes;
  late final AddUserInterests _addInterests;

  bool _loading = true;
  String? _error;
  List<ActivityType> _options = [];
  final Set<int> _selected = {};
  bool _showAll = true;

  @override
  void initState() {
    super.initState();
    _svc = RegistrationService(g.appDio!);
    _getTypes = GetActivityTypes(InterestsRepositoryImpl(_svc));
    _addInterests = AddUserInterests(RegistrationRepositoryImpl(_svc));
    _load();
  }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final items = await _getTypes();
      setState(() { _options = items; _loading = false; });
    } catch (e) {
      setState(() { _error = 'Failed to load interests'; _loading = false; });
    }
  }

  Future<void> _submit() async {
    if (_selected.isEmpty) {
      showTopToast(context, 'Please pick at least one interest');
      return;
    }
    setState(() => _loading = true);
    try {
      await _addInterests(widget.userId, _selected.toList());
      if (!mounted) return;
      showTopToast(context, 'All set!', type: ToastType.success);
      Navigator.of(context).pop(); // back to Login -> then it will route to shell
    } catch (e) {
      setState(() => _loading = false);
      showTopToast(context, 'Could not save interests', type: ToastType.error);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Pick your interests')),
      body: Stack(
        children: [
          if (_loading)
            const Center(child: CircularProgressIndicator()),
          if (!_loading && _error != null)
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_error!),
                  const SizedBox(height: 12),
                  AppButton(onPressed: _load, label: 'Retry'),
                ],
              ),
            ),
          if (!_loading && _error == null)
            SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: InterestsGridRemote(
                items: _options,
                selected: _selected,
                showAll: _showAll,
                onToggleShow: () => setState(() => _showAll = !_showAll),
                onToggle: (id) => setState(() {
                  _selected.contains(id) ? _selected.remove(id) : _selected.add(id);
                }),
                onSubmit: _submit,
              ),
            ),
        ],
      ),
    );
  }
}
