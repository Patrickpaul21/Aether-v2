import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import '../../core/appearance.dart';
import '../../core/settings.dart';
import '../../core/theme.dart';

const appVersion = '2.0.0-dev';
const repoUrl = 'github.com/Patrickpaul21/Aether-v2';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(serverUrlProvider));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final value = _controller.text.trim();
    final messenger = ScaffoldMessenger.of(context);
    if (!value.startsWith('http://') && !value.startsWith('https://')) {
      messenger.showSnackBar(
        const SnackBar(
            content: Text('Address must start with http:// or https://')),
      );
      return;
    }
    await ref.read(serverUrlProvider.notifier).save(value);
    messenger.showSnackBar(const SnackBar(content: Text('Saved')));
  }

  Future<void> _test() async {
    final messenger = ScaffoldMessenger.of(context);
    final base = _controller.text.trim().replaceAll(RegExp(r'/+$'), '');
    messenger.showSnackBar(const SnackBar(content: Text('Testing...')));
    try {
      final res = await http
          .get(Uri.parse('$base/health'))
          .timeout(const Duration(seconds: 6));
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(SnackBar(
        content: Text(res.statusCode == 200
            ? 'Connected to the Aether server'
            : 'Server answered with ${res.statusCode}'),
      ));
    } catch (_) {
      messenger.hideCurrentSnackBar();
      messenger.showSnackBar(const SnackBar(
        content: Text("Can't reach the server. Check the address, and that it's running."),
      ));
    }
  }

  Widget _section(String title) => Padding(
        padding: const EdgeInsets.only(top: 32, bottom: 8),
        child: Text(title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      );

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final ap = ref.watch(appearanceProvider);
    final notifier = ref.read(appearanceProvider.notifier);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text('Server address',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text(
            'Your Aether server, for example http://192.168.1.23:8000',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            keyboardType: TextInputType.url,
            autocorrect: false,
            decoration: InputDecoration(
              filled: true,
              fillColor: scheme.surfaceContainerHigh,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(6),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              FilledButton(onPressed: _save, child: const Text('Save')),
              const SizedBox(width: 12),
              OutlinedButton(
                  onPressed: _test, child: const Text('Test connection')),
            ],
          ),
          _section('Appearance'),
          const Text('Accent colour',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 14,
            children: [
              for (final e in accentPresets.entries)
                GestureDetector(
                  onTap: () => notifier.setAccent(e.key),
                  child: Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: e.value,
                      shape: BoxShape.circle,
                      border: ap.accent == e.key
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                    child: ap.accent == e.key
                        ? const Icon(Icons.check, color: Colors.black)
                        : null,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Pure black (AMOLED)'),
            subtitle: const Text('Deeper blacks on OLED screens',
                style: TextStyle(color: AppColors.textSecondary)),
            value: ap.amoled,
            onChanged: notifier.setAmoled,
          ),
          _section('About'),
          const ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text('Aether'),
            subtitle: Text('Version $appVersion',
                style: TextStyle(color: AppColors.textSecondary)),
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Source code'),
            subtitle: const Text(repoUrl,
                style: TextStyle(color: AppColors.textSecondary)),
            trailing: const Icon(Icons.copy, size: 18),
            onTap: () {
              Clipboard.setData(const ClipboardData(text: 'https://$repoUrl'));
              ScaffoldMessenger.of(context)
                  .showSnackBar(const SnackBar(content: Text('Link copied')));
            },
          ),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Credits and licences'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => showLicensePage(
              context: context,
              applicationName: 'Aether',
              applicationVersion: appVersion,
            ),
          ),
        ],
      ),
    );
  }
}
