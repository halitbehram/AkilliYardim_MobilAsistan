import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:todo_app1/appp/screens/home_page.dart'; // HomePage'in doğru yolu
import 'package:todo_app1/appp/screens/login_page.dart'; // LoginPage'in doğru yolu
import 'firebase_options.dart'; // Firebase yapılandırma dosyası

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Geçici olarak oturumları kapatıyoruz
  await FirebaseAuth.instance.signOut();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth App',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // Hata ayıklama için konsola durum mesajları yazdırıyoruz
        print('Connection State: ${snapshot.connectionState}');
        print('Has Data: ${snapshot.hasData}');
        print('Error: ${snapshot.error}');

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Hata: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          return const HomePage(); // Kullanıcı giriş yaptıysa HomePage
        } else {
          return const LoginPage(); // Kullanıcı giriş yapmadıysa LoginPage
        }
      },
    );
  }
}



