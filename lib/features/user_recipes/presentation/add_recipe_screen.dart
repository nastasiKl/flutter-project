import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/l10n/app_localizations.dart';
import '../../auth/presentation/auth_controller.dart';
import '../data/user_data_repository.dart';
import '../domain/user_recipe.dart';

class AddRecipeScreen extends ConsumerStatefulWidget {
  const AddRecipeScreen({super.key});

  @override
  ConsumerState<AddRecipeScreen> createState() => _AddRecipeScreenState();
}

class _AddRecipeScreenState extends ConsumerState<AddRecipeScreen> {
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _ingredients = TextEditingController();
  final _steps = TextEditingController();
  final _servings = TextEditingController(text: '2');
  final _notes = TextEditingController();
  final _picker = ImagePicker();

  String _category = 'Vegetarian';
  XFile? _photo;
  Uint8List? _photoBytes;
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _ingredients.dispose();
    _steps.dispose();
    _servings.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final user = ref.watch(authStateProvider).asData?.value;

    if (user == null) {
      return Center(child: Text(l10n.t('protectedInfo')));
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_photoBytes != null)
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.memory(
                  _photoBytes!,
                  height: 220,
                  fit: BoxFit.cover,
                ),
              )
            else
              Container(
                height: 160,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                ),
                child: const Icon(Icons.add_photo_alternate_outlined, size: 48),
              ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.gallery),
                    icon: const Icon(Icons.photo_library_outlined),
                    label: Text(l10n.t('pickGallery')),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => _pick(ImageSource.camera),
                    icon: const Icon(Icons.photo_camera_outlined),
                    label: Text(l10n.t('pickCamera')),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _title,
              decoration: InputDecoration(labelText: l10n.t('title')),
              validator: (value) => _required(value, l10n),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _category,
              decoration: InputDecoration(labelText: l10n.t('category')),
              items:
                  const [
                    'Vegetarian',
                    'Beef',
                    'Chicken',
                    'Dessert',
                    'Seafood',
                  ].map((category) {
                    return DropdownMenuItem(
                      value: category,
                      child: Text(category),
                    );
                  }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _category = value);
                }
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _servings,
              decoration: InputDecoration(labelText: l10n.t('servings')),
              keyboardType: TextInputType.number,
              validator: (value) {
                final parsed = int.tryParse(value ?? '');
                if (parsed == null || parsed <= 0) {
                  return l10n.t('positiveNumber');
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _ingredients,
              minLines: 3,
              maxLines: 5,
              decoration: InputDecoration(labelText: l10n.t('ingredients')),
              validator: (value) => _required(value, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _steps,
              minLines: 4,
              maxLines: 8,
              decoration: InputDecoration(labelText: l10n.t('steps')),
              validator: (value) => _required(value, l10n),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _notes,
              minLines: 2,
              maxLines: 4,
              decoration: InputDecoration(labelText: l10n.t('notes')),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _saving ? null : () => _save(user.id),
              icon: _saving
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined),
              label: Text(l10n.t('saveRecipe')),
            ),
          ],
        ),
      ),
    );
  }

  String? _required(String? value, AppLocalizations l10n) {
    if ((value ?? '').trim().isEmpty) {
      return l10n.t('requiredField');
    }
    return null;
  }

  Future<void> _pick(ImageSource source) async {
    final file = await _picker.pickImage(
      source: source,
      imageQuality: 82,
      maxWidth: 1600,
    );
    if (file == null) {
      return;
    }
    final bytes = await file.readAsBytes();
    setState(() {
      _photo = file;
      _photoBytes = bytes;
    });
  }

  Future<void> _save(String userId) async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    final l10n = AppLocalizations.of(context);
    setState(() => _saving = true);
    try {
      await ref
          .read(userDataRepositoryProvider)
          .addRecipe(
            userId,
            UserRecipeDraft(
              title: _title.text.trim(),
              category: _category,
              ingredients: _ingredients.text.trim(),
              steps: _steps.text.trim(),
              servings: int.parse(_servings.text),
              notes: _notes.text.trim(),
            ),
            _photo,
          );
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.t('saved'))));
      _formKey.currentState?.reset();
      setState(() {
        _photo = null;
        _photoBytes = null;
        _category = 'Vegetarian';
        _servings.text = '2';
      });
    } on Object catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('${l10n.t('error')}: $error')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }
}
