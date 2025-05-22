import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/spotify_api.dart';
import 'navegacion.dart';
import 'principal.dart'; // Importa aquí la pantalla Principal

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<SpotifyApi>(
          create: (_) => SpotifyApi(),
        ),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tu App',
      theme: ThemeData.dark(),
      home: const Navegacion(),
    );
  }
}
