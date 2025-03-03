import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  String? _imageUrl;
  File? _imageFile;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  /// Carga los datos del usuario desde Firestore y los asigna a los campos correspondientes
  Future<void> _loadUserData() async {
    String userId = _auth.currentUser!.uid;
    DocumentSnapshot userDoc =
        await _firestore.collection('Users').doc(userId).get();

    if (userDoc.exists) {
      setState(() {
        _nameController.text = userDoc['name'] ?? '';
        _lastNameController.text = userDoc['lastName'] ?? '';
        _bioController.text = userDoc['bio'] ?? '';
        _phoneController.text = userDoc['phone'] ?? '';
        _imageUrl = userDoc['profileImage'] ?? '';
      });
    }
  }

  /// Permite al usuario seleccionar una imagen desde la galería
  Future<void> _pickImage() async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
      _uploadImage();
    }
  }

  /// Sube la imagen seleccionada a Firebase Storage y actualiza la URL en Firestore
  Future<void> _uploadImage() async {
    if (_imageFile == null) return;
    String userId = _auth.currentUser!.uid;
    Reference ref = _storage.ref().child('profileImages/$userId.jpg');
    await ref.putFile(_imageFile!);
    String downloadUrl = await ref.getDownloadURL();
    setState(() {
      _imageUrl = downloadUrl;
    });
    await _firestore
        .collection('Users')
        .doc(userId)
        .update({'profileImage': downloadUrl});
  }

  /// Guarda los datos del perfil del usuario en Firestore
  Future<void> _saveProfile() async {
    String userId = _auth.currentUser!.uid;
    await _firestore.collection('Users').doc(userId).update({
      'name': _nameController.text.trim(),
      'lastName': _lastNameController.text.trim(),
      'bio': _bioController.text.trim(),
      'phone': _phoneController.text.trim(),
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Perfil actualizado')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Editar Perfil'),
        actions: [
          IconButton(
            icon: Icon(Icons.check),
            onPressed: _saveProfile,
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundImage: _imageUrl != null
                    ? NetworkImage(_imageUrl!)
                    : AssetImage('assets/default_avatar.png') as ImageProvider,
                child: Icon(Icons.camera_alt, size: 30, color: Colors.white70),
              ),
            ),
            SizedBox(height: 16),
            TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Nombre')),
            TextField(
                controller: _lastNameController,
                decoration: InputDecoration(labelText: 'Apellido')),
            TextField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Biografía')),
            TextField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Teléfono')),
          ],
        ),
      ),
    );
  }
}
