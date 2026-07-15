import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:komiku/models/chapter.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_message.dart';

class ChapterInput {
  final TextEditingController titleController = TextEditingController();
  final TextEditingController numberController = TextEditingController();
  List<File> pages = [];

  ChapterInput({int? nextNumber}) {
    if (nextNumber != null) {
      numberController.text = nextNumber.toString();
    }
  }

  void dispose() {
    titleController.dispose();
    numberController.dispose();
  }
}

class CreateComicChapterScreen extends StatefulWidget {
  const CreateComicChapterScreen({super.key});

  @override
  State<CreateComicChapterScreen> createState() => _CreateComicChapterScreenState();
}

class _CreateComicChapterScreenState extends State<CreateComicChapterScreen> {
  final List<ChapterInput> _chapters = [];
  bool _isSubmitting = false;
  late int _comicId;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _comicId = ModalRoute.of(context)!.settings.arguments as int;
    if (_chapters.isEmpty) {
      _addChapterField();
    }
  }

  @override
  void dispose() {
    for (var chapter in _chapters) {
      chapter.dispose();
    }
    super.dispose();
  }

  void _addChapterField() {
    setState(() {
      int nextNum = _chapters.isEmpty ? 1 : (int.tryParse(_chapters.last.numberController.text) ?? 0) + 1;
      _chapters.add(ChapterInput(nextNumber: nextNum));
    });
  }

  void _removeChapterField(int index) {
    if (_chapters.length <= 1) return;
    setState(() {
      _chapters[index].dispose();
      _chapters.removeAt(index);
    });
  }

  Future<void> _pickImages(int chapterIndex) async {
    final picker = ImagePicker();
    final pickedFiles = await picker.pickMultiImage(
      imageQuality: 80,
      maxWidth: 1000,
    );

    if (pickedFiles.isNotEmpty) {
      setState(() {
        _chapters[chapterIndex].pages.addAll(
              pickedFiles.map((e) => File(e.path)),
            );
      });
    }
  }

  void _removePage(int chapterIndex, int pageIndex) {
    setState(() {
      _chapters[chapterIndex].pages.removeAt(pageIndex);
    });
  }

  Future<void> _submit() async {
    // Validation
    for (var chapter in _chapters) {
      if (chapter.titleController.text.trim().isEmpty ||
          chapter.numberController.text.trim().isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Please fill all chapter titles and numbers")),
        );
        return;
      }
      if (chapter.pages.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Chapter ${chapter.numberController.text} has no pages")),
        );
        return;
      }
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      // 1. Insert Chapters
      final chaptersToInsert = _chapters.map((c) => Chapter(
        chapterNumber: int.parse(c.numberController.text),
        title: c.titleController.text,
      )).toList();

      final response = await ApiService.insertComicChapters(_comicId, chaptersToInsert);

      if (response['status'] == 'SUCCESS') {
        final List createdChapters = response['data']['chapters'];
        
        // 2. Insert Pages for each chapter
        bool allPagesSuccess = true;
        for (int i = 0; i < createdChapters.length; i++) {
          final chapterId = createdChapters[i]['id'];
          final imageFiles = _chapters[i].pages;
          
          final pagesResponse = await ApiService.insertComicChapterPages(chapterId, imageFiles);
          if (pagesResponse['status'] != 'SUCCESS') {
            allPagesSuccess = false;
            break;
          }
        }

        if (allPagesSuccess && mounted) {
          Navigator.pop(context, true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Chapters and pages uploaded successfully")),
          );
        } else if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Some pages failed to upload")),
          );
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error_message']?.toString() ?? "Failed to create chapters")),
        );
      }
    } catch (e) {
      debugPrint("Error: $e");
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
        title: const Text("Add Chapters"),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _chapters.length,
              itemBuilder: (context, index) {
                final chapter = _chapters[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Chapter ${index + 1}",
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                            ),
                            const Spacer(),
                            if (_chapters.length > 1)
                              IconButton(
                                icon: const Icon(Icons.remove_circle, color: Colors.red),
                                onPressed: () => _removeChapterField(index),
                              ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            SizedBox(
                              width: 80,
                              child: TextFormField(
                                controller: chapter.numberController,
                                decoration: const InputDecoration(labelText: "No.", border: OutlineInputBorder()),
                                keyboardType: TextInputType.number,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextFormField(
                                controller: chapter.titleController,
                                decoration: const InputDecoration(labelText: "Title", border: OutlineInputBorder()),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text("Pages", style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 120,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: chapter.pages.length + 1,
                            itemBuilder: (context, pIndex) {
                              if (pIndex == chapter.pages.length) {
                                return GestureDetector(
                                  onTap: () => _pickImages(index),
                                  child: Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.grey.shade200,
                                      borderRadius: BorderRadius.circular(8),
                                      border: Border.all(color: Colors.grey.shade400),
                                    ),
                                    child: const Icon(Icons.add_a_photo, color: Colors.grey),
                                  ),
                                );
                              }

                              return Stack(
                                children: [
                                  Container(
                                    width: 100,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        image: FileImage(chapter.pages[pIndex]),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    right: 4,
                                    top: 0,
                                    child: GestureDetector(
                                      onTap: () => _removePage(index, pIndex),
                                      child: Container(
                                        decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                                        padding: const EdgeInsets.all(4),
                                        child: const Icon(Icons.close, size: 14, color: Colors.white),
                                      ),
                                    ),
                                  ),
                                  Positioned(
                                    left: 4,
                                    bottom: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                      decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                      child: Text(
                                        "${pIndex + 1}",
                                        style: const TextStyle(color: Colors.white, fontSize: 10),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                OutlinedButton.icon(
                  onPressed: _addChapterField,
                  icon: const Icon(Icons.add),
                  label: const Text("Add Another Chapter"),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submit,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: _isSubmitting
                      ? const CircularProgressIndicator()
                      : const Text("Upload Chapters & Pages"),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
