import 'package:flutter/material.dart';

import '../models/comic.dart';
import '../services/api_service.dart';
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
    final hasHalf = (ratingAvg - full) >= 0.25;
    String stars = '';
    for (int i = 0; i < 5; i++) {
      if (i < full) {
        stars += '★';
      } else if (i == full && hasHalf) {
        stars += '½';
      } else {
        stars += '☆';
      }
    }
    return Row(
      children: [
        Text(stars, style: const TextStyle(color: Colors.amber, fontSize: 14)),
        const SizedBox(width: 4),
        Text(
          ratingAvg.toStringAsFixed(1),
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
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
                                    errorBuilder: (context, error, stackTrace) {
                                      return Container(
                                        color: Colors.grey.shade200,
                                        child: const Icon(Icons.broken_image, color: Colors.grey),
                                      );
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      if (loadingProgress == null) return child;
                                      return Container(
                                        color: Colors.grey.shade100,
                                        child: const Center(
                                          child: CircularProgressIndicator(strokeWidth: 2),
                                        ),
                                      );
                                    },
                                  )
                                : Container(
                                    color: Colors.grey.shade200,
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  ),
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

