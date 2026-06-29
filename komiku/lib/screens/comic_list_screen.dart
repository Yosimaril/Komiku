import 'package:flutter/material.dart';

import '../models/comic.dart';
import '../services/komiku_api_service.dart';
import 'read_comic_layout_screen.dart';

class ComicListScreen extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const ComicListScreen({super.key, required this.categoryId, required this.categoryName});

  @override
  State<ComicListScreen> createState() => _ComicListScreenState();
}

class _ComicListScreenState extends State<ComicListScreen> {
  final KomikuApiService _api = const KomikuApiService();

  late Future<List<Comic>> _futureComics;

  @override
  void initState() {
    super.initState();
    _futureComics = _api.getComicsByCategory(widget.categoryId);
  }

  Widget _ratingStars(double ratingAvg) {
    final full = ratingAvg.floor().clamp(0, 5);
    return Text('★★★★★'.substring(0, full).padRight(5, '☆'),
        style: const TextStyle(color: Colors.amber, fontSize: 12));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName),
      ),
      body: FutureBuilder<List<Comic>>(
        future: _futureComics,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Failed to load comics: ${snapshot.error}'));
          }

          final comics = snapshot.data ?? const [];
          if (comics.isEmpty) {
            return const Center(child: Text('No comics found'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: comics.length,
            itemBuilder: (context, index) {
              final comic = comics[index];
              return InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => ReadComicLayoutScreen(comicId: comic.id),
                    ),
                  );
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: 3,
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 90,
                            height: 120,
                            child: comic.posterUrl != null && comic.posterUrl!.isNotEmpty
                                ? Image.network(
                                    comic.posterUrl!,
                                    fit: BoxFit.cover,
                                  )
                                : Container(color: Colors.grey.shade200),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                comic.title,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 6),
                              _ratingStars(comic.ratingAvg),
                              const SizedBox(height: 6),
                              Text(
                                comic.description ?? '',
                                style: TextStyle(color: Colors.grey.shade700, fontSize: 13),
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

