enum RequestAction {
  login('LOGIN'),
  register('REGISTER'),
  updateUser('UPDATE_USER'),
  deleteUser('DELETE_USER'),
  getCategories('GET_CATEGORIES'),
  insertCategory('INSERT_CATEGORY'),
  updateCategory('UPDATE_CATEGORY'),
  deleteCategory('DELETE_CATEGORY'),
  getComics('GET_COMICS'),
  getComicDetail('GET_COMIC_DETAIL'),
  insertComic('INSERT_COMIC'),
  updateComic('UPDATE_COMIC'),
  deleteComic('DELETE_COMIC'),
  addComicView("ADD_COMIC_VIEW"),
  getComicChapters('GET_COMIC_CHAPTERS'),
  insertComicChapters('INSERT_COMIC_CHAPTERS'),
  updateComicChapter('UPDATE_COMIC_CHAPTER'),
  deleteComicChapter('DELETE_COMIC_CHAPTER'),
  getComicChapterPages('GET_COMIC_CHAPTER_PAGES'),
  insertComicChapterPages('INSERT_COMIC_CHAPTER_PAGES'),
  updateComicChapterPage('UPDATE_COMIC_CHAPTER_PAGE'),
  deleteComicChapterPage('DELETE_COMIC_CHAPTER_PAGE'),
  getComments('GET_COMMENTS'),
  insertComment('INSERT_COMMENT'),
  updateComment('UPDATE_COMMENT'),
  deleteComment('DELETE_COMMENT'),
  getReplies('GET_REPLIES'),
  insertReply('INSERT_REPLY'),
  updateReply('UPDATE_REPLY'),
  deleteReply('DELETE_REPLY'),
  getRating('GET_RATING'),
  saveRating('SAVE_RATING'),
  deleteRating('DELETE_RATING');

  final String action;

  const RequestAction(this.action);
}
