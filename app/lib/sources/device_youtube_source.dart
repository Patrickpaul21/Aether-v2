import 'package:youtube_explode_dart/youtube_explode_dart.dart' hide StreamInfo;
import '../core/track.dart';
import 'music_source.dart';

class DeviceYoutubeSource implements MusicSource {
  final YoutubeExplode _yt = YoutubeExplode();

  @override
  Future<List<Track>> search(String query) async {
    final results = await _yt.search.search(query);
    return results
        .map((v) => Track(
              id: v.id.value,
              title: v.title,
              artist: v.author,
              coverUrl: 'https://i.ytimg.com/vi/${v.id.value}/hqdefault.jpg',
              source: 'youtube',
            ))
        .toList();
  }

  @override
  Future<StreamInfo> getStream(String trackId) async {
    final manifest = await _yt.videos.streams.getManifest(
      trackId,
      ytClients: [YoutubeApiClient.androidVr, YoutubeApiClient.safari],
    );
    final audio = manifest.audioOnly.withHighestBitrate();
    return StreamInfo(audio.url.toString());
  }
}
