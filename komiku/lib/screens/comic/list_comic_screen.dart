import 'package:flutter/material.dart';
import 'package:komiku/components/list_comic_screen/rating_star.dart';
import 'package:komiku/components/list_comic_screen/search_field.dart';
import 'package:komiku/models/comic.dart';
import 'package:komiku/screens/comic/comic_detail_screen.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_message.dart';

class ListComicScreen extends StatefulWidget {
  const ListComicScreen({super.key});

  @override
  State<ListComicScreen> createState() => _ListComicScreenState();
}

class _ListComicScreenState extends State<ListComicScreen> {
  late Future<List<Comic>> _futureComics;

  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futureComics = getComics(null);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<List<Comic>> getComics(String? keyword) async {
    final response = await ApiService.getComics(keyword: keyword);
    return response['data'].map<Comic>((c) => Comic.fromJson(c)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Comics')),
      body: Column(
        children: [
          SearchField(
            controller: _searchController,
            onEmpty: () {
              setState(() {
                _futureComics = getComics(null);
              });
            },
            onSearch: (value) {
              setState(() {
                _futureComics = getComics(value);
              });
            },
          ),
          Expanded(child: ListComicWidget(futureComics: _futureComics)),
        ],
      ),
    );
  }
}

class ListComicWidget extends StatelessWidget {
  const ListComicWidget({super.key, required Future<List<Comic>> futureComics})
    : _futureComics = futureComics;

  final Future<List<Comic>> _futureComics;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Comic>>(
      future: _futureComics,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${ErrorMessage.loadComicError}: ${snapshot.error}'),
          );
        }

        final comics = snapshot.data ?? const [];
        if (comics.isEmpty) {
          return const Center(child: Text(ErrorMessage.loadComicEmpty));
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
                  MaterialPageRoute(builder: (_) => ComicDetailScreen()),
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
                          child:
                              comic.poster != null && comic.poster!.isNotEmpty
                              ? Image.network(
                                  comic.poster!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey.shade200,
                                      child: const Icon(
                                        Icons.broken_image,
                                        color: Colors.grey,
                                      ),
                                    );
                                  },
                                  loadingBuilder:
                                      (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        }
                                        return Container(
                                          color: Colors.grey.shade100,
                                          child: const Center(
                                            child: CircularProgressIndicator(
                                              strokeWidth: 2,
                                            ),
                                          ),
                                        );
                                      },
                                )
                              : Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.image,
                                    color: Colors.grey,
                                  ),
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
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 6),
                            RatingStar(ratingAverage: comic.averageRating ?? 0),
                            const SizedBox(height: 6),
                            Text(
                              comic.description ?? '',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
