import 'package:flutter/material.dart';
import 'package:phone_mqtt/home_page.dart';
import 'package:phone_mqtt/provider.dart';
import 'package:phone_mqtt/settings.dart';

import 'client_ui.dart';

class Menu extends StatefulWidget {
  const Menu({super.key});

  @override
  _MenuState createState() => _MenuState();
}

class _MenuState extends State<Menu> {
  int _selectedIndex = 0;
  static const List<Widget> _widgetOptions = <Widget>[
    HomePage(),
    ClientUi(),
    Provider(),
    Settings(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: IndexedStack(
          children: const <Widget>[
            HomePage(),
            ClientUi(),
            Provider(),
            Settings(),
          ],
          index: _selectedIndex,
        ),
        //_widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Color(0xffffffff)),
            label: 'Home',
            backgroundColor: Color(0xFF3A3A3A),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me, color: Color(0xffffffff)),
            label: 'Client',
            backgroundColor: Color(0xFF3A3A3A),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share_location, color: Color(0xffffffff)),
            label: 'Provider',
            backgroundColor: Color(0xFF3A3A3A),
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.settings,
              color: Color(0xffffffff),
            ),
            label: 'Ustawienia',
            backgroundColor: Color(0xFF3A3A3A),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xffffffff),
        onTap: _onItemTapped,
      ),
    );
  }
}
