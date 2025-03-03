import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _getUserData();
  }

  // Función para obtener los datos del usuario desde Firestore
  Future<void> _getUserData() async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('Users') // Nombre de la colección
                .doc(user.uid) // ID del documento basado en FirebaseAuth
                .get();

        setState(() {
          userData = snapshot.data();
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error al obtener los datos del usuario: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  // Función para cerrar sesión
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
      Navigator.pushReplacementNamed(
          context, 'login'); // Redirige a la pantalla de login
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        title: const Text(
          'Perfil',
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: Colors.black),
          )
        ],
        centerTitle: false,
      ),
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : userData == null
              ? const Center(
                  child: Text(
                    'Error al cargar los datos del usuario.',
                    style: TextStyle(fontSize: 18),
                  ),
                )
              : Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.grey[300],
                            backgroundImage: userData!['profileImage'] != null
                                ? NetworkImage(userData!['profileImage'])
                                : null,
                            child: userData!['profileImage'] == null
                                ? const Icon(Icons.person, size: 40)
                                : null,
                          ),
                          const SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                userData!['name'] ?? 'Nombre',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                userData!['email'] ?? 'Correo electrónico',
                                style: const TextStyle(fontSize: 16),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        margin: EdgeInsets.only(left: 20),
                        width: 150,
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.pushNamed(context, 'profile/edit');
                          },
                          child: const Text(
                            'Editar',
                            style: TextStyle(color: Colors.black),
                          ),
                          style: ElevatedButton.styleFrom(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                      ),
                      //const SizedBox(height: 20),
                      const Divider(),
                      const SizedBox(height: 20),
                      const Text(
                        'Publicaciones',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Expanded(
                        child: GridView.builder(
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 5,
                            mainAxisSpacing: 5,
                            childAspectRatio: 1,
                          ),
                          itemCount: 9, // Placeholder para publicaciones
                          itemBuilder: (context, index) {
                            return Container(
                              color: Colors.grey[300],
                              child: const Center(
                                child: Icon(Icons.image, color: Colors.grey),
                              ),
                            );
                          },
                        ),
                      ),
                      // // Botón de Cerrar Sesión
                      // Padding(
                      //   padding: const EdgeInsets.only(top: 20),
                      //   child: ElevatedButton(
                      //     onPressed: _logout,
                      //     style: ElevatedButton.styleFrom(
                      //       backgroundColor: Colors.red,
                      //       padding: const EdgeInsets.symmetric(
                      //           vertical: 12, horizontal: 16),
                      //       shape: RoundedRectangleBorder(
                      //           borderRadius: BorderRadius.circular(8)),
                      //     ),
                      //     child: const Text(
                      //       'Cerrar Sesión',
                      //       style: TextStyle(fontSize: 16),
                      //     ),
                      //   ),
                      // ),
                    ],
                  ),
                ),
    );
  }
}
