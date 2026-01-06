class Anime {
  final String title;
  final String imageUrl;
  final String videoUrl;
  final String description;

  Anime({
    required this.title,
    required this.imageUrl,
    required this.videoUrl,
    required this.description,
  });

  factory Anime.fromJson(Map<String, dynamic> json) {
    return Anime(
      title: json['title'] ?? '',
      imageUrl: json['images']['jpg']['image_url'] ?? '',
      videoUrl: json['trailer']['url'] ?? '',
      description: json['synopsis'] ?? '',
    );
  }
}