import 'dart:ui';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'services/spotify_api.dart';
import 'services/favoritoService.dart';

class Buscador extends StatefulWidget {
  const Buscador({Key? key}) : super(key: key);

  @override
  State<Buscador> createState() => _BuscadorState();
}

class _BuscadorState extends State<Buscador> {
  final TextEditingController _controller = TextEditingController();
  final FavoritosService _favoritosService = FavoritosService(); //para fav
  Set<String> _favoritosIds = {};


  @override
  void initState() {
    super.initState();
    _cargarFavoritos();
  }


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

  Future<void> _cargarFavoritos() async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final snapshot = await FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .get();

    final ids = snapshot.docs.map((doc) => doc.id).toSet();

    setState(() {
      _favoritosIds = ids;
    });
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

        //Ficha del artista
        if (_searchResults!['artists']['items'].isNotEmpty) ...[
          const Text(
            'Artistas',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          const SizedBox(height: 12),
          ..._searchResults!['artists']['items'].map<Widget>((artist) {
            final List genres = artist['genres'] ?? [];
            final int popularity = artist['popularity'] ?? 0;
            final int followers = artist['followers']?['total'] ?? 0;
            final String type = artist['type'] ?? 'artista';

            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              color: Colors.white.withOpacity(0.15), // ← fondo translúcido
              elevation: 6,
              shadowColor: Colors.black45,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                      : const Icon(Icons.person, size: 50, color: Colors.white),
                ),
                title: Text(
                  artist['name'],
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(' • Popularidad: $popularity/100', style: TextStyle(color: Colors.white70)),
                    if (genres.isNotEmpty)
                      Text(' • Géneros(s):  ${genres.join(', ')}', style: TextStyle(color: Colors.white70)),
                    Text(' • Seguidores: $followers', style: TextStyle(color: Colors.white70)),
                    Text(' • Tipo: $type', style: TextStyle(color: Colors.white70)),
                  ],
                ),
                onTap: () {
                  // Aquí abrimos el perfil oficial del artista en Spotify
                  final url = artist['external_urls']?['spotify'];
                  if (url != null) {
                    _openSpotifyUrl(url);
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('No se encontró el perfil del artista')),
                    );
                  }
                },
              ),
            );
          }),
          const Divider(color: Colors.white70),
        ],


        //Albunes del artista
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
                  onTap: () => _playFirstTrackOfAlbum(album['id']),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Stack(
                      children: [
                        // Fondo borroso con traslucidez y borde
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(46, 8, 84, 0.4),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                            ),
                          ),
                        ),
                        // Contenido sobre el fondo borroso
                        Column(
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
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      album['name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _favoritosIds.contains(album['id']) ? Icons.favorite : Icons.favorite_border,
                                      color: _favoritosIds.contains(album['id']) ? Colors.red : Colors.white,
                                    ),
                                    onPressed: () async {
                                      final albumId = album['id'];
                                      final albumName = album['name'];
                                      final albumImage = (album['images'] as List).isNotEmpty
                                          ? album['images'][0]['url']
                                          : '';

                                      final albumArtist = album['artists'] != null && (album['artists'] as List).isNotEmpty
                                          ? album['artists'][0]['name']
                                          : 'Desconocido';

                                      if (_favoritosIds.contains(albumId)) {
                                        try {
                                          final uid = FirebaseAuth.instance.currentUser?.uid;
                                          if (uid != null) {
                                            await FirebaseFirestore.instance
                                                .collection('usuarios')
                                                .doc(uid)
                                                .collection('favoritos')
                                                .doc(albumId)
                                                .delete();
                                            setState(() {
                                              _favoritosIds.remove(albumId);
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al eliminar favorito: $e')),
                                          );
                                        }
                                      } else {
                                        try {
                                          await _favoritosService.agregarAFavoritos(
                                            id: albumId,
                                            tipo: 'album',
                                            nombre: albumName,
                                            artista: albumArtist,
                                            genero: '',
                                            imagen: albumImage,
                                          );
                                          setState(() {
                                            _favoritosIds.add(albumId);
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al guardar favorito: $e')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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

        //canciones mas escuchadas
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
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        children: [
                          // Fondo borroso
                          BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(46, 8, 84, 0.4), // violeta traslúcido
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                            ),
                          ),
                          // Contenido encima del fondo blur
                          Column(
                            children: [
                              ClipRRect(
                                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                                child: (track['album']['images'] as List).isNotEmpty
                                    ? Image.network(
                                  track['album']['images'][0]['url'],
                                  height: 140,
                                  width: 160,
                                  fit: BoxFit.cover,
                                )
                                    : const Icon(Icons.music_note, size: 100),
                              ),
                              /*Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                  track['name'],
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ), */
                              // El padding incluye seleccionar favoritos
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        track['name'],
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(color: Colors.white),
                                      ),
                                    ),
                                    IconButton(
                                      icon: Icon(
                                        _favoritosIds.contains(track['id']) ? Icons.favorite : Icons.favorite_border,
                                        color: _favoritosIds.contains(track['id']) ? Colors.red : Colors.white,
                                      ),
                                      onPressed: () async {
                                        final trackId = track['id'];

                                        if (_favoritosIds.contains(trackId)) {
                                          // Eliminar favorito
                                          try {
                                            final uid = FirebaseAuth.instance.currentUser?.uid;
                                            if (uid != null) {
                                              await FirebaseFirestore.instance
                                                  .collection('usuarios')
                                                  .doc(uid)
                                                  .collection('favoritos')
                                                  .doc(trackId)
                                                  .delete();
                                              setState(() {
                                                _favoritosIds.remove(trackId);
                                              });
                                            }
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al eliminar favorito: $e')),
                                            );
                                          }
                                        } else {
                                          // Agregar favorito
                                          try {
                                            await _favoritosService.agregarAFavoritos(
                                              id: trackId,
                                              tipo: 'track',
                                              nombre: track['name'],
                                              artista: track['artists'][0]['name'],
                                              genero: '',
                                              imagen: track['album']['images'][0]['url'],
                                            );
                                            setState(() {
                                              _favoritosIds.add(trackId);
                                            });
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              SnackBar(content: Text('Error al guardar favorito: $e')),
                                            );
                                          }
                                        }
                                      },
                                    )


                                  ],
                                ),
                              ),

                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const Divider(),
        ],

        //albunes
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
              children: _searchResults!['albums']['items'].map<Widget>((album) {
                return GestureDetector(
                  onTap: () => _openSpotifyUrl(album['external_urls']['spotify']),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(46, 8, 84, 0.4), // violeta traslúcido
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                            ),
                          ),
                        ),
                        Column(
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
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      album['name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _favoritosIds.contains(album['id']) ? Icons.favorite : Icons.favorite_border,
                                      color: _favoritosIds.contains(album['id']) ? Colors.red : Colors.white,
                                    ),
                                    onPressed: () async {
                                      final albumId = album['id'];
                                      final albumName = album['name'];
                                      final albumImage = (album['images'] as List).isNotEmpty
                                          ? album['images'][0]['url']
                                          : '';

                                      final albumArtist = album['artists'] != null && (album['artists'] as List).isNotEmpty
                                          ? album['artists'][0]['name']
                                          : 'Desconocido';

                                      if (_favoritosIds.contains(albumId)) {
                                        try {
                                          final uid = FirebaseAuth.instance.currentUser?.uid;
                                          if (uid != null) {
                                            await FirebaseFirestore.instance
                                                .collection('usuarios')
                                                .doc(uid)
                                                .collection('favoritos')
                                                .doc(albumId)
                                                .delete();
                                            setState(() {
                                              _favoritosIds.remove(albumId);
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al eliminar favorito: $e')),
                                          );
                                        }
                                      } else {
                                        try {
                                          await _favoritosService.agregarAFavoritos(
                                            id: albumId,
                                            tipo: 'album',
                                            nombre: albumName,
                                            artista: albumArtist,
                                            genero: '',
                                            imagen: albumImage,
                                          );
                                          setState(() {
                                            _favoritosIds.add(albumId);
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al guardar favorito: $e')),
                                          );
                                        }
                                      }
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ],
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


        //canciones
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
              children: _searchResults!['tracks']['items'].map<Widget>((track) {
                return GestureDetector(
                  onTap: () => _openSpotifyUrl(track['external_urls']['spotify']),
                  child: Container(
                    width: 160,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color.fromRGBO(46, 8, 84, 0.4), // violeta traslúcido
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withOpacity(0.2)),
                              ),
                            ),
                          ),
                        ),
                        Column(
                          children: [
                            ClipRRect(
                              borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                              child: (track['album']['images'] as List).isNotEmpty
                                  ? Image.network(
                                track['album']['images'][0]['url'],
                                height: 140,
                                width: 160,
                                fit: BoxFit.cover,
                              )
                                  : const Icon(Icons.music_note, size: 100, color: Colors.white),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      track['name'],
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _favoritosIds.contains(track['id']) ? Icons.favorite : Icons.favorite_border,
                                      color: _favoritosIds.contains(track['id']) ? Colors.red : Colors.white,
                                    ),
                                    onPressed: () async {
                                      final trackId = track['id'];

                                      if (_favoritosIds.contains(trackId)) {
                                        // Eliminar favorito
                                        try {
                                          final uid = FirebaseAuth.instance.currentUser?.uid;
                                          if (uid != null) {
                                            await FirebaseFirestore.instance
                                                .collection('usuarios')
                                                .doc(uid)
                                                .collection('favoritos')
                                                .doc(trackId)
                                                .delete();
                                            setState(() {
                                              _favoritosIds.remove(trackId);
                                            });
                                          }
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al eliminar favorito: $e')),
                                          );
                                        }
                                      } else {
                                        // Agregar favorito
                                        try {
                                          await _favoritosService.agregarAFavoritos(
                                            id: trackId,
                                            tipo: 'track',
                                            nombre: track['name'],
                                            artista: track['artists'][0]['name'],
                                            genero: '',
                                            imagen: track['album']['images'][0]['url'],
                                          );
                                          setState(() {
                                            _favoritosIds.add(trackId);
                                          });
                                        } catch (e) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            SnackBar(content: Text('Error al guardar favorito: $e')),
                                          );
                                        }
                                      }
                                    },
                                  )


                                ],
                              ),
                            ),
                          ],
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
      body: Stack(
        children: [
          Container(
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
          ),

          SafeArea(
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 30),

                  // Título animado con FadeAnimatedText
                  SizedBox(
                    height: 60,
                    child: DefaultTextStyle(
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      child: AnimatedTextKit(
                        repeatForever: true,
                        animatedTexts: [
                          FadeAnimatedText('¡Descubre tu música!'),
                          FadeAnimatedText('Reproduce tu canción'),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Campo de búsqueda
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _performSearch(),
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.2),
                        hintText: 'Buscar artista, álbum o canción',
                        hintStyle: const TextStyle(color: Colors.white70),
                        prefixIcon: const Icon(Icons.search, color: Colors.white),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                      ),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),

                  Expanded(child: _buildResults()),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
