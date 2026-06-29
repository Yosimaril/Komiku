class Comic {
  final int id;
  final int creatorId;
  final String title;
  final String? posterUrl;
  final String? description;
  final double ratingAvg;

  const Comic({
    required this.id,
    required this.creatorId,
    required this.title,
    this.posterUrl,
    this.description,
    required this.ratingAvg,
  });
}

