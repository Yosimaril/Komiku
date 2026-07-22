import 'package:flutter/material.dart';
import 'package:komiku/models/category.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/static/error_message.dart';
import 'package:komiku/static/navigation_route.dart';

class ListCategoryScreen extends StatefulWidget {
  const ListCategoryScreen({super.key});

  @override
  State<ListCategoryScreen> createState() => _ListCategoryScreenState();
}

class _ListCategoryScreenState extends State<ListCategoryScreen> {
  late Future<List<Category>> _futureCategories;

  @override
  void initState() {
    super.initState();
    _futureCategories = getCategories(null);
  }

  Future<List<Category>> getCategories(String? keyword) async {
    final response = await ApiService.getCategories(keyword: keyword);
    return response['data'].map<Category>((c) => Category.fromJson(c)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Category>>(
      future: _futureCategories,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Text('${ErrorMessage.loadCategoryError}: ${snapshot.error}'),
          );
        }

        final categories = snapshot.data ?? const [];
        if (categories.isEmpty) {
          return const Center(child: Text(ErrorMessage.loadCategoryEmpty));
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: GridView.builder(
            itemCount: categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.1,
            ),
            itemBuilder: (context, index) {
              final c = categories[index];
              return Card(
                elevation: 1,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                clipBehavior: Clip.antiAlias,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      NavigationRoute.listComicScreen.name,
                      arguments: c.id,
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          c.name,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            const Icon(Icons.library_books, size: 16),
                            const SizedBox(width: 4),
                            Text('${c.comicCount} comics'),
                          ],
                        ),
                        if (c.description?.isNotEmpty ?? false) ...[
                          const SizedBox(height: 6),
                          Text(
                            c.description!,
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}
