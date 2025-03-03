import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:social_media_chatgpt/screens/auth/ForgotPasswordScreen.dart';
import 'package:social_media_chatgpt/screens/auth/LoginScreen.dart';
import 'package:social_media_chatgpt/screens/auth/RegisterScreen.dart';
import 'package:social_media_chatgpt/screens/home/HomeScreen.dart';
import 'package:social_media_chatgpt/screens/home/SplashScreen.dart';
import 'package:social_media_chatgpt/screens/profile/EditProfileScreen.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(), // Cambia la pantalla inicial a SplashScreen
      //initialRoute: 'home',
      routes: {
        'home': (BuildContext context) => HomeScreen(),
        'login': (BuildContext context) => LoginScreen(),
        'register': (BuildContext context) => // Define la ruta de login
            const RegisterScreen(), // Define la ruta de registro
        'forgot-password': (BuildContext context) =>
            const ForgotPasswordScreen(), //  Define la ruta de olvidaste contraseña
        'profile/edit': (BuildContext context) =>
            EditProfileScreen(), //  Define la ruta de editar perfil
      },
    );
  }
}
