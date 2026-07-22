import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:komiku/models/category.dart';
import 'package:komiku/models/comic.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_messages.dart';
import 'package:komiku/static/success_message.dart';

class UpdateComicScreen extends StatefulWidget {
  final int comicId;

  const UpdateComicScreen({super.key, required this.comicId});

  @override
  State<UpdateComicScreen> createState() => _UpdateComicScreenState();
}

class _UpdateComicScreenState extends State<UpdateComicScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _posterImage;
  Uint8List? _posterBytesWeb;
  String? _posterFilenameWeb;
  String? _existingPosterUrl;

  final List<Category> _allCategories = [];
  final Set<int> _selectedCategoryIds = {};

  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    try {
      final comicResponse = await ApiService.getComicDetail(widget.comicId);
      final categoriesResponse = await ApiService.getCategories();

      if (comicResponse['status'] == 'SUCCESS' && categoriesResponse['status'] == 'SUCCESS') {
        final Comic comic = Comic.fromJson(comicResponse['data']);
        final List categoryData = categoriesResponse['data'];

        setState(() {
          _titleController.text = comic.title;
          _descriptionController.text = comic.description ?? '';
          _existingPosterUrl = comic.poster;

          _allCategories.addAll(categoryData.map((e) => Category.fromJson(e)));
          _selectedCategoryIds.addAll(comic.categories.where((e) => e.id != null).map((e) => e.id!));

          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ErrorMessage.loadComicDetailError)));
        Navigator.pop(context);
      }
    }
  }

  Future<void> _pickPosterImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, imageQuality: 80, maxWidth: 600, maxHeight: 800);

    if (pickedFile == null) return;

    setState(() {
      if (kIsWeb) {
        _posterBytesWeb = null; // will be set async below
        // We'll load bytes + filename in async block below.
      } else {
        _posterImage = File(pickedFile.path);
      }
    });

    if (kIsWeb) {
      final bytes = await pickedFile.readAsBytes();
      final path = pickedFile.path;
      final name = path.split('/').last;
      final lower = name.toLowerCase();
      final hasAllowedExt = lower.endsWith('.jpg') || lower.endsWith('.jpeg') || lower.endsWith('.png') || lower.endsWith('.webp');
      final filename = hasAllowedExt ? name : 'poster.jpg';

      setState(() {
        _posterBytesWeb = bytes;
        _posterFilenameWeb = filename;
        _posterImage = null; // ensure we don't use Image.file on web
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final comic = Comic(id: widget.comicId, title: _titleController.text, description: _descriptionController.text, categories: _allCategories.where((c) => _selectedCategoryIds.contains(c.id)).toList());

      final response = await ApiService.updateComic(comic, poster: kIsWeb ? null : _posterImage, posterBytes: kIsWeb ? _posterBytesWeb : null, posterFilename: kIsWeb ? _posterFilenameWeb : null);

      if (response['status'] == 'SUCCESS') {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(SuccessMessage.updateComic)));
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(response['error_messages']?.toString() ?? "Failed to update comic")));
        }
      }
    } catch (e) {
      debugPrint("Error updating comic: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text(ErrorMessage.networkError)));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Update Comic")),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return "Title is required";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(labelText: "Description (Optional)", border: OutlineInputBorder()),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    const Text("Poster Image (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: _pickPosterImage,
                      child: Container(
                        height: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey.shade200,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.grey.shade400),
                        ),
                        child: kIsWeb
                            ? (_posterBytesWeb != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.memory(_posterBytesWeb!, fit: BoxFit.cover, width: double.infinity),
                                    )
                                  : (_existingPosterUrl != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: Image.network(_existingPosterUrl!, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                                          )
                                        : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 48), SizedBox(height: 8), Text("Tap to change poster")])))
                            : _posterImage != null
                            ? kIsWeb
                                  ? const SizedBox.shrink()
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.file(_posterImage!, fit: BoxFit.cover, width: double.infinity),
                                    )
                            : _existingPosterUrl != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.network(_existingPosterUrl!, fit: BoxFit.cover, width: double.infinity, errorBuilder: (_, __, ___) => const Icon(Icons.broken_image)),
                              )
                            : const Column(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.add_a_photo, size: 48), SizedBox(height: 8), Text("Tap to change poster")]),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text("Categories (Optional)", style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _allCategories.map((category) {
                        final isSelected = _selectedCategoryIds.contains(category.id);
                        return FilterChip(
                          label: Text(category.name),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                _selectedCategoryIds.add(category.id!);
                              } else {
                                _selectedCategoryIds.remove(category.id);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                      child: _isSubmitting ? const CircularProgressIndicator() : const Text("Update Comic"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
