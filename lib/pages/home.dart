import 'package:flutter/material.dart';
import 'package:green_pill/models/menu_action.dart';
import 'package:green_pill/pages/chatlist.dart';
import 'package:green_pill/pages/settings.dart';
import 'package:green_pill/service/matrix_service.dart';
import 'package:provider/provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  int _currentPageIndex = 0; // For bottom navigation at the Moment unused

  final List<MenuAction> _menuActions = [
    MenuAction(
      label: 'Settings',
      icon: Icons.settings,
      onTap: (context) {
        Navigator.push(context, MaterialPageRoute(builder: (context) => SettingsPage()));
      },
      children: Row(
        children: [
          Icon(Icons.settings),
          SizedBox(width: 8),
          Text('Settings'),
        ],
      ),
    ),
    MenuAction(
      label: 'Logout',
      icon: Icons.logout,
      onTap: (context) {
        context.read<MatrixService>().logout();
      },
      children: Row(
        children: [
          Icon(Icons.logout),
          SizedBox(width: 8),
          Text('Logout'),
        ],
      ),
    ),
  ];

  @override
  Widget build(BuildContext context) { 
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
        actions: [
          PopupMenuButton<String>(
            itemBuilder: (BuildContext context) => _menuActions.map((action) => PopupMenuItem<String>(
              value: action.id,
              child: action.children,
              onTap: () => action.onTap(context),
            )).toList(),
          ),
        ],
      ),
      body: <Widget>[
        const ChatListPage(),
      ][_currentPageIndex],
      /*Just for maybe later use of a bottom navigation bar for switching between private messages and spaces
      
      bottomNavigationBar: NavigationBar(
        onDestinationSelected: (value) => {
          setState(() {
            _currentPageIndex = value;
          })
        },
        selectedIndex: _currentPageIndex,
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.messenger_sharp),
            label: 'Chats',
          ),
          NavigationDestination(
            icon: const Icon(Icons.sensor_door),
            label: 'Settings',
          ),
        ],
      ),*/
    );
  }
}