import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FavoritosService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> agregarAFavoritos({
    required String id,
    required String tipo,
    required String nombre,
    required String artista,
    required String genero,
    required String imagen,
  }) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) throw Exception('Usuario no autenticado');

    final docRef = _db
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .doc(id);

    await docRef.set({
      'id': id,
      'tipo': tipo,
      'nombre': nombre,
      'artista': artista,
      'genero': genero,
      'imagen': imagen,
      'fecha': FieldValue.serverTimestamp(),
    });
  }
}
