import 'package:flutter/material.dart';
import 'package:komiku/components/list_comic_screen/rating_star.dart';
import 'package:komiku/models/comic.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_message.dart';

class ComicDetailScreen extends StatefulWidget {
  final int comicId;

  const ComicDetailScreen({super.key, required this.comicId});

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  late Future<Comic> _futureComic;

  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureComic = getComicDetail(widget.comicId);
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<Comic> getComicDetail(int id) async {
    final response = await ApiService.getComicDetail(id);
    return Comic.fromJson(response['data']);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Comic>(
      future: _futureComic,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('${ErrorMessage.loadComicDetailError}: ${snapshot.error}'));
        }

        final comic = snapshot.data;
        if (comic == null) {
          return const Center(child: Text(ErrorMessage.loadComicDetailEmpty));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(comic.title),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (comic.poster != null && comic.poster!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        comic.poster!,
                        height: 220,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          height: 220,
                          color: Colors.grey.shade300,
                          child: const Icon(Icons.broken_image, size: 48),
                        ),
                      ),
                    ),
                  ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        comic.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),

                      RatingStar(
                        ratingAverage: comic.averageRating ?? 0,
                      ),

                      const SizedBox(height: 8),

                      Text(
                        comic.description ?? '-',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                        ),
                      ),
                    ],
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    'Chapters',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comic.chapters.length,
                    itemBuilder: (context, index) {
                      final chapter = comic.chapters[index];

                      return ListTile(
                        title: Text(
                          'Chapter ${chapter.chapterNumber}: ${chapter.title}',
                        ),
                        trailing: const Icon(Icons.chevron_right),
                        onTap: () {
                          // TODO: Navigate to reader screen
                        },
                      );
                    },
                  ),
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Text(
                    'Comments',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

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
                          // TODO: Insert comment

                          _commentController.clear();
                        },
                        child: const Text('Submit'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: comic.comments.length,
                    itemBuilder: (context, index) {
                      final comment = comic.comments[index];

                      return Card(
                        margin: const EdgeInsets.only(bottom: 10),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comment.username ?? 'Unknown',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),

                              const SizedBox(height: 4),

                              Text(comment.content),

                              const SizedBox(height: 8),

                              TextButton(
                                onPressed: () {
                                  // TODO: Reply comment
                                },
                                child: const Text('Reply'),
                              ),
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
      },
    );
  }
}