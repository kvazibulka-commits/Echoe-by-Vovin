import 'package:flutter/material.dart';

void main() => runApp(const EchoesApp());

class EchoesApp extends StatelessWidget {
  const EchoesApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData.dark(useMaterial3: true),
        home: const Scaffold(
          body: Center(
            child: Text('Echoes', style: TextStyle(fontSize: 32, letterSpacing: 6)),
          ),
        ),
      );
}
