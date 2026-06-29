import 'package:flutter/material.dart';


import '../models/comic.dart';
import '../models/comment.dart';
import '../models/chapter.dart';
import '../services/komiku_api_service.dart';

class ReadComicLayoutScreen extends StatefulWidget {
  final int comicId;

  const ReadComicLayoutScreen({super.key, required this.comicId});

  @override
  State<ReadComicLayoutScreen> createState() => _ReadComicLayoutScreenState();
}

class _ReadComicLayoutScreenState extends State<ReadComicLayoutScreen> {
  final KomikuApiService _api = const KomikuApiService();

  Comic? _comic;
  List<Chapter> _chapters = const [];
  List<Comment> _comments = const [];

  final TextEditingController _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    // use api ambil comic read layout
    try {
      final data = await _api.getComicReadLayout(widget.comicId);
      setState(() {
        _comic = data.comic;
        _chapters = data.chapters;
        _comments = data.comments;
      });
    } catch (_) {
      // Layout-only fallback (no dummy data): leave fields null/empty.
      setState(() {});
    }
  }

  Widget _stars(double ratingAvg) {
    final full = ratingAvg.floor().clamp(0, 5);
    final text = '★★★★★'.substring(0, full).padRight(5, '☆');
    return Text(text, style: const TextStyle(color: Colors.amber, fontSize: 14));
  }

  @override
  Widget build(BuildContext context) {
    final posterUrl = _comic?.posterUrl;

    return Scaffold(
      appBar: AppBar(
        title: Text(_comic?.title ?? 'Read Comic'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Poster
            if (posterUrl != null && posterUrl.isNotEmpty)
              Padding(
                padding: const EdgeInsets.all(12),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    posterUrl,
                    height: 220,
                    fit: BoxFit.cover,
                  ),
                ),
              ),

            // Layout header info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _comic?.title ?? 'Title',
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _stars(_comic?.ratingAvg ?? 0),
                  const SizedBox(height: 8),
                  Text(
                    _comic?.description ?? 'Description',
                    style: TextStyle(color: Colors.grey.shade800),
                  ),
                ],
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text('Chapters', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // Chapter list (placeholder layout)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _chapters.length,
                itemBuilder: (context, index) {
                  final ch = _chapters[index];
                  return ListTile(
                    title: Text('Chapter ${ch.chapterNumber}: ${ch.title}'),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () {
                      // use api buat load chapter pages
                    },
                  );
                },
              ),
            ),

            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Text('Comments', style: TextStyle(fontWeight: FontWeight.bold)),
            ),

            // Comment input
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _commentController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Add Comment',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      // use api buat add comment
                      // TODO: call web service to post comment.
                      _commentController.clear();
                      setState(() {});
                    },
                    child: const Text('Submit'),
                  )
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Comment list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _comments.length,
                itemBuilder: (context, index) {
                  final cm = _comments[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(cm.content),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () {
                              // use api buat reply comment
                            },
                            child: const Text('[Reply]'),
                          )
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

