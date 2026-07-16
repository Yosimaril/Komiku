enum NavigationRoute {
  homeScreen('/'),
  loginScreen('/login'),
  registerScreen('/register'),
  listCategoryScreen('/category'),
  listComicScreen('/comic'),
  comicDetailScreen('/comic-detail'),
  createComicScreen('/create-comic'),
  createComicChapterScreen('/create-chapter'),
  updateComicScreen('/update-comic'),
  updateComicChapterScreen('/update-chapter'),
  chapterDetailScreen('/chapter-detail'),
  settingScreen('/setting');

  final String name;

  const NavigationRoute(this.name);
}
