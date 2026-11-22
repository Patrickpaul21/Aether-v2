String cleanTitle(String raw) {
  var t = raw;
  t = t.replaceAll(
    RegExp(
      r'[\(\[][^\)\]]*(official|video|audio|lyric|visuali[sz]er|remaster|hd|hq|4k|mv|m/v|clip|feat|ft\.)[^\)\]]*[\)\]]',
      caseSensitive: false,
    ),
    '',
  );
  t = t.replaceAll(
    RegExp(r'\b(official\s+(music\s+)?(video|audio)|lyric\s+video)\b',
        caseSensitive: false),
    '',
  );
  t = t.replaceAll(RegExp(r'\s+'), ' ').trim();
  t = t.replaceAll(RegExp(r'[-–|]\s*$'), '').trim();
  return t;
}

String cleanArtist(String raw) {
  return raw
      .replaceAll(RegExp(r'\s*-\s*Topic$', caseSensitive: false), '')
      .replaceAll(RegExp(r'VEVO$', caseSensitive: false), '')
      .replaceAll(RegExp(r'\s*(official|music)$', caseSensitive: false), '')
      .trim();
}
