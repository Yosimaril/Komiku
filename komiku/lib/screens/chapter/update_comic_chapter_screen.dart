import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komiku/models/chapter.dart';
import 'package:komiku/models/chapter_page.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_message.dart';

class UpdateComicChapterScreen extends StatefulWidget {
  final int chapterId;

  const UpdateComicChapterScreen({super.key, required this.chapterId});

  @override
  State<UpdateComicChapterScreen> createState() =>
      _UpdateComicChapterScreenState();
}

class _UpdateComicChapterScreenState extends State<UpdateComicChapterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _numberController = TextEditingController();

  List<ChapterPage> _existingPages = [];
  List<File> _newPages = [];
  List<Uint8List> _newPagesBytesWeb = []; // For web preview
  bool _isLoading = true;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadChapterDetail();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _numberController.dispose();
    super.dispose();
  }

  Future<void> _loadChapterDetail() async {
    try {
      // Load chapter pages (includes chapter info from API)
      final response =
          await ApiService.getComicChapterPages(widget.chapterId);
      if (response['status'] == 'SUCCESS') {
        final data = response['data'];
        setState(() {
          if (data is List && data.isNotEmpty) {
            // API returns list of pages
            _titleController.text =
                data.first['chapter_title'] ?? 'Chapter';
            _numberController.text =
                (data.first['chapter_number'] ?? '').toString();
            _existingPages =
                data.map((e) => ChapterPage.fromJson(e)).toList();
          } else if (data is Map) {
            // API returns single object with pages inside
            _titleController.text = data['title'] ?? 'Chapter';
            _numberController.text =
                (data['chapter_number'] ?? '').toString();
            if (data['pages'] != null) {
              _existingPages = (data['pages'] as List)
                  .map((e) => ChapterPage.fromJson(e))
                  .toList();
            }
          }
          _isLoading = false;
        });
      } else {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    } catch (e) {
      debugPrint("Error loading chapter: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickNewPages() async {
    final picker = ImagePicker();
    final files = await picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1000,
    );
    if (files.isNotEmpty) {
      if (kIsWeb) {
        // Week 3 - Image Widget: web pakai bytes untuk preview
        for (final f in files) {
          final bytes = await f.readAsBytes();
          setState(() {
            _newPages.add(File(f.path));
            _newPagesBytesWeb.add(bytes);
          });
        }
      } else {
        setState(() {
          _newPages.addAll(files.map((f) => File(f.path)));
        });
      }
    }
  }

  Future<void> _deleteExistingPage(int pageId, int index) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Page?'),
        content: const Text('Are you sure you want to delete this page?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child:
                const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await ApiService.deleteComicChapterPage(pageId);
        if (response['status'] == 'SUCCESS') {
          setState(() {
            _existingPages.removeAt(index);
          });
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Page deleted successfully')),
            );
          }
        }
      } catch (e) {
        debugPrint("Error deleting page: $e");
      }
    }
  }

  void _removeNewPage(int index) {
    setState(() {
      _newPages.removeAt(index);
      if (kIsWeb && index < _newPagesBytesWeb.length) {
        _newPagesBytesWeb.removeAt(index);
      }
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true);

    try {
      // 1. Update chapter title & number (Week 10 - Form submission)
      final chapterResponse = await ApiService.updateComicChapter(Chapter(
        id: widget.chapterId,
        chapterNumber: int.parse(_numberController.text),
        title: _titleController.text,
      ));

      if (chapterResponse['status'] != 'SUCCESS') {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                chapterResponse['error_message']?.toString() ??
                    'Failed to update chapter',
              ),
            ),
          );
        }
        return;
      }


      if (kIsWeb ? _newPagesBytesWeb.isNotEmpty : _newPages.isNotEmpty) {
        final pagesResponse = await ApiService.insertComicChapterPages(
          widget.chapterId,
          _newPages,
          pagesBytesWeb: kIsWeb ? _newPagesBytesWeb : null,
          pageNumberOffset: _existingPages.length,
        );



        if (pagesResponse['status'] != 'SUCCESS') {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                  content: Text('Chapter updated but some pages failed')),
            );
          }
          return;
        }
      }

      if (mounted) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Chapter updated successfully')),
        );
      }
    } catch (e) {
      debugPrint("Error updating chapter: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text(ErrorMessage.networkError)),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Chapter'),
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
                    // Chapter Number & Title (Week 4 - TextField)
                    Row(
                      children: [
                        SizedBox(
                          width: 80,
                          child: TextFormField(
                            controller: _numberController,
                            decoration: const InputDecoration(
                              labelText: 'No.',
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Required';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Must be a number';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _titleController,
                            decoration: const InputDecoration(
                              labelText: 'Chapter Title',
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Title is required';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Existing Pages Section
                    Text(
                      'Existing Pages (${_existingPages.length})',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    const SizedBox(height: 8),
                    if (_existingPages.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No existing pages',
                            style: TextStyle(color: Colors.grey)),
                      )
                    else
                      ..._existingPages.asMap().entries.map((entry) {
                        final index = entry.key;
                        final page = entry.value;
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: Image.network(
                              ApiService.getImageUrl(page.image),
                              width: 50,
                              height: 70,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) => Container(
                                width: 50,
                                height: 70,
                                color: Colors.grey.shade200,
                                child: const Icon(Icons.broken_image),
                              ),
                            ),
                            title: Text('Page ${page.pageNumber}'),
                            subtitle: Text(page.id != null
                                ? 'ID: ${page.id}'
                                : ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete,
                                  color: Colors.red),
                              onPressed: () {
                                if (page.id != null) {
                                  _deleteExistingPage(page.id!, index);
                                }
                              },
                            ),
                          ),
                        );
                      }),

                    const SizedBox(height: 24),

                    // Add New Pages
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Add New Pages',
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 16),
                        ),
                        TextButton.icon(
                          onPressed: _pickNewPages,
                          icon: const Icon(Icons.add_a_photo),
                          label: const Text('Pick Images'),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // New Pages Preview
                    if (_newPages.isEmpty)
                      const Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No new pages selected',
                            style: TextStyle(color: Colors.grey)),
                      )
                    else
                      SizedBox(
                        height: 120,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _newPages.length,
                          itemBuilder: (context, index) {
                            return Stack(
                              children: [
                                Container(
                                  width: 100,
                                  margin:
                                      const EdgeInsets.only(right: 8),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(8),
                                    image: DecorationImage(
                                      image: kIsWeb &&
                                              index <
                                                  _newPagesBytesWeb
                                                      .length
                                          ? MemoryImage(
                                              _newPagesBytesWeb[
                                                  index])
                                          : FileImage(
                                                  _newPages[index])
                                              as ImageProvider,
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                                Positioned(
                                  right: 4,
                                  top: 0,
                                  child: GestureDetector(
                                    onTap: () =>
                                        _removeNewPage(index),
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
                                      child: const Icon(Icons.close,
                                          size: 14,
                                          color: Colors.white),
                                    ),
                                  ),
                                ),
                                Positioned(
                                  left: 4,
                                  bottom: 4,
                                  child: Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 4,
                                            vertical: 2),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius:
                                          BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      '${_existingPages.length + index + 1}',
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      ),

                    const SizedBox(height: 32),

                    // Submit Button
                    ElevatedButton(
                      onPressed: _isSubmitting ? null : _submit,
                      style: ElevatedButton.styleFrom(
                        padding:
                            const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSubmitting
                          ? const CircularProgressIndicator()
                          : const Text('Update Chapter'),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}