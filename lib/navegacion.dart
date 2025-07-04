import 'package:flutter/material.dart';
import 'principal.dart';
import 'buscador.dart';
import 'descubrimiento.dart';
import 'perfil.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.purpleAccent,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.radio_outlined), label: 'Descubre'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),

        ],
      ),
    );
  }
}
