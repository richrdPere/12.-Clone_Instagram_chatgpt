import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:geolocator/geolocator.dart';

class PostScreen extends StatefulWidget {
  const PostScreen({super.key});

  @override
  State<PostScreen> createState() => _PostScreenState();
}

class _PostScreenState extends State<PostScreen> {
  File? _mediaFile;
  String? _mediaUrl;
  VideoPlayerController? _videoController;
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  FocusNode _focusNode = FocusNode();

  /// Permite al usuario seleccionar una imagen o un video desde la galería
  Future<void> _pickMedia(bool isVideo) async {
    final pickedFile = await ImagePicker().pickMedia();
    if (pickedFile != null) {
      setState(() {
        _mediaFile = File(pickedFile.path);
        if (pickedFile.path.endsWith("mp4")) {
          _videoController = VideoPlayerController.file(_mediaFile!)
            ..initialize().then((_) {
              setState(() {});
            });
        }
      });
    }
  }

  /// Obtiene la ubicación actual del usuario
  Future<void> _getCurrentLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      _locationController.text = "${position.latitude}, ${position.longitude}";
    });
  }

  /// Sube el archivo seleccionado a Firebase Storage y obtiene la URL de descarga
  Future<void> _uploadMedia() async {
    if (_mediaFile == null) return;
    String userId = _auth.currentUser!.uid;
    String fileType = _mediaFile!.path.endsWith("mp4") ? "videos" : "images";
    Reference ref = _storage
        .ref()
        .child('$fileType/$userId/${DateTime.now().millisecondsSinceEpoch}');
    await ref.putFile(_mediaFile!);
    String downloadUrl = await ref.getDownloadURL();
    setState(() {
      _mediaUrl = downloadUrl;
    });
  }

  /// Guarda la publicación en Firestore con la información del usuario
  Future<void> _savePost() async {
    if (_mediaUrl == null) return;
    String userId = _auth.currentUser!.uid;
    await _firestore.collection('posts').add({
      'userId': userId,
      'mediaUrl': _mediaUrl,
      'description': _descriptionController.text.trim(),
      'location': _locationController.text.trim(),
      'timestamp': FieldValue.serverTimestamp(),
    });
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text('Publicación subida')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Nueva Publicación'),
        actions: [
          IconButton(
            icon: Icon(Icons.upload),
            onPressed: () async {
              await _uploadMedia();
              _savePost();
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: () => _pickMedia(false),
              child: Container(
                height: 200,
                width: double.infinity,
                color: Colors.grey[300],
                child: _mediaFile != null
                    ? (_mediaFile!.path.endsWith("mp4")
                        ? _videoController!.value.isInitialized
                            ? AspectRatio(
                                aspectRatio:
                                    _videoController!.value.aspectRatio,
                                child: VideoPlayer(_videoController!),
                              )
                            : Icon(Icons.videocam, size: 100)
                        : Image.file(_mediaFile!, fit: BoxFit.cover))
                    : Icon(Icons.add_a_photo, size: 100),
              ),
            ),
            SizedBox(height: 16),
            TextField(
                controller: _descriptionController,
                focusNode: _focusNode, // Asegura que reciba foco
                keyboardType: TextInputType.text,
                obscureText: true,
                decoration: InputDecoration(labelText: 'Descripción')),
            TextField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Ubicación')),
            ElevatedButton(
                onPressed: _getCurrentLocation,
                child: Text("Obtener Ubicación")),
          ],
        ),
      ),
    );
  }
}
