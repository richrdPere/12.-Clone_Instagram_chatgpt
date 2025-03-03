import 'package:flutter/material.dart';
import 'package:social_media_chatgpt/screens/feed/FeedScreen.dart';
import 'package:social_media_chatgpt/screens/post/CreatePostScreen.dart';
import 'package:social_media_chatgpt/screens/post/PostScreen.dart';
import 'package:social_media_chatgpt/screens/profile/ProfileScreen.dart';
import 'package:social_media_chatgpt/screens/search/SearchScreen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  // Lista de widgets que representan las pantallas
  final List<Widget> _screens = [
    const Center(
      child: FeedScreen(),
    ), // Feed
    const Center(
      child: SearchScreen(),
    ), // Búsqueda
    Center(
      child: CreatePostScreen(),
    ), // Publicaciones
    const Center(
      child: ProfileScreen(),
    ), // Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // title: const Text(
        //   'Instagram Clone',
        //   style: TextStyle(
        //     fontFamily: 'Roboto',
        //     fontWeight: FontWeight.bold,
        //     fontSize: 24,
        //   ),
        // ),
        title: Image.asset(
          'assets/img/instaclone.png', // Cambia por la ruta de tu logo
          height: 50,
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        centerTitle: true,
      ),
      body: _screens[_currentIndex], // Muestra la pantalla seleccionada
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Feed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search_outlined),
            activeIcon: Icon(Icons.search),
            label: 'Buscar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_box_outlined),
            activeIcon: Icon(Icons.add_box),
            label: 'Publicar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Perfil',
          ),
        ],
      ),
    );
  }
}
