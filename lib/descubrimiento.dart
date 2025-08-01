import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '/services/spotify_api.dart';

class Descubrimiento extends StatefulWidget {
  const Descubrimiento({Key? key}) : super(key: key);

  @override
  _DescubrimientoState createState() => _DescubrimientoState();
}

class _DescubrimientoState extends State<Descubrimiento> {
  Map<String, dynamic>? _currentSong;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRandomSong();
  }

  Future<void> _loadRandomSong() async {
    setState(() {
      _loading = true;
    });
    try {
      final spotify = Provider.of<SpotifyApi>(context, listen: false);
      final songs = await spotify.getRandomPopularSongs();
      if (songs.isNotEmpty) {
        songs.shuffle();
        setState(() {
          _currentSong = songs.first;
          _loading = false;
        });
      } else {
        setState(() {
          _loading = false;
          _currentSong = null;
        });
      }
    } catch (e) {
      setState(() {
        _loading = false;
        _currentSong = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cargar canción: $e')),
      );
    }
  }

  Future<void> _openSpotifySong(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Spotify')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF6A0572),
              Color(0xFFC72C39),
              Color(0xFF6A0572),
            ],
          ),
        ),
        child: Column(
          children: [
            AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              centerTitle: true,
              toolbarHeight: 100,
              title: const Text(
                'Sal de tu zona de confort',
                style: TextStyle(
                  color: Color(0xFFB0AFC1),
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
            Expanded(
              child: _loading
                  ? const Center(
                  child: CircularProgressIndicator(color: Colors.white))
                  : _currentSong == null
                  ? const Center(
                child: Text(
                  'No se encontró ninguna canción',
                  style: TextStyle(color: Colors.white70, fontSize: 18),
                ),
              )
                  : SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 20,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(25),
                        child: Image.network(
                          _currentSong!['album']['images'][0]['url'],
                          height: 300,
                          width: 300,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 25),
                    Text(
                      _currentSong!['name'],
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 1.1,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      (_currentSong!['artists'] as List)
                          .map((a) => a['name'])
                          .join(', '),
                      style: const TextStyle(
                        fontSize: 18,
                        color: Colors.white70,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.whatshot, color: Colors.redAccent),
                        const SizedBox(width: 6),
                        Text(
                          'Popularidad: ${_currentSong!['popularity']}',
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ],
                    ),
                    const SizedBox(height: 40),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton.icon(
                          onPressed: () {
                            _openSpotifySong(
                                _currentSong!['external_urls']['spotify']);
                          },
                          icon: const Icon(Icons.play_circle_fill_rounded,
                              size: 28),
                          label: const Text('Escuchar'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF6C43AB),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 30, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 20),
                        ElevatedButton.icon(
                          onPressed: _loadRandomSong,
                          icon: const Icon(Icons.shuffle_rounded, size: 26),
                          label: const Text('Aleatorio'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.grey[850],
                            padding: const EdgeInsets.symmetric(
                                horizontal: 28, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                            textStyle: const TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
