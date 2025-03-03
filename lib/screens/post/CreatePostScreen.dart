import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:uuid/uuid.dart';

class CreatePostScreen extends StatefulWidget {
  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  File? _selectedFile;
  String? _fileType; // 'image' o 'video'
  bool _isLoading = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final ImagePicker _picker = ImagePicker();

  Future<void> _pickFile() async {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: Icon(Icons.image),
                  title: Text('Seleccionar Imagen'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickImage(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedFile = File(pickedFile.path);
                        _fileType = 'image';
                      });
                    }
                  },
                ),
                ListTile(
                  leading: Icon(Icons.videocam),
                  title: Text('Seleccionar Video'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile =
                        await _picker.pickVideo(source: ImageSource.gallery);
                    if (pickedFile != null) {
                      setState(() {
                        _selectedFile = File(pickedFile.path);
                        _fileType = 'video';
                      });
                    }
                  },
                ),
              ],
            ),
          );
        });
  }

  Future<void> _uploadPost() async {
    if (_selectedFile == null || _fileType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Por favor selecciona una imagen o video.')));
      return;
    }

    if (_descriptionController.text.isEmpty ||
        _locationController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Completa todos los campos.')));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final User? user = _auth.currentUser;
      if (user == null) {
        throw Exception('Usuario no autenticado.');
      }

      final String postId = Uuid().v4();
      final String fileName = '$postId.${_fileType == "image" ? "jpg" : "mp4"}';
      final Reference storageRef =
          _storage.ref().child('posts/${user.uid}/$fileName');

      await storageRef.putFile(_selectedFile!);
      final String downloadUrl = await storageRef.getDownloadURL();

      await _firestore.collection('Users').doc(user.uid).update({
        'posts': FieldValue.arrayUnion([
          {
            'postId': postId,
            'userId': user.uid,
            'url': downloadUrl,
            'description': _descriptionController.text,
            'location': _locationController.text,
            'fileType': _fileType,
            'createdAt': FieldValue.serverTimestamp(),
          }
        ])
      });

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Publicación subida con éxito.')));
      setState(() {
        _selectedFile = null;
        _descriptionController.clear();
        _locationController.clear();
      });
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear Publicación'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GestureDetector(
              onTap: _pickFile,
              child: Container(
                height: 200,
                color: Colors.grey[300],
                child: _selectedFile == null
                    ? Center(child: Text('Seleccionar Imagen o Video'))
                    : _fileType == 'image'
                        ? Image.file(_selectedFile!, fit: BoxFit.cover)
                        : Icon(Icons.videocam, size: 100),
              ),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _descriptionController,
              decoration: InputDecoration(labelText: 'Descripción'),
            ),
            SizedBox(height: 16),
            TextField(
              controller: _locationController,
              decoration: InputDecoration(labelText: 'Ubicación'),
            ),
            SizedBox(height: 16),
            _isLoading
                ? Center(child: CircularProgressIndicator())
                : ElevatedButton(
                    onPressed: _uploadPost,
                    child: Text('Subir Publicación'),
                  ),
          ],
        ),
      ),
    );
  }
}
 