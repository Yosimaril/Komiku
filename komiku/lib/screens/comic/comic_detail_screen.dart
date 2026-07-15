import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:komiku/components/list_comic_screen/rating_star.dart';
import 'package:komiku/models/comic.dart';
import 'package:komiku/models/comment.dart';
import 'package:komiku/models/rating.dart';
import 'package:komiku/models/reply.dart';
import 'package:komiku/models/user.dart';
import 'package:komiku/services/api_service.dart';
import 'package:komiku/services/secure_storage_service.dart';
import 'package:komiku/static/error_message.dart';
import 'package:komiku/static/navigation_route.dart';
import 'package:provider/provider.dart';

class ComicDetailScreen extends StatefulWidget {
  final int comicId;

  const ComicDetailScreen({super.key, required this.comicId});

  @override
  State<ComicDetailScreen> createState() => _ComicDetailScreenState();
}

class _ComicDetailScreenState extends State<ComicDetailScreen> {
  late Future<Comic> _futureComic;
  User? _currentUser;
  int? _userRating;

  final _commentController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  Future<void> _loadInitialData() async {
    setState(() {
      _futureComic = _getComicDetail(widget.comicId);
    });
    final secureStorage = context.read<SecureStorageService>();
    final userJson = await secureStorage.getUser();
    if (userJson != null) {
      setState(() {
        _currentUser = User.fromJson(jsonDecode(userJson));
      });
    }
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<Comic> _getComicDetail(int id) async {
    final response = await ApiService.getComicDetail(id);
    Comic comic = Comic.fromJson(response['data']);

    // Check for existing rating
    try {
      final ratingResponse = await ApiService.getRating(id);
      if (ratingResponse['status'] == 'SUCCESS' && ratingResponse['data'] != null) {
        final ratingData = ratingResponse['data']['rating'];
        if (ratingData != null) {
          _userRating = int.tryParse(ratingData['rating'].toString());
        }
      }
    } catch (e) {
      debugPrint("Error loading rating: $e");
    }

    try {
      final commentsResponse = await ApiService.getComments(id);
      if (commentsResponse['status'] == 'SUCCESS') {
        List<Comment> comments = (commentsResponse['data'] as List)
            .map((e) => Comment.fromJson(e))
            .toList();

        // Fetch replies for each comment in parallel
        await Future.wait(comments.asMap().entries.map((entry) async {
          final commentIndex = entry.key;
          final comment = entry.value;
          final repliesResponse = await ApiService.getReplies(comment.id!);
          if (repliesResponse['status'] == 'SUCCESS') {
            List<Reply> replies = (repliesResponse['data'] as List)
                .map((e) => Reply.fromJson(e))
                .toList();
            comments[commentIndex] = comment.copyWith(replies: replies);
          }
        }));

        comic = comic.copyWith(comments: comments);
      }
    } catch (e) {
      debugPrint("Error loading comments/replies: $e");
    }

    return comic;
  }

  Future<void> _refreshData() async {
    final newData = _getComicDetail(widget.comicId);
    setState(() {
      _futureComic = newData;
    });
  }

  Future<void> _submitComment() async {
    if (_commentController.text.trim().isEmpty) return;

    final response = await ApiService.insertComment(
      Comment(
        comicId: widget.comicId,
        content: _commentController.text,
      ),
    );

    if (response['status'] == 'SUCCESS') {
      _commentController.clear();
      _refreshData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error_message']?.toString() ?? 'Failed to post comment')),
      );
    }
  }

  Future<void> _deleteComment(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comment?'),
        content: const Text('Are you sure you want to delete this comment?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.deleteComment(id);
      if (response['status'] == 'SUCCESS') {
        _refreshData();
      }
    }
  }

