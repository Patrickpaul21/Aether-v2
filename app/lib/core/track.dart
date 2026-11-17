class Track {
  final String id;
  final String title;
  final String artist;
  final String coverUrl;
  final String source;
  final int? duration;

  const Track({
    required this.id,
    required this.title,
    required this.artist,
    required this.coverUrl,
    required this.source,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'artist': artist,
        'coverUrl': coverUrl,
        'source': source,
        'duration': duration,
      };

  factory Track.fromJson(Map<String, dynamic> j) => Track(
        id: j['id'] as String,
        title: j['title'] as String,
        artist: j['artist'] as String,
        coverUrl: (j['coverUrl'] as String?) ?? '',
        source: (j['source'] as String?) ?? 'youtube',
        duration: (j['duration'] as num?)?.round(),
      );
}
