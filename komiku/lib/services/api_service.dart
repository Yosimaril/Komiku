import 'dart:io';
import 'dart:typed_data';

import 'package:komiku/models/api.dart';
import 'package:komiku/models/category.dart';
import 'package:komiku/models/chapter.dart';
import 'package:komiku/models/chapter_page.dart';
import 'package:komiku/models/comic.dart';
import 'package:komiku/models/comment.dart';
import 'package:komiku/models/rating.dart';
import 'package:komiku/models/reply.dart';
import 'package:komiku/models/user.dart';
import 'package:komiku/static/request_action.dart';

class ApiService {
  static late Api _api;

  static void initialize(Api api) {
    _api = api;
  }

  // User ====================================================================================================
  static Future<Map<String, dynamic>> login(User user) {
    return _api.post(
      action: RequestAction.login,
      body: {'user': user.toJson()},
    );
  }

  static Future<Map<String, dynamic>> register(User user) {
    return _api.post(
      action: RequestAction.register,
      body: {'user': user.toJson()},
    );
  }

  static Future<Map<String, dynamic>> updateUser(User user) {
    return _api.postAuthenticated(
      action: RequestAction.updateUser,
      body: {'user': user.toJson()},
    );
  }

  // Category ====================================================================================================
  static Future<Map<String, dynamic>> getCategories({String? keyword}) {
    return _api.post(
      action: RequestAction.getCategories,
      body: {'keyword': keyword},
    );
  }

  static Future<Map<String, dynamic>> insertCategory(Category category) {
    return _api.postAuthenticated(
      action: RequestAction.insertCategory,
      body: {'category': category.toJson()},
    );
  }

  static Future<Map<String, dynamic>> updateCategory(Category category) {
    return _api.postAuthenticated(
      action: RequestAction.updateCategory,
      body: {'category': category.toJson()},
    );
  }

  static Future<Map<String, dynamic>> deleteCategory(int id) {
    return _api.postAuthenticated(
      action: RequestAction.deleteCategory,
      body: {'id': id},
    );
  }

  // Comic ====================================================================================================
  static Future<Map<String, dynamic>> getComics({String? keyword}) {
    return _api.post(
      action: RequestAction.getComics,
      body: {'keyword': keyword},
    );
  }

  static Future<Map<String, dynamic>> getComicDetail(int id) {
    return _api.post(action: RequestAction.getComicDetail, body: {'id': id});
  }

  static Future<Map<String, dynamic>> insertComic(
    Comic comic, {
    File? poster,
    Uint8List? posterBytes,
    String? posterFilename,
  }) {
    return _api.postMultipartAuthenticated(
      action: RequestAction.insertComic,
      body: {
        'comic': {
          'title': comic.title,
          'description': comic.description,
          'categories': comic.categories.map((e) => e.id).toList(),
        },
      },
      files: {
        'poster': ?poster,
        if (posterBytes != null)
          'poster': {
            'bytes': posterBytes,
            'filename': posterFilename ?? 'poster',
          },
      },
    );
  }

  static Future<Map<String, dynamic>> updateComic(
    Comic comic, {
    File? poster,
    Uint8List? posterBytes,
    String? posterFilename,
  }) {
    return _api.postMultipartAuthenticated(
      action: RequestAction.updateComic,
      body: {
        'comic': {
          'id': comic.id,
          'title': comic.title,
          'description': comic.description,
          'categories': comic.categories.map((e) => e.id).toList(),
        },
      },
      files: {
        'poster': ?poster,
        if (posterBytes != null)
          'poster': {
            'bytes': posterBytes,
            'filename': posterFilename ?? 'poster',
          },
      },
    );
  }

  static Future<Map<String, dynamic>> deleteComic(int id) {
    return _api.postAuthenticated(
      action: RequestAction.deleteComic,
      body: {'id': id},
    );
  }

  static Future<Map<String, dynamic>> addComicView(int id) {
    return _api.postAuthenticated(
      action: RequestAction.addComicView,
      body: {'id': id},
    );
  }

  // Chapter ====================================================================================================
  static Future<Map<String, dynamic>> getComicChapters(
    int comicId, {
    String? keyword,
  }) {
    return _api.post(
      action: RequestAction.getComicChapters,
      body: {'comic_id': comicId, 'keyword': keyword},
    );
  }

  static Future<Map<String, dynamic>> insertComicChapters(
    int comicId,
    List<Chapter> chapters,
  ) {
    return _api.postAuthenticated(
      action: RequestAction.insertComicChapters,
      body: {
        'comic_id': comicId,
        'chapters': chapters.map((e) => e.toJson()).toList(),
      },
    );
  }

