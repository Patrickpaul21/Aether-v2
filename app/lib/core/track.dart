class Track {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String source;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.source,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'coverUrl': coverUrl,
        'source': source,
      };

  factory Track.fromJson(Map<String, dynamic> j) => Track(
        id: j['id'] as String,
        title: j['title'] as String,
        artist: j['artist'] as String,
        coverUrl: (j['coverUrl'] as String?) ?? '',
        source: (j['source'] as String?) ?? 'youtube',
      );
}
