import 'package:flutter/material.dart';
import 'principal.dart';
import 'buscador.dart';
import 'descubrimiento.dart';

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
        selectedItemColor: Colors.purpleAccent,  // Color morado para botón seleccionado
        unselectedItemColor: Colors.grey,        // Color gris para no seleccionados
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Buscar'),
          BottomNavigationBarItem(icon: Icon(Icons.explore), label: 'Descubre'), // Nuevo botón

        ],
      ),
    );
  }
}
