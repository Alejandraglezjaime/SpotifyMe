import 'package:flutter/material.dart';
import 'package:music_player_tutorial/Principal.dart';
import 'package:provider/provider.dart';
import 'Principal.dart';
import 'services/spotify_api.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => SpotifyApi(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spotify Clone',
      theme: ThemeData(
        primarySwatch: Colors.green,
      ),
      home: const Principal(),
    );
  }
}

