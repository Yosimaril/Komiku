import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komiku/models/category.dart';
import 'package:komiku/models/comic.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_message.dart';
import 'package:komiku/static/success_message.dart';

class CreateComicScreen extends StatefulWidget {
  const CreateComicScreen({super.key});

  @override
  State<CreateComicScreen> createState() => _CreateComicScreenState();
}

class _CreateComicScreenState extends State<CreateComicScreen> {
  final _formKey = GlobalKey<FormState>();

  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  File? _posterImage;
  final List<Category> _allCategories = [];
  final Set<int> _selectedCategoryIds = {};

  bool _isLoadingCategories = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  Future<void> _loadCategories() async {
    try {
      final response = await ApiService.getCategories();
      if (response['status'] == 'SUCCESS') {
        final List data = response['data'];
        setState(() {
          _allCategories.addAll(data.map((e) => Category.fromJson(e)));
          _isLoadingCategories = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading categories: $e");
      setState(() {
        _isLoadingCategories = false;
      });
    }
  }

  Future<void> _pickPosterImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 600,
      maxHeight: 800,
    );

    if (pickedFile != null) {
      setState(() {
        _posterImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isSubmitting = true;
    });

    try {
      final comic = Comic(
        title: _titleController.text,
        description: _descriptionController.text,
        categories: _allCategories
            .where((c) => _selectedCategoryIds.contains(c.id))
            .toList(),
      );

      final response = await ApiService.insertComic(
        comic,
        poster: _posterImage,
      );

      if (response['status'] == 'SUCCESS') {
        if (mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text(SuccessMessage.addComic)),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                response['error_message']?.toString() ?? "Failed to create comic",
              ),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint("Error creating comic: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ErrorMessage.networkError)),
        );
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
      appBar: AppBar(
        title: const Text("Create Comic"),
      ),
      body: _isLoadingCategories
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
                      decoration: const InputDecoration(
                        labelText: "Title",
                        border: OutlineInputBorder(),
                      ),
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
                      decoration: const InputDecoration(
                        labelText: "Description (Optional)",
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Poster Image (Optional)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
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
                        child: _posterImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.file(
                                  _posterImage!,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              )
                            : const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_a_photo, size: 48),
                                  SizedBox(height: 8),
                                  Text("Tap to select poster"),
                                ],
                              ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      "Categories (Optional)",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: _allCategories.map((category) {
                        final isSelected =
                            _selectedCategoryIds.contains(category.id);
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
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text("Create Comic"),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
