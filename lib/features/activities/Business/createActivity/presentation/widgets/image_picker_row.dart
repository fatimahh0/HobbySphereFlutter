import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class ImagePickerRow extends StatefulWidget {
  final String? initialPath;
  final ValueChanged<String?> onChanged;

  const ImagePickerRow({super.key, this.initialPath, required this.onChanged});

  @override
  State<ImagePickerRow> createState() => _ImagePickerRowState();
}

class _ImagePickerRowState extends State<ImagePickerRow> {
  String? _path;
  final _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _path = widget.initialPath;
  }

  Future<void> _pickFromCamera() async {
    final img = await _picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() => _path = img.path);
      widget.onChanged(_path);
    }
  }

  Future<void> _pickFromGallery() async {
    final img = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (img != null) {
      setState(() => _path = img.path);
      widget.onChanged(_path);
    }
  }

  void _remove() {
    setState(() => _path = null);
    widget.onChanged(null);
  }

  @override
  Widget build(BuildContext context) {
    final preview = _path != null
        ? ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.file(
              File(_path!),
              width: 90,
              height: 90,
              fit: BoxFit.cover,
            ),
          )
        : Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(Icons.image, size: 30),
          );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        preview,
        const SizedBox(width: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            ElevatedButton.icon(
              onPressed: _pickFromCamera,
              icon: const Icon(Icons.photo_camera),
              label: const Text('Camera'),
            ),
            OutlinedButton.icon(
              onPressed: _pickFromGallery,
              icon: const Icon(Icons.photo_library),
              label: const Text('Gallery'),
            ),
            if (_path != null)
              TextButton.icon(
                onPressed: _remove,
                icon: const Icon(Icons.delete_outline),
                label: const Text('Remove'),
              ),
          ],
        ),
      ],
    );
  }
}
