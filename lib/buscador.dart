import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'services/spotify_api.dart';

class Buscador extends StatefulWidget {
  const Buscador({Key? key}) : super(key: key);

  @override
  State<Buscador> createState() => _BuscadorState();
}

class _BuscadorState extends State<Buscador> {
  final TextEditingController _controller = TextEditingController();
  Map<String, dynamic>? _searchResults;
  List<dynamic>? _artistAlbums;
  List<dynamic>? _artistTopTracks;
  String? _error;

  Future<void> _performSearch() async {
    final input = _controller.text.trim();
    if (input.isEmpty) return;

    try {
      final api = Provider.of<SpotifyApi>(context, listen: false);
      final results = await api.search(input);

      final exactArtists = (results['artists']['items'] as List)
          .where((artist) =>
      artist['name'].toString().toLowerCase() == input.toLowerCase())
          .toList();

      final exactAlbums = (results['albums']['items'] as List)
          .where((album) =>
      album['name'].toString().toLowerCase() == input.toLowerCase())
          .toList();

      final exactTracks = (results['tracks']['items'] as List)
          .where((track) =>
      track['name'].toString().toLowerCase() == input.toLowerCase())
          .toList();

      if (exactArtists.isNotEmpty) {
        final artistId = exactArtists[0]['id'];
        _artistAlbums = await api.getAlbumsByArtist(artistId);
        _artistTopTracks = await api.getTopTracksByArtist(artistId);
      } else {
        _artistAlbums = null;
        _artistTopTracks = null;
      }

      setState(() {
        _searchResults = {
          'artists': {'items': exactArtists},
          'albums': {'items': exactAlbums},
          'tracks': {'items': exactTracks},
        };
        _error = null;
      });
    } catch (e) {
      setState(() {
        _error = 'Error en la búsqueda: $e';
      });
    }
  }

  void _openSpotifyUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir Spotify')),
      );
    }
  }

  Future<void> _playFirstTrackOfAlbum(String albumId) async {
    try {
      final api = Provider.of<SpotifyApi>(context, listen: false);
      final tracks = await api.getTracksByAlbum(albumId);
      if (tracks.isNotEmpty) {
        final firstTrackUrl = tracks[0]['external_urls']['spotify'];
        _openSpotifyUrl(firstTrackUrl);
      }
    } catch (e) {
      setState(() {
        _error = 'Error al reproducir la canción: $e';
      });
    }
  }

  Widget _buildResults() {
    if (_error != null) {
      return Center(child: Text(_error!));
    }

    if (_searchResults == null) {
      return const Center(child: Text(' '));
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_searchResults!['artists']['items'].isNotEmpty) ...[
          const Text(
            'Artistas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          ..._searchResults!['artists']['items'].map<Widget>((artist) {
            final List genres = artist['genres'] ?? [];
            final int popularity = artist['popularity'] ?? 0;
            final int followers = artist['followers']?['total'] ?? 0;
            final String type = artist['type'] ?? 'artista';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              elevation: 4,
              shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(12),
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: (artist['images'] as List).isNotEmpty
                      ? Image.network(
                    artist['images'][0]['url'],
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                      : const Icon(Icons.person, size: 50),
                ),
                title: Text(artist['name'],
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(' • Popularidad: $popularity/100'),
                    if (genres.isNotEmpty)
                      Text(' • Géneros(s):  ${genres.join(', ')}'),
                    Text(' • Seguidores: $followers'),
                    Text(' • Tipo: $type'),
                  ],
                ),
                onTap: () {
                  // Al tocar un artista, reproducimos la primera canción del primer álbum (si existe)
                  if (_artistAlbums != null && _artistAlbums!.isNotEmpty) {
                    _playFirstTrackOfAlbum(_artistAlbums![0]['id']);
                  }
                },
              ),
            );
          }),
          const Divider(),
        ],

        // ÁLBUMES DEL ARTISTA
        // ÁLBUMES DEL ARTISTA
        if (_artistAlbums != null && _artistAlbums!.isNotEmpty) ...[
          const Text(
            'Álbumes del artista',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _artistAlbums!.map<Widget>((album) {
                return GestureDetector(
                  onTap: () => _playFirstTrackOfAlbum(album['id']), // <- CAMBIO AQUÍ
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E0854),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                          child: (album['images'] as List).isNotEmpty
                              ? Image.network(
                            album['images'][0]['url'],
                            height: 140,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.album, size: 100),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            album['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
        ],


        if (_artistTopTracks != null && _artistTopTracks!.isNotEmpty) ...[
          const Text(
            'Canciones más escuchadas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _artistTopTracks!.map<Widget>((track) {
                return GestureDetector(
                  onTap: () => _openSpotifyUrl(track['external_urls']['spotify']),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E0854),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                          child: (track['album']['images'] as List).isNotEmpty
                              ? Image.network(
                            track['album']['images'][0]['url'],
                            height: 140,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.music_note, size: 100),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            track['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
        ],

        if (_searchResults!['albums']['items'].isNotEmpty) ...[
          const Text(
            'Álbumes',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
              _searchResults!['albums']['items'].map<Widget>((album) {
                return GestureDetector(
                  onTap: () => _openSpotifyUrl(album['external_urls']['spotify']),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E0854),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                          child: (album['images'] as List).isNotEmpty
                              ? Image.network(
                            album['images'][0]['url'],
                            height: 140,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.album, size: 100),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            album['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
        ],

        if (_searchResults!['tracks']['items'].isNotEmpty) ...[
          const Text(
            'Canciones',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children:
              _searchResults!['tracks']['items'].map<Widget>((track) {
                return GestureDetector(
                  onTap: () => _openSpotifyUrl(track['external_urls']['spotify']),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFF2E0854),
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          blurRadius: 6,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        ClipRRect(
                          borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(16)),
                          child: (track['album']['images'] as List).isNotEmpty
                              ? Image.network(
                            track['album']['images'][0]['url'],
                            height: 140,
                            width: 160,
                            fit: BoxFit.cover,
                          )
                              : const Icon(Icons.music_note, size: 100),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Text(
                            track['name'],
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Buscador'),
        centerTitle: true,
        backgroundColor: const Color(0xFF6C43AB),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: TextField(
              controller: _controller,
              onSubmitted: (_) => _performSearch(),
              decoration: InputDecoration(
                hintText: 'Buscar artista, álbum o canción',
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _performSearch,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          Expanded(child: _buildResults()),
        ],
      ),
    );
  }
}
