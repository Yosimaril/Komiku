import 'dart:async';

import 'package:flutter/material.dart';

import '../models/comic.dart';
import '../services/api_service.dart';
import 'read_comic_layout_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final KomikuApiService _api = const KomikuApiService();
  final TextEditingController _searchController = TextEditingController();

  String _query = '';
  bool _isLoading = false;
  List<Comic> _results = const [];
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounceTimer?.cancel();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _query = value;
    });
    // Cancel previous debounce timer
    _debounceTimer?.cancel();
    // Start new timer: wait 500ms after user stops typing
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchComics();
    });
  }

  Future<void> searchComics() async {
    final q = _query.trim();
    if (q.isEmpty) {
      setState(() {
        _results = const [];
      });
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // use api buat search comics by title
      final res = await _api.searchComicsByTitle(q);
      setState(() {
        _results = res;
      });
    } catch (_) {
      setState(() {
        _results = const [];
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _ratingStars(double ratingAvg) {
    final full = ratingAvg.floor().clamp(0, 5);
    String stars = '';
    for (int i = 0; i < 5; i++) {
      if (i < full) {
        stars += '★';
      } else {
        stars += '☆';
      }
    }
    return Row(
      children: [
        Text(stars, style: const TextStyle(color: Colors.amber, fontSize: 12)),
        const SizedBox(width: 4),
        Text(
          ratingAvg.toStringAsFixed(1),
          style: TextStyle(color: Colors.grey.shade500, fontSize: 11),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Comic'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                border: const OutlineInputBorder(),
                labelText: 'Search comic by title...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
              onSubmitted: (_) {
                _debounceTimer?.cancel();
                searchComics();
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _query.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.search, size: 64, color: Colors.grey.shade300),
                              const SizedBox(height: 12),
                              Text(
                                'Start typing to search comics',
                                style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                              ),
                            ],
                          ),
                        )
                      : _results.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.search_off, size: 64, color: Colors.grey.shade300),
                                  const SizedBox(height: 12),
                                  Text(
                                    'No comics found for "$_query"',
                                    style: TextStyle(color: Colors.grey.shade500, fontSize: 16),
                                  ),
                                ],
                              ),
                            )
                          : ListView.builder(
                              itemCount: _results.length,
                              itemBuilder: (context, index) {
                                final comic = _results[index];
                                return Card(
                                  margin: const EdgeInsets.only(bottom: 8),
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(12),
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => ReadComicLayoutScreen(
                                            comicId: comic.id,
                                          ),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.all(10),
                                      child: Row(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(8),
                                            child: SizedBox(
                                              width: 60,
                                              height: 80,
                                              child: comic.posterUrl != null &&
                                                      comic.posterUrl!.isNotEmpty
                                                  ? Image.network(
                                                      comic.posterUrl!,
                                                      fit: BoxFit.cover,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return Container(
                                                          color: Colors.grey.shade200,
                                                          child: const Icon(Icons.broken_image,
                                                              size: 30, color: Colors.grey),
                                                        );
                                                      },
                                                      loadingBuilder:
                                                          (context, child, loadingProgress) {
                                                        if (loadingProgress == null) return child;
                                                        return Container(
                                                          color: Colors.grey.shade100,
                                                          child: const Center(
                                                            child: CircularProgressIndicator(
                                                                strokeWidth: 2),
                                                          ),
                                                        );
                                                      },
                                                    )
                                                  : Container(
                                                      color: Colors.grey.shade200,
                                                      child: const Icon(Icons.image,
                                                          size: 30, color: Colors.grey),
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
                                                    fontSize: 15,
                                                    fontWeight: FontWeight.bold,
                                                  ),
                                                  maxLines: 2,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 4),
                                                _ratingStars(comic.ratingAvg),
                                                const SizedBox(height: 4),
                                                if (comic.description != null &&
                                                    comic.description!.isNotEmpty)
                                                  Text(
                                                    comic.description!,
                                                    style: TextStyle(
                                                      color: Colors.grey.shade600,
                                                      fontSize: 12,
                                                    ),
                                                    maxLines: 2,
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
                            ),
            )
          ],
        ),
      ),
    );
  }
}

