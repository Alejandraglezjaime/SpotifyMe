import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class FavoritosPage extends StatelessWidget {
  const FavoritosPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    if (uid == null) {
      return const Center(child: Text('Debes iniciar sesión'));
    }

    final favoritosRef = FirebaseFirestore.instance
        .collection('usuarios')
        .doc(uid)
        .collection('favoritos')
        .orderBy('fecha', descending: true);

    return Scaffold(
      extendBodyBehindAppBar: true,
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
        child: SafeArea(
          child: Column(
            children: [
              const SizedBox(height: 10),

              // Encabezado animado
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
                      FadeAnimatedText('¡TUS FAVORITOS!'),
                      FadeAnimatedText('¡TUS FAVORITOS!'),
                    ],
                  ),
                ),
              ),

              // Encabezado animado
              SizedBox(
                height: 60,
                child: DefaultTextStyle(
                  style: GoogleFonts.poppins(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  child: AnimatedTextKit(
                    repeatForever: true,
                    animatedTexts: [
                      FadeAnimatedText('Esta parte no reproduce la canción'),
                      FadeAnimatedText('Esta parte no reproduce la canción'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // Lista de favoritos expandida
              Expanded(
                child: StreamBuilder<QuerySnapshot>(
                  stream: favoritosRef.snapshots(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator(color: Colors.white));
                    }
                    final favoritos = snapshot.data!.docs;

                    if (favoritos.isEmpty) {
                      return const Center(
                        child: Text(
                          'No tienes favoritos aún',
                          style: TextStyle(color: Colors.white70, fontSize: 18),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: favoritos.length,
                      itemBuilder: (context, index) {
                        final fav = favoritos[index].data() as Map<String, dynamic>;

                        return Card(
                          color: Colors.white.withOpacity(0.15),
                          margin: const EdgeInsets.symmetric(vertical: 6),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                fav['imagen'],
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                              ),
                            ),
                            title: Text(
                              fav['nombre'],
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Text(
                              '${fav['artista']} • ${fav['genero']}',
                              style: const TextStyle(color: Colors.white70),
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: Colors.white24,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    fav['tipo'].toString().toLowerCase() == 'track' ? 'Canción' : 'Álbum',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                                  onPressed: () async {
                                    final uid = FirebaseAuth.instance.currentUser?.uid;
                                    if (uid != null) {
                                      try {
                                        await FirebaseFirestore.instance
                                            .collection('usuarios')
                                            .doc(uid)
                                            .collection('favoritos')
                                            .doc(fav['id'])
                                            .delete();

                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text('Eliminado de favoritos')),
                                        );
                                      } catch (e) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text('Error al eliminar: $e')),
                                        );
                                      }
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
