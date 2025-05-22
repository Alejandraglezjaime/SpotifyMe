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
        const SnackBar(content: Text('No se pudo abrir Spotify')),
      );
    }
  }

  Widget _buildNewReleasesSection(List<dynamic> albums) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Nuevos Lanzamientos',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
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
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.network(imageUrl, width: 180, height: 180, fit: BoxFit.cover),
                      const SizedBox(height: 8),
                      Text(name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(artists, maxLines: 1, overflow: TextOverflow.ellipsis),
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

  Widget _buildGenresSection(List<dynamic> genres) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Géneros', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: genres.length,
            itemBuilder: (context, index) {
              final genre = genres[index];
              final isSelected = genre == _selectedGenre;

              return GestureDetector(
                onTap: () => _onGenreSelected(genre),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.green : Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    genre,
                    style: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
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
        child: Text('No se encontraron canciones para este género.'),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.all(8.0),
          child: Text('Canciones', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
        ),
        ListView.builder(
          physics: const NeverScrollableScrollPhysics(),
          shrinkWrap: true,
          itemCount: songs.length,
          itemBuilder: (context, index) {
            final song = songs[index];
            final imageUrl = (song['album']['images'] as List).isNotEmpty
                ? song['album']['images'][0]['url']
                : null;
            final name = song['name'];
            final artists = (song['artists'] as List).map((a) => a['name']).join(', ');
            final externalUrl = song['external_urls']['spotify'] ?? '';

            return ListTile(
              leading: imageUrl != null
                  ? Image.network(imageUrl, width: 50, height: 50, fit: BoxFit.cover)
                  : const Icon(Icons.music_note),
              title: Text(name),
              subtitle: Text(artists),
              onTap: () => _openSpotifySong(externalUrl),
            );
          },
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Spotify Clone'),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FutureBuilder<List<dynamic>>(
              future: _newReleasesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error al cargar nuevos lanzamientos: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay nuevos lanzamientos disponibles.'),
                  );
                }

                return _buildNewReleasesSection(snapshot.data!);
              },
            ),
            FutureBuilder<List<dynamic>>(
              future: _genresFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const LinearProgressIndicator();
                } else if (snapshot.hasError) {
                  return Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text('Error al cargar géneros: ${snapshot.error}'),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Text('No hay géneros disponibles.'),
                  );
                }

                return _buildGenresSection(snapshot.data!);
              },
            ),
            if (_selectedGenre != null)
              FutureBuilder<List<dynamic>>(
                future: _songsByGenreFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text('Error al cargar canciones: ${snapshot.error}'),
                    );
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text('No hay canciones para este género.'),
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
