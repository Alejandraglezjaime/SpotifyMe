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
    'Pop', 'Rock', 'Reggaeton', 'Rap', 'Trap', 'Hip Hop', 'Urbano', 'Banda', 'Salsa', 'K-POP', 'R&B', 'Country', 'Reggae',];


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
              final externalUrl = album['external_urls']['spotify'] ?? '';

              return GestureDetector(
                onTap: () => _openSpotifySong(externalUrl),
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
              color: Colors.grey[400], // gris suave y lindo para modo oscuro
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
          child:
          Text('Canciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
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
        toolbarHeight: 80, // altura mayor para más espacio arriba y abajo
        title: const Padding(
          padding: EdgeInsets.symmetric(vertical: 12.0),
          child: Text(
            'DESCUBRE NUEVOS GENEROS',
            style: TextStyle(
              color: Color(0xFFB0AFC1),
              fontWeight: FontWeight.w600,
              fontSize: 30,
              letterSpacing: 1.2,
            ),
          ),
        ),
        foregroundColor: Colors.white,
      ),

      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<dynamic>>(
              future: _newReleasesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error al cargar nuevos lanzamientos: ${snapshot.error}',
                        style: const TextStyle(color: Colors.redAccent)),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay nuevos lanzamientos disponibles.', style: TextStyle(color: Colors.white70)),
                  );
                }

                return _buildNewReleasesSection(snapshot.data!);
              },
            ),
            _buildFixedGenreButtons(),
            if (_selectedGenre != null)
              FutureBuilder<List<dynamic>>(
                future: _songsByGenreFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator(color: Colors.purpleAccent));
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error al cargar canciones: ${snapshot.error}',
                          style: const TextStyle(color: Colors.redAccent)),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay canciones para este género.', style: TextStyle(color: Colors.white70)),
                    );
                  }

                  return _buildSongsByGenreSection(snapshot.data!);
                },
              ),
          ],
        ),
      ),
    );
  }
}
