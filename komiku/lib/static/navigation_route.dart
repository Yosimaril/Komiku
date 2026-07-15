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
  settingScreen('/setting');

  final String name;

  const NavigationRoute(this.name);
}
