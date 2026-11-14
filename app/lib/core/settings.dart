import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const defaultServerUrl = 'http://192.168.68.51:8000';

final prefsProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('prefsProvider must be overridden'),
);

class ServerUrlNotifier extends Notifier<String> {
  @override
  String build() =>
      ref.read(prefsProvider).getString('server_url') ?? defaultServerUrl;

  Future<void> save(String value) async {
    final cleaned = value.trim().replaceAll(RegExp(r'/+$'), '');
    await ref.read(prefsProvider).setString('server_url', cleaned);
    state = cleaned;
  }
}

final serverUrlProvider =
    NotifierProvider<ServerUrlNotifier, String>(ServerUrlNotifier.new);
