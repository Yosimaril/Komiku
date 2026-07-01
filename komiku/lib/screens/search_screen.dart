import 'package:flutter/material.dart';

import '../models/comic.dart';
import '../services/komiku_api_service.dart';
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

  @override
  void initState() {
    super.initState();
    _searchController.text = '';
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
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Search...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) {
                setState(() {
                  _query = v;
                });
              },
              onSubmitted: (_) => searchComics(),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _results.isEmpty
                      ? const Center(child: Text('No results'))
                      : ListView.builder(
                          itemCount: _results.length,
                          itemBuilder: (context, index) {
                            final comic = _results[index];
                            return ListTile(
                              leading: comic.posterUrl != null && comic.posterUrl!.isNotEmpty
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8),
                                      child: Image.network(
                                        comic.posterUrl!,
                                        width: 45,
                                        height: 60,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : Container(
                                      width: 45,
                                      height: 60,
                                      color: Colors.grey.shade200,
                                    ),
                              title: Text(comic.title),
                              subtitle: Text(comic.description ?? ''),
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