  static Future<Map<String, dynamic>> updateComicChapter(Chapter chapter) {
    return _api.postAuthenticated(
      action: RequestAction.updateComicChapter,
      body: {'chapter': chapter.toJson()},
    );
  }

  static Future<Map<String, dynamic>> deleteComicChapter(int id) {
    return _api.postAuthenticated(
      action: RequestAction.deleteComicChapter,
      body: {'id': id},
    );
  }

  // Chapter Page ====================================================================================================
  static Future<Map<String, dynamic>> getComicChapterPages(int chapterId) {
    return _api.post(
      action: RequestAction.getComicChapterPages,
      body: {'chapter_id': chapterId},
    );
  }

  static Future<Map<String, dynamic>> insertComicChapterPages(
    int chapterId,
    List<File> imageFiles, {
    List<Uint8List>? pagesBytesWeb,
    int pageNumberOffset = 0,
  }) {
    final List<Map<String, dynamic>> pages = [];
    final Map<String, dynamic> files = {};

    if (pagesBytesWeb != null) {
      for (int i = 0; i < pagesBytesWeb.length; i++) {
        final pageNumber = pageNumberOffset + i + 1;
        final key = 'image_$i';
        pages.add({'page_number': pageNumber, 'image': key});
        files[key] = {
          'bytes': pagesBytesWeb[i],
          'filename': 'page_$pageNumber.png',
        };
      }
    } else {
      for (int i = 0; i < imageFiles.length; i++) {
        final pageNumber = pageNumberOffset + i + 1;
        final key = 'image_$i';
        pages.add({'page_number': pageNumber, 'image': key});
        files[key] = imageFiles[i];
      }
    }

    return _api.postMultipartAuthenticated(
      action: RequestAction.insertComicChapterPages,
      body: {'chapter_id': chapterId, 'pages': pages},
      files: files,
    );
  }

  static Future<Map<String, dynamic>> updateComicChapterPage(ChapterPage page) {
    return _api.postAuthenticated(
      action: RequestAction.updateComicChapterPage,
      body: {'page': page.toJson()},
    );
  }

  static Future<Map<String, dynamic>> deleteComicChapterPage(int id) {
    return _api.postAuthenticated(
      action: RequestAction.deleteComicChapterPage,
      body: {'id': id},
    );
  }

  // Comment ====================================================================================================
  static Future<Map<String, dynamic>> getComments(int comicId) {
    return _api.post(
      action: RequestAction.getComments,
      body: {'comic_id': comicId},
    );
  }

  static Future<Map<String, dynamic>> insertComment(Comment comment) {
    return _api.postAuthenticated(
      action: RequestAction.insertComment,
      body: {
        'comment': {'comic_id': comment.comicId, 'content': comment.content},
      },
    );
  }

  static Future<Map<String, dynamic>> updateComment(Comment comment) {
    return _api.postAuthenticated(
      action: RequestAction.updateComment,
      body: {
        'comment': {'id': comment.id, 'content': comment.content},
      },
    );
  }

  static Future<Map<String, dynamic>> deleteComment(int id) {
    return _api.postAuthenticated(
      action: RequestAction.deleteComment,
      body: {'id': id},
    );
  }

  // Reply ====================================================================================================
  static Future<Map<String, dynamic>> getReplies(int parentCommentId) {
    return _api.post(
      action: RequestAction.getReplies,
      body: {'parent_comment_id': parentCommentId},
    );
  }

  static Future<Map<String, dynamic>> insertReply(Reply reply) {
    return _api.postAuthenticated(
      action: RequestAction.insertReply,
      body: {
        'reply': {
          'parent_comment_id': reply.parentCommentId,
          'content': reply.content,
        },
      },
    );
  }

  static Future<Map<String, dynamic>> updateReply(Reply reply) {
    return _api.postAuthenticated(
      action: RequestAction.updateReply,
      body: {
        'reply': {'id': reply.id, 'content': reply.content},
      },
    );
  }

  static Future<Map<String, dynamic>> deleteReply(int id) {
    return _api.postAuthenticated(
      action: RequestAction.deleteReply,
      body: {'id': id},
    );
  }

  // Rating ====================================================================================================
  static Future<Map<String, dynamic>> getRating(int comicId) {
    return _api.postAuthenticated(
      action: RequestAction.getRating,
      body: {'comic_id': comicId},
    );
  }

  static Future<Map<String, dynamic>> saveRating(Rating rating) {
    return _api.postAuthenticated(
      action: RequestAction.saveRating,
      body: {'rating': rating.toJson()},
    );
  }

  static Future<Map<String, dynamic>> deleteRating(int comicId) {
    return _api.postAuthenticated(
      action: RequestAction.deleteRating,
      body: {'comic_id': comicId},
    );
  }
}
