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
        child: _widgetOptions.elementAt(_selectedIndex),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
            backgroundColor: Color(0xff2d1010),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.near_me),
            label: 'Client',
            backgroundColor: Color(0xff2d1010),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.share_location),
            label: 'Provider',
            backgroundColor: Color(0xff2d1010),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
            backgroundColor: Color(0xff2d1010),
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Color(0xff616161),
        onTap: _onItemTapped,
      ),
    );
  }
}
