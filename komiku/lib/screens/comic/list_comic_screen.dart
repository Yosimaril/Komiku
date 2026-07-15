import 'package:flutter/material.dart';
import 'package:komiku/components/list_comic_screen/comic_card.dart';
import 'package:komiku/components/list_comic_screen/search_field.dart';
import 'package:komiku/models/category.dart';
import 'package:komiku/models/comic.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_message.dart';
import 'package:komiku/static/navigation_route.dart';

class ListComicScreen extends StatefulWidget {
  final int? categoryId;

  const ListComicScreen({super.key, this.categoryId});

  @override
  State<ListComicScreen> createState() => _ListComicScreenState();
}

class _ListComicScreenState extends State<ListComicScreen> {
  late Future<void> _future;

  final _searchController = TextEditingController();

  List<Comic> _allComics = [];
  List<Comic> _filteredComics = [];

  List<Category> _categories = [];

  String _keyword = '';
  final Set<int> _selectedCategoryIds = {};

  @override
  void initState() {
    super.initState();

    _selectedCategoryIds.add(widget.categoryId ?? 0);
    _future = _loadData();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    final comicsResponse = await ApiService.getComics();
    final categoriesResponse = await ApiService.getCategories();

    _allComics = (comicsResponse['data'] as List)
        .map((e) => Comic.fromJson(e))
        .toList();

    _categories = (categoriesResponse['data'] as List)
        .map((e) => Category.fromJson(e))
        .toList();

    _applyFilter();
  }

  void _applyFilter() {
    _filteredComics = _allComics.where((comic) {
      final keywordMatch =
          _keyword.isEmpty ||
          comic.title.toLowerCase().contains(_keyword.toLowerCase());

      final categoryMatch =
          _selectedCategoryIds.isEmpty ||
          comic.categories.any(
            (category) => _selectedCategoryIds.contains(category.id),
          );

      return keywordMatch && categoryMatch;
    }).toList();

    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${ErrorMessage.loadComicError}: ${snapshot.error}'),
          );
        }

        return Column(
          children: [
            SearchField(
              controller: _searchController,
              onEmpty: () {
                _keyword = '';
                _applyFilter();
              },
              onSearch: (value) {
                _keyword = value;
                _applyFilter();
              },
            ),

            SizedBox(
              height: 56,
              child: ListView(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                scrollDirection: Axis.horizontal,
                children: [
                  FilterChip(
                    selected: _selectedCategoryIds.isEmpty,
                    label: const Text('All'),
                    onSelected: (_) {
                      _selectedCategoryIds.clear();
                      _applyFilter();
                    },
                  ),

                  const SizedBox(width: 8),

                  ..._categories.map(
                    (category) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        selected: _selectedCategoryIds.contains(category.id),
                        label: Text(category.name),
                        onSelected: (selected) {
                          setState(() {
                            if (selected) {
                              _selectedCategoryIds.add(category.id!);
                            } else {
                              _selectedCategoryIds.remove(category.id);
                            }

                            _applyFilter();
                          });
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),

            Expanded(child: ListComicWidget(comics: _filteredComics)),
          ],
        );
      },
    );
  }
}

class ListComicWidget extends StatelessWidget {
  const ListComicWidget({super.key, required this.comics});

  final List<Comic> comics;

  @override
  Widget build(BuildContext context) {
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
            Navigator.pushNamed(
              context,
              NavigationRoute.comicDetailScreen.name,
              arguments: comic.id,
            );
          },
          child: ComicCard(comic: comic),
        );
      },
    );
  }
}
