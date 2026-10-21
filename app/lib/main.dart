import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

const _ch = MethodChannel('echoes/np');

void main() => runApp(const EchoesApp());

class EchoesApp extends StatelessWidget {
  const EchoesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const NowPlaying(),
      );
}

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key});

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> {
  Timer? _timer;
  bool _enabled = false;
  Map<String, String>? _track;

  @override
  void initState() {
    super.initState();
    _poll();
    _timer = Timer.periodic(const Duration(seconds: 3), (_) => _poll());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _poll() async {
    try {
      final en = await _ch.invokeMethod<bool>('isEnabled') ?? false;
      final tr = en ? await _ch.invokeMapMethod<String, String>('current') : null;
      if (mounted) setState(() {
        _enabled = en;
        _track = tr;
      });
    } on PlatformException {
      // следующий опрос повторит попытку
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = _track;
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: !_enabled
              ? Column(mainAxisSize: MainAxisSize.min, children: [
                  const Text('Нужен доступ к уведомлениям, чтобы видеть, что играет',
                      textAlign: TextAlign.center),
                  const SizedBox(height: 16),
                  FilledButton(
                    onPressed: () => _ch.invokeMethod('openSettings'),
                    child: const Text('Разрешить'),
                  ),
                ])
              : t == null
                  ? const Text('Тишина…', style: TextStyle(fontSize: 20))
                  : Column(mainAxisSize: MainAxisSize.min, children: [
                      Text(t['title']!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 26)),
                      const SizedBox(height: 8),
                      Text(t['artist']!, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 8),
                      Text(t['app']!, style: const TextStyle(fontSize: 12)),
                    ]),
        ),
      ),
    );
  }
}
