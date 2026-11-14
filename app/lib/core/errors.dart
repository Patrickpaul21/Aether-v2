String friendlyError(Object e) {
  final s = e.toString();
  if (s.contains('SocketException') ||
      s.contains('ClientException') ||
      s.contains('TimeoutException')) {
    return "Can't reach the server. Check it's running and the address in Settings.";
  }
  if (s.contains('Server returned')) {
    return "Couldn't load this track. Try another one.";
  }
  return "Couldn't play this track.";
}
