import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class SpotifyApi extends ChangeNotifier {
  //final String clientId = 'clientId';
  //final String clientSecret = 'clientSecret';


  String? _token;
  DateTime? _tokenExpiry;

  Future<void> authenticate() async {
    if (_token != null &&
        _tokenExpiry != null &&
        DateTime.now().isBefore(_tokenExpiry!)) {
      return;
    }

    final credentials = base64Encode(utf8.encode('$clientId:$clientSecret'));
    final response = await http.post(
      Uri.parse('https://accounts.spotify.com/api/token'),
      headers: {
        'Authorization': 'Basic $credentials',
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: 'grant_type=client_credentials',
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      _token = data['access_token'];
      final expiresIn = data['expires_in']; // segundos
      _tokenExpiry = DateTime.now().add(Duration(seconds: expiresIn));
      notifyListeners();
    } else {
      throw Exception('Error authenticating with Spotify API');
    }
  }

  Future<List<dynamic>> getNewReleases() async {
    await authenticate();

    final url = Uri.parse('https://api.spotify.com/v1/browse/new-releases?country=MX&limit=20');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final albums = data['albums']['items'] as List;
      return albums;
    } else {
      throw Exception('Error al obtener nuevos lanzamientos');
    }
  }

  Future<List<dynamic>> getGenres() async {
    await authenticate();
    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/recommendations/available-genre-seeds'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['genres'] as List<dynamic>;
    } else {
      throw Exception('Error fetching genres');
    }
  }

  Future<List<dynamic>> getSongsByGenre(String genre) async {
    await authenticate();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/search?q=genre:$genre&type=track&limit=20'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['tracks']['items'] as List<dynamic>;
    } else {
      throw Exception('Error fetching songs by genre');
    }
  }

  Future<List<dynamic>> getPopularArtists({int limit = 50}) async {
    //Nota no se puede agregar mas de 50 artistas ya que no se puede
    await authenticate();

    final url = 'https://api.spotify.com/v1/search?q=a&type=artist&limit=$limit';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['artists']['items'] as List<dynamic>;
    } else {
      throw Exception('Error al obtener artistas populares');
    }
  }


  Future<List<dynamic>> getRandomPopularSongs({int limit = 50}) async {
    await authenticate();

    final query = 'a';
    final url =
        'https://api.spotify.com/v1/search?q=$query&type=track&limit=$limit';

    final response = await http.get(
      Uri.parse(url),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final tracks = data['tracks']['items'] as List<dynamic>;

      tracks.shuffle();
      return tracks;
    } else {
      throw Exception('Error al obtener canciones: ${response.statusCode}');
    }
  }


  Future<Map<String, dynamic>> search(String query) async {
    await authenticate();

    final url = Uri.parse(
        'https://api.spotify.com/v1/search?q=$query&type=artist,album,track&limit=10');
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data;
    } else {
      throw Exception('Error en búsqueda');
    }
  }

  Future<List<dynamic>> getAlbumsByArtist(String artistId) async {
    await authenticate();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId/albums?include_groups=album,single&market=MX&limit=20'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] as List<dynamic>;
    } else {
      throw Exception('Error al obtener álbumes del artista');
    }
  }

  Future<List<dynamic>> getTracksByAlbum(String albumId) async {
    final response = await http.get(Uri.parse('https://api.spotify.com/v1/albums/$albumId/tracks'), headers: {
      'Authorization': 'Bearer $_token',
    });

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'];
    } else {
      throw Exception('Error al obtener canciones del álbum');
    }
  }



  Future<List<dynamic>> getTopTracksByArtist(String artistId) async {
    await authenticate();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/artists/$artistId/top-tracks?market=MX'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['tracks'] as List<dynamic>;
    } else {
      throw Exception('Error al obtener top tracks del artista');
    }
  }


  Future<List<dynamic>> getAlbumTracks(String albumId) async {
    await authenticate();

    final response = await http.get(
      Uri.parse('https://api.spotify.com/v1/albums/$albumId/tracks'),
      headers: {'Authorization': 'Bearer $_token'},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      return data['items'] as List<dynamic>;
    } else {
      throw Exception('Error al obtener canciones del álbum');
    }
  }
}