import '../models/category.dart';
import '../models/comic.dart';
import '../models/chapter.dart';
import '../models/comment.dart';

class KomikuApiService {
  const KomikuApiService();

  // use api utk get categories
  Future<List<Category>> getCategories() async {
    // connect ke ubaya.cloud API buat categories.
    // GET https://ubaya.cloud/flutter/[NRP]/categories.php
    return const [];
  }

  // use api utk get comics by category
  Future<List<Comic>> getComicsByCategory(int categoryId) async {
    // connect ke ubaya.cloud API for comics list.
    // POST https://ubaya.cloud/flutter/[NRP]/comics_by_category.php
    return const [];
  }

  // use api utk search comics by title (future)
  Future<List<Comic>> searchComicsByTitle(String query) async {
    // connect ke ubaya.cloud API for searching comics.
    return const [];
  }

  // use api utk get comic read layout (chapters, comments, etc.)
  Future<({Comic comic, List<Chapter> chapters, List<Comment> comments})>
      getComicReadLayout(int comicId) async {
    // connect ke ubaya.cloud API.
    throw UnimplementedError('Not implemented yet');
  }
}

