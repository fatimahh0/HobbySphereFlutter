// lib/features/activities/Business/presentation/create/create_business_activity_screen.dart
import 'package:flutter/material.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/state/create_business_activity_controller.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/widgets/image_picker_row.dart';
import 'package:hobby_sphere/features/activities/Business/createActivity/presentation/widgets/map_picker.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

class CreateBusinessActivityScreen extends StatefulWidget {
  final int businessId;
  final String token;
  const CreateBusinessActivityScreen({
    super.key,
    required this.businessId,
    required this.token,
  });

  @override
  State<CreateBusinessActivityScreen> createState() =>
      _CreateBusinessActivityScreenState();
}

class _CreateBusinessActivityScreenState
    extends State<CreateBusinessActivityScreen> {
  final _form = GlobalKey<FormState>();
  final _priceCtl = TextEditingController();
  final _maxCtl = TextEditingController(text: '1');

  @override
  void initState() {
    super.initState();
    final c = context.read<CreateBusinessActivityController>();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      c.loadTypes(widget.token);
    });
  }

  @override
  void dispose() {
    _priceCtl.dispose();
    _maxCtl.dispose();
    super.dispose();
  }

  Future<void> _pickDateTime({
    required bool isStart,
    required CreateBusinessActivityController c,
  }) async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: now,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(now.add(const Duration(hours: 1))),
    );
    if (time == null) return;

    final dt = DateTime(
      date.year,
      date.month,
      date.day,
      time.hour,
      time.minute,
    );

    if (isStart) {
      c.startAt = dt;
      if (c.endAt != null && !c.endAt!.isAfter(c.startAt!)) {
        c.endAt = c.startAt!.add(const Duration(hours: 1));
      }
    } else {
      c.endAt = dt;
    }
    // If you actually display these values immediately, do a gentle rebuild:
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (c.hasListeners) c.notifyListeners();
    });
  }

  @override
  Widget build(BuildContext context) {
    final c = context.watch<CreateBusinessActivityController>();
    final df = DateFormat('yyyy-MM-dd  HH:mm');

    return Scaffold(
      appBar: AppBar(title: const Text('Create Activity')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Title
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => c.title = v,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Type dropdown
                c.loadingTypes
                    ? const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 12),
                          child: CircularProgressIndicator(),
                        ),
                      )
                    : DropdownButtonFormField<int>(
                        value: c.typeId,
                        items: c.activityTypes.map<DropdownMenuItem<int>>((t) {
                          if (t is Map) {
                            final id = (t['id'] as num).toInt();
                            final name = (t['name'] ?? 'Type $id').toString();
                            return DropdownMenuItem<int>(
                              value: id,
                              child: Text(name),
                            );
                          }
                          final idx = c.activityTypes.indexOf(t) + 1;
                          return DropdownMenuItem<int>(
                            value: idx,
                            child: Text(t.toString()),
                          );
                        }).toList(),
                        onChanged: (v) => c.typeId = v,
                        decoration: const InputDecoration(
                          labelText: 'Type',
                          border: OutlineInputBorder(),
                        ),
                        validator: (v) => v == null ? 'Select a type' : null,
                      ),
                const SizedBox(height: 12),

                // Description
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Description',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 3,
                  onChanged: (v) => c.description = v,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // Location (text)
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Location (text)',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (v) => c.location = v,
                  validator: (v) =>
                      (v == null || v.trim().isEmpty) ? 'Required' : null,
                ),
                const SizedBox(height: 12),

                // ✅ Bounded Map + quiet semantics
                MapPicker(
                  height: 240, // keep bounded
                  initialLat: c.latitude,
                  initialLng: c.longitude,
                  onLocationPicked: (lat, lng) {
                    c.latitude = lat;
                    c.longitude = lng;
                    // ❌ DO NOT notify here → prevents the semantics assert flood
                    // If you display lat/lng live, use addPostFrameCallback to notify.
                  },
                ),
                const SizedBox(height: 16),

                // Image picker
                ImagePickerRow(
                  initialPath: c.imagePath,
                  onChanged: (p) => c.imagePath = p,
                ),
                const SizedBox(height: 16),

                // Max participants & price
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _maxCtl,
                        decoration: const InputDecoration(
                          labelText: 'Max participants',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                        onChanged: (v) =>
                            c.maxParticipants = int.tryParse(v) ?? 1,
                        validator: (v) {
                          final n = int.tryParse(v ?? '');
                          if (n == null || n <= 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _priceCtl,
                        decoration: const InputDecoration(
                          labelText: 'Price',
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        onChanged: (v) => c.price = double.tryParse(v) ?? 0,
                        validator: (v) {
                          final n = double.tryParse(v ?? '');
                          if (n == null || n < 0) return 'Invalid';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Status
                DropdownButtonFormField<String>(
                  value: c.status,
                  decoration: const InputDecoration(
                    labelText: 'Status',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'ACTIVE', child: Text('ACTIVE')),
                    DropdownMenuItem(value: 'DRAFT', child: Text('DRAFT')),
                  ],
                  onChanged: (v) => c.status = v ?? 'ACTIVE',
                ),
                const SizedBox(height: 12),

                // Start / End pickers
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.play_arrow),
                        label: Text(
                          c.startAt == null
                              ? 'Pick start'
                              : 'Start: ${df.format(c.startAt!)}',
                        ),
                        onPressed: () => _pickDateTime(isStart: true, c: c),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        icon: const Icon(Icons.stop),
                        label: Text(
                          c.endAt == null
                              ? 'Pick end'
                              : 'End: ${df.format(c.endAt!)}',
                        ),
                        onPressed: () => _pickDateTime(isStart: false, c: c),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Submit
                ElevatedButton(
                  onPressed: c.loading
                      ? null
                      : () async {
                          if (!_form.currentState!.validate()) return;
                          await c.submit(
                            businessId: widget.businessId,
                            token: widget.token,
                          );
                          if (c.error != null) {
                            ScaffoldMessenger.of(
                              context,
                            ).showSnackBar(SnackBar(content: Text(c.error!)));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Created!')),
                            );
                            if (mounted) Navigator.of(context).pop(true);
                          }
                        },
                  child: Text(c.loading ? 'Creating…' : 'Create'),
                ),

                if (c.error != null) ...[
                  const SizedBox(height: 8),
                  Text(c.error!, style: const TextStyle(color: Colors.red)),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
