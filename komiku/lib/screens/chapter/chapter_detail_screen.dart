import 'package:flutter/material.dart';
import 'package:komiku/models/chapter_page.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_message.dart';

class ChapterDetailScreen extends StatefulWidget {
  final int chapterId;

  const ChapterDetailScreen({super.key, required this.chapterId});

  @override
  State<ChapterDetailScreen> createState() => _ChapterDetailScreenState();
}

class _ChapterDetailScreenState extends State<ChapterDetailScreen> {
  late Future<List<ChapterPage>> _futurePages;

  @override
  void initState() {
    super.initState();
    _futurePages = _loadPages(widget.chapterId);
  }

  Future<List<ChapterPage>> _loadPages(int id) async {
    final response = await ApiService.getComicChapterPages(id);

    return (response['data'] as List)
        .map((e) => ChapterPage.fromJson(e))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ChapterPage>>(
      future: _futurePages,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            appBar: AppBar(title: const Text("Loading...")),
            body: const Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text("Chapter")),
            body: Center(
              child: Text(
                '${ErrorMessage.loadChapterPageError}: ${snapshot.error}',
              ),
            ),
          );
        }

        final pages = snapshot.data;
        if (pages == null || pages.isEmpty) {
          return Scaffold(
            appBar: AppBar(title: const Text("Chapter")),
            body: const Center(child: Text(ErrorMessage.loadChapterPageEmpty)),
          );
        }

        return Scaffold(
          appBar: AppBar(title: Text(pages.first.chapterTitle ?? "Chapter")),
          body: ListView.builder(
            itemCount: pages.length,
            itemBuilder: (context, index) {
              final page = pages[index];
              final fullImageUrl = page.image;

              return Image.network(
                fullImageUrl,
                width: double.infinity,
                fit: BoxFit.fitWidth,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return SizedBox(
                    height: 300,
                    child: Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    ),
                  );
                },
                errorBuilder: (_, _, _) {
                  return const SizedBox(
                    height: 400,
                    child: Icon(Icons.broken_image, size: 160),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }
}
