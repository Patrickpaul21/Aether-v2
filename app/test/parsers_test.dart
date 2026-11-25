import 'package:flutter_test/flutter_test.dart';
import 'package:aether/core/text_clean.dart';
import 'package:aether/core/youtube_link.dart';
import 'package:aether/lyrics/lyrics_service.dart';

void main() {
  group('parseVideoId', () {
    test('watch link', () {
      expect(parseVideoId('https://www.youtube.com/watch?v=dQw4w9WgXcQ'),
          'dQw4w9WgXcQ');
    });
    test('short link with tracking', () {
      expect(parseVideoId('https://youtu.be/dQw4w9WgXcQ?si=abc'), 'dQw4w9WgXcQ');
    });
    test('music link with extra params', () {
      expect(
          parseVideoId(
              'https://music.youtube.com/watch?v=dQw4w9WgXcQ&list=RDAMVM'),
          'dQw4w9WgXcQ');
    });
    test('shorts link', () {
      expect(parseVideoId('https://www.youtube.com/shorts/dQw4w9WgXcQ'),
          'dQw4w9WgXcQ');
    });
    test('plain text is not a link', () {
      expect(parseVideoId('youtube lofi'), isNull);
    });
    test('invalid id is rejected', () {
      expect(parseVideoId('https://youtu.be/short'), isNull);
    });
  });

  group('text cleaning', () {
    test('removes video noise from titles', () {
      expect(cleanTitle('Blinding Lights (Official Video)'), 'Blinding Lights');
    });
    test('cleans topic and vevo channel names', () {
      expect(cleanArtist('The Weeknd - Topic'), 'The Weeknd');
      expect(cleanArtist('TaylorSwiftVEVO'), 'TaylorSwift');
    });
  });

  group('parseLrc', () {
    test('parses timestamps and text', () {
      final lines = parseLrc('[00:12.50] Hello\n[01:05.00] World');
      expect(lines.length, 2);
      expect(lines.first.time, const Duration(seconds: 12, milliseconds: 500));
      expect(lines.first.text, 'Hello');
    });
    test('handles several timestamps on one line and sorts', () {
      final lines = parseLrc('[00:20.00][00:10.00] Chorus');
      expect(lines.length, 2);
      expect(lines.first.time, const Duration(seconds: 10));
    });
  });
}