  Future<void> _editComment(Comment comment) async {
    final controller = TextEditingController(text: comment.content);
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Comment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Update your comment'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (newContent != null && newContent.trim().isNotEmpty && newContent != comment.content) {
      final response = await ApiService.updateComment(comment.copyWith(content: newContent));
      if (response['status'] == 'SUCCESS') {
        _refreshData();
      }
    }
  }

  Future<void> _submitReply(int parentCommentId) async {
    final controller = TextEditingController();
    final content = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reply to Comment'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter your reply'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Post')),
        ],
      ),
    );

    if (content != null && content.trim().isNotEmpty) {
      final response = await ApiService.insertReply(
        Reply(
          parentCommentId: parentCommentId,
          content: content,
        ),
      );

      if (response['status'] == 'SUCCESS') {
        _refreshData();
      }
    }
  }

  Future<void> _deleteReply(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Reply?'),
        content: const Text('Are you sure you want to delete this reply?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.deleteReply(id);
      if (response['status'] == 'SUCCESS') {
        _refreshData();
      }
    }
  }

  Future<void> _deleteChapter(int id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Chapter?'),
        content: const Text('Are you sure you want to delete this chapter? This will remove all its pages.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.deleteComicChapter(id);
      if (response['status'] == 'SUCCESS') {
        _refreshData();
      }
    }
  }

  Future<void> _editReply(Reply reply) async {
    final controller = TextEditingController(text: reply.content);
    final newContent = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Reply'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Update your reply'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, controller.text), child: const Text('Save')),
        ],
      ),
    );

    if (newContent != null && newContent.trim().isNotEmpty && newContent != reply.content) {
      final response = await ApiService.updateReply(reply.copyWith(content: newContent));
      if (response['status'] == 'SUCCESS') {
        _refreshData();
      }
    }
  }

  Future<void> _saveRating(int rating) async {
    final response = await ApiService.saveRating(
      Rating(comicId: widget.comicId, rating: rating),
    );

    if (response['status'] == 'SUCCESS') {
      setState(() {
        _userRating = rating;
      });
      _refreshData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error_message']?.toString() ?? 'Failed to save rating')),
      );
    }
  }

  Future<void> _deleteRating() async {
    final response = await ApiService.deleteRating(widget.comicId);

    if (response['status'] == 'SUCCESS') {
      setState(() {
        _userRating = null;
      });
      _refreshData();
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(response['error_message']?.toString() ?? 'Failed to delete rating')),
      );
    }
  }

  Future<void> _deleteComic() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Comic?'),
        content: const Text('Are you sure you want to delete this comic? This will remove all chapters and comments.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final response = await ApiService.deleteComic(widget.comicId);
      if (response['status'] == 'SUCCESS') {
        if (mounted) {
          Navigator.pop(context, true); // Go back to list and signal refresh
        }
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['error_message']?.toString() ?? 'Failed to delete comic')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Comic>(
      future: _futureComic,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }

        if (snapshot.hasError) {
          return Scaffold(body: Center(child: Text('${ErrorMessage.loadComicDetailError}: ${snapshot.error}')));
        }

        final comic = snapshot.data;
        if (comic == null) {
          return const Scaffold(body: Center(child: Text(ErrorMessage.loadComicDetailEmpty)));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(comic.title),
            actions: [
              if (_currentUser?.username == comic.creatorName) ...[
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    final refresh = await Navigator.pushNamed(
                      context,
                      NavigationRoute.updateComicScreen.name,
                      arguments: comic.id,
                    );
                    if (refresh == true) {
                      _refreshData();
                    }
                  },
                  tooltip: 'Edit Comic',
                ),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.red),
                  onPressed: _deleteComic,
                  tooltip: 'Delete Comic',
                ),
              ],
            ],
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

                const Divider(),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Your Rating',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Row(
                        children: [
                          ...List.generate(5, (index) {
                            final ratingValue = index + 1;
                            final isSelected = _userRating != null && _userRating! >= ratingValue;
                            return IconButton(
                              padding: EdgeInsets.zero,
                              constraints: const BoxConstraints(),
                              icon: Icon(
                                isSelected ? Icons.star : Icons.star_border,
                                color: Colors.amber,
                              ),
                              onPressed: () => _saveRating(ratingValue),
                            );
                          }),
                          const Spacer(),
                          if (_userRating != null)
                            TextButton(
                              onPressed: () {
                                _deleteRating();
                                setState(() {
                                  _userRating = null;
                                });
                              },
                              child: const Text('Clear', style: TextStyle(color: Colors.red)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Chapters',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      // if (_currentUser?.username == comic.creatorName)
                      if(true)
                        TextButton.icon(
                          onPressed: () async {
                            final refresh = await Navigator.pushNamed(
                              context,
                              NavigationRoute.createComicChapterScreen.name,
                              arguments: comic.id,
                            );
                            if (refresh == true) {
                              _refreshData();
                            }
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Chapter'),
                        ),
                    ],
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
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_currentUser?.username == comic.creatorName)
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                onPressed: () => _deleteChapter(chapter.id!),
                              ),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                        onTap: () {
                          // TODO: Readerscreen navigation
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
                        onPressed: _submitComment,
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
                      final isOwner = _currentUser?.id == comment.userId;

                      return Card(
                        margin: const EdgeInsets.only(bottom: 12),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                          side: BorderSide(color: Colors.grey.shade200),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    comment.username ?? 'Unknown',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  if (isOwner)
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        IconButton(
                                          icon: const Icon(Icons.edit, size: 18),
                                          onPressed: () => _editComment(comment),
                                        ),
                                        IconButton(
                                          icon: const Icon(Icons.delete, size: 18, color: Colors.red),
                                          onPressed: () => _deleteComment(comment.id!),
                                        ),
                                      ],
                                    ),
                                ],
                              ),

                              const SizedBox(height: 4),

                              Text(comment.content),

                              const SizedBox(height: 8),

                              TextButton.icon(
                                icon: const Icon(Icons.reply, size: 16),
                                label: const Text('Reply'),
                                onPressed: () => _submitReply(comment.id!),
                              ),

                              if (comment.replies.isNotEmpty)
                                ...[
                                  const Divider(),
                                  Padding(
                                    padding: const EdgeInsets.only(left: 16),
                                    child: ListView.builder(
                                      shrinkWrap: true,
                                      physics: const NeverScrollableScrollPhysics(),
                                      itemCount: comment.replies.length,
                                      itemBuilder: (context, rIndex) {
                                        final reply = comment.replies[rIndex];
                                        final isReplyOwner = _currentUser?.id == reply.userId;

                                        return Container(
                                          padding: const EdgeInsets.symmetric(vertical: 8),
                                          decoration: BoxDecoration(
                                            border: Border(left: BorderSide(color: Colors.grey.shade300, width: 2)),
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.only(left: 12),
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                  children: [
                                                    Text(
                                                      reply.username ?? 'Unknown',
                                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                                                    ),
                                                    if (isReplyOwner)
                                                      Row(
                                                        mainAxisSize: MainAxisSize.min,
                                                        children: [
                                                          IconButton(
                                                            icon: const Icon(Icons.edit, size: 16),
                                                            onPressed: () => _editReply(reply),
                                                          ),
                                                          IconButton(
                                                            icon: const Icon(Icons.delete, size: 16, color: Colors.red),
                                                            onPressed: () => _deleteReply(reply.id!),
                                                          ),
                                                        ],
                                                      ),
                                                  ],
                                                ),
                                                Text(reply.content, style: const TextStyle(fontSize: 14)),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ),
                                ],
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }
}
