import 'package:flutter/material.dart';
import 'principal.dart';
import 'buscador.dart';
import 'descubrimiento.dart';
import 'perfil.dart';
import 'favoritos.dart';


class Navegacion extends StatefulWidget {
  const Navegacion({Key? key}) : super(key: key);

  @override
  State<Navegacion> createState() => _NavegacionState();
}

class _NavegacionState extends State<Navegacion> {
  int _selectedIndex = 0;

  static final List<Widget> _widgetOptions = <Widget>[
    const Principal(),
    const Buscador(),
    const Descubrimiento(),
    const FavoritosPage(),
    const Perfil(),


  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _widgetOptions[_selectedIndex],
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4A148C).withOpacity(0.3),
              const Color(0xFF6A1B9A),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, -3),
            ),
          ],
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(8),
            topRight: Radius.circular(2),
          ),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
          child: BottomNavigationBar(
            currentIndex: _selectedIndex,
            onTap: _onItemTapped,
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.grey,
            selectedFontSize: 14,
            unselectedFontSize: 10,
            iconSize: 15,
            items: const [
              BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.search), label: 'Buscar'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.radio_outlined), label: 'Descubre'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.favorite), label: 'Favoritos'),
              BottomNavigationBarItem(
                  icon: Icon(Icons.person), label: 'Perfil'),


            ],
          ),
        ),
      ),
    );
  }

}