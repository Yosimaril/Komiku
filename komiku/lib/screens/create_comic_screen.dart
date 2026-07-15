import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../models/category.dart';
import '../services/api_service.dart';

class CreateComicScreen extends StatefulWidget {
  const CreateComicScreen({super.key});

  @override
  State<CreateComicScreen> createState() => _CreateComicScreenState();
}

class _CreateComicScreenState extends State<CreateComicScreen> {
  final KomikuApiService _api = const KomikuApiService();
  final _formKey = GlobalKey<FormState>();

  // Text controllers
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _posterUrlController = TextEditingController();

  // Form data
  int? _selectedCategoryId;
  List<Category> _categories = const [];
  File? _posterImage;
  final List<ChapterData> _chapters = [];

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadCategories();
  }

  Future<void> _loadCategories() async {
    // connect ke ubaya.cloud API for categories.
    // GET https://ubaya.cloud/flutter/[NRP]/categories.php
    try {
      final cats = await _api.getCategories();
      setState(() {
        _categories = cats;
      });
    } catch (_) {
      // Layout-only fallback
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

  void _addChapter() {
    setState(() {
      _chapters.add(ChapterData());
    });
  }

  void _removeChapter(int index) {
    setState(() {
      _chapters.removeAt(index);
    });
  }

  void _addPageToChapter(int chapterIndex) {
    setState(() {
      _chapters[chapterIndex].pages.add(PageData());
    });
  }

  void _removePageFromChapter(int chapterIndex, int pageIndex) {
    setState(() {
      _chapters[chapterIndex].pages.removeAt(pageIndex);
    });
  }

  Future<void> _submitComic() async {
    // Validate form fields
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the form errors before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate category
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a category'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate chapters
    if (_chapters.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one chapter'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Validate each chapter has a title
    for (int i = 0; i < _chapters.length; i++) {
      if (_chapters[i].title.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please enter a title for Chapter ${i + 1}'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
      // Validate each chapter has at least one page
      if (_chapters[i].pages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Chapter ${i + 1} must have at least one page'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Validate poster
    if (_posterImage == null && _posterUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please pick a poster image or enter a poster URL'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // connect ke ubaya.cloud API for create comic.
      // POST https://ubaya.cloud/flutter/[NRP]/create_comic.php
      // body: title, description, category_id, creator_id, poster_url
      // TODO: implement comic creation API call

      // After comic created, add chapters and pages
      // connect ke ubaya.cloud API for add chapter.
      // POST https://ubaya.cloud/flutter/[NRP]/add_chapter.php
      // body: comic_id, chapter_number, title

      // connect ke ubaya.cloud API for upload page image.
      // POST https://ubaya.cloud/flutter/[NRP]/upload_page.php
      // body: chapter_id, page_number, image (base64)

      await Future.delayed(const Duration(seconds: 1)); // Simulate API call

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Comic created successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Comic'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Form(
              key: _formKey,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Title
                    TextFormField(
                      controller: _titleController,
                      decoration: const InputDecoration(
                        labelText: 'Title',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter comic title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Description
                    TextFormField(
                      controller: _descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 5,
                      keyboardType: TextInputType.multiline,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter description';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Category Dropdown
                    DropdownButtonFormField<int>(
                      decoration: const InputDecoration(
                        labelText: 'Category',
                        border: OutlineInputBorder(),
                      ),
                      hint: const Text('Select Category'),
                      initialValue: _selectedCategoryId,
                      items: _categories.map((Category category) {
                        return DropdownMenuItem<int>(
                          value: category.id,
                          child: Text(category.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a category';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Poster Image
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Poster',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: _pickPosterImage,
                              icon: const Icon(Icons.image),
                              label: const Text('Pick Poster'),
                            ),
                            const SizedBox(width: 16),
                            if (_posterImage != null)
                              Container(
                                width: 100,
                                height: 140,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(8),
                                  image: DecorationImage(
                                    image: FileImage(_posterImage!),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Chapters Section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Chapters',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        ElevatedButton.icon(
                          onPressed: _addChapter,
                          icon: const Icon(Icons.add),
                          label: const Text('Add Chapter'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Chapter List
                    if (_chapters.isEmpty)
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            'No chapters yet. Click "Add Chapter" to start.',
                            style: TextStyle(color: Colors.grey),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _chapters.length,
                        itemBuilder: (context, chapterIndex) {
                          final chapter = _chapters[chapterIndex];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Chapter ${chapterIndex + 1}',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      IconButton(
                                        onPressed: () => _removeChapter(chapterIndex),
                                        icon: const Icon(Icons.delete, color: Colors.red),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 12),

                    // Chapter Title
                                  TextFormField(
                                    decoration: const InputDecoration(
                                      labelText: 'Chapter Title',
                                      hintText: 'e.g. The Beginning',
                                      border: OutlineInputBorder(),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.trim().isEmpty) {
                                        return 'Chapter title is required';
                                      }
                                      return null;
                                    },
                                    onChanged: (value) {
                                      chapter.title = value;
                                    },
                                  ),
                                  const SizedBox(height: 12),

                                  // Pages Section
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      const Text(
                                        'Pages',
                                        style: TextStyle(fontWeight: FontWeight.bold),
                                      ),
                                      TextButton.icon(
                                        onPressed: () => _addPageToChapter(chapterIndex),
                                        icon: const Icon(Icons.add),
                                        label: const Text('Add Page'),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),

                                  // Pages List
                                  if (chapter.pages.isEmpty)
                                    const Padding(
                                      padding: EdgeInsets.symmetric(vertical: 16),
                                      child: Text(
                                        'No pages yet',
                                        style: TextStyle(color: Colors.grey),
                                        textAlign: TextAlign.center,
                                      ),
                                    )
                                  else
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: chapter.pages.length,
                                      itemBuilder: (context, pageIndex) {
                                        final page = chapter.pages[pageIndex];
                                        return ListTile(
                                          leading: page.image != null
                                              ? Image.file(
                                                  page.image!,
                                                  width: 50,
                                                  height: 70,
                                                  fit: BoxFit.cover,
                                                )
                                              : Container(
                                                  width: 50,
                                                  height: 70,
                                                  color: Colors.grey.shade200,
                                                  child: const Icon(Icons.image),
                                                ),
                                          title: Text('Page ${pageIndex + 1}'),
                                          trailing: IconButton(
                                            onPressed: () =>
                                                _removePageFromChapter(chapterIndex, pageIndex),
                                            icon: const Icon(Icons.delete, color: Colors.red),
                                          ),
                                        );
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    const SizedBox(height: 24),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _submitComic,
                      style: ButtonStyle(
                        padding: WidgetStateProperty.all(
                          const EdgeInsets.symmetric(vertical: 16),
                        ),
                      ),
                      child: const Text(
                        'Create Comic',
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _posterUrlController.dispose();
    super.dispose();
  }
}

// Helper class for chapter data
class ChapterData {
  String title = '';
  final List<PageData> pages = [];
}

// Helper class for page data
class PageData {
  File? image;
  int? pageNumber;
}