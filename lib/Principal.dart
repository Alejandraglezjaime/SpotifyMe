import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/spotify_api.dart';

class Principal extends StatefulWidget {
  const Principal({Key? key}) : super(key: key);

  @override
  State<Principal> createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  Future<List<dynamic>>? _newReleasesFuture;
  Future<List<dynamic>>? _genresFuture;
  Future<List<dynamic>>? _songsByGenreFuture;
  String? _selectedGenre;

  final List<String> _genreButtons = [
    'Pop', 'Rock', 'Reggaeton', 'Rap', 'Trap', 'Hip Hop', 'Urbano', 'Banda', 'Salsa', 'K-POP', 'R&B', 'Country', 'Reggae',
  ];

  @override
  void initState() {
    super.initState();
    final spotify = Provider.of<SpotifyApi>(context, listen: false);
    _newReleasesFuture = spotify.getNewReleases();
    _genresFuture = spotify.getGenres();
  }

  void _onGenreSelected(String genre) {
    setState(() {
      _selectedGenre = genre;
      _songsByGenreFuture =
          Provider.of<SpotifyApi>(context, listen: false).getSongsByGenre(genre);
    });
  }

  Future<void> _openSpotifySong(String externalUrl) async {
    final Uri url = Uri.parse(externalUrl);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Perdón, no se puede abrir Spotify')),
      );
    }
  }

  // Función para reproducir la primera canción de un álbum
  Future<void> _playFirstTrackOfAlbum(String albumId) async {
    try {
      final spotify = Provider.of<SpotifyApi>(context, listen: false);
      final tracks = await spotify.getAlbumTracks(albumId);
      if (tracks.isNotEmpty) {
        final firstTrack = tracks[0];
        final externalUrl = firstTrack['external_urls']['spotify'] ?? '';
        if (externalUrl.isNotEmpty) {
          await _openSpotifySong(externalUrl);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo reproducir la canción del álbum')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Este álbum no tiene canciones disponibles')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al reproducir álbum: $e')),
      );
    }
  }

  Widget _buildNewReleasesSection(List<dynamic> albums) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
          child: Text(
            'Nuevos lanzamientos',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
        ),
        SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: albums.length,
            itemBuilder: (context, index) {
              final album = albums[index];
              final imageUrl = album['images'][0]['url'];
              final name = album['name'];
              final artists = (album['artists'] as List).map((a) => a['name']).join(', ');
              // Usamos album['id'] para buscar las canciones
              final albumId = album['id'];

              return GestureDetector(
                onTap: () => _playFirstTrackOfAlbum(albumId),
                child: Container(
                  width: 180,
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1B24),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                        child: Image.network(imageUrl, width: 180, height: 180, fit: BoxFit.cover),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          artists,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildFixedGenreButtons() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
          child: Text(
            'Explorar por género',
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
              color: Colors.grey[400],
            ),
          ),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _genreButtons.length,
            itemBuilder: (context, index) {
              final genre = _genreButtons[index];
              final isSelected = genre.toLowerCase() == _selectedGenre?.toLowerCase();

              return GestureDetector(
                onTap: () => _onGenreSelected(genre),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? const Color(0xFFBB86FC) : Colors.grey[800],
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: isSelected
                        ? [
                      BoxShadow(
                        color: Colors.purpleAccent.withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(0, 3),
                      ),
                    ]
                        : [],
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: isSelected ? Colors.black : Colors.white70,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSongsByGenreSection(List<dynamic> songs) {
    if (songs.isEmpty) {
      return const Padding(
        padding: EdgeInsets.all(8.0),
        child: Text('No se encontraron canciones para este género.',
            style: TextStyle(color: Colors.white70)),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Canciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
        ),
        SizedBox(
          height: 250,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              final imageUrl = (song['album']['images'] as List).isNotEmpty
                  ? song['album']['images'][0]['url']
                  : null;
              final name = song['name'];
              final artists = (song['artists'] as List).map((a) => a['name']).join(', ');
              final externalUrl = song['external_urls']['spotify'] ?? '';

              return GestureDetector(
                onTap: () => _openSpotifySong(externalUrl),
                child: Container(
                  width: 160,
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1F1B24),
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.6),
                        blurRadius: 8,
                        offset: const Offset(2, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (imageUrl != null)
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
                          child: Image.network(
                            imageUrl,
                            width: 160,
                            height: 160,
                            fit: BoxFit.cover,
                          ),
                        )
                      else
                        const Icon(Icons.music_note, size: 100, color: Colors.white70),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 8.0),
                        child: Text(
                          artists,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF121212),
      appBar: AppBar(
        backgroundColor: const Color(0xFF4B0082),
        elevation: 2,
        centerTitle: true,
        toolbarHeight: 80,
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'Explora nuevos generos',
            style: TextStyle(
              color: Color(0xFFB0AFC1),
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            FutureBuilder<List<dynamic>>(
              future: _newReleasesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ));
                } else if (snapshot.hasError) {
                  return const Center(child: Text('Error al cargar nuevos lanzamientos'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('No hay nuevos lanzamientos'));
                } else {
                  return _buildNewReleasesSection(snapshot.data!);
                }
              },
            ),
            _buildFixedGenreButtons(),
            if (_selectedGenre != null)
              FutureBuilder<List<dynamic>>(
                future: _songsByGenreFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(20.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  } else if (snapshot.hasError) {
                    return const Center(child: Text('Error al cargar canciones por género'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No hay canciones para este género'));
                  } else {
                    return _buildSongsByGenreSection(snapshot.data!);
                  }
                },
              ),
          ],
        ),
      ),
    );
  }
}
