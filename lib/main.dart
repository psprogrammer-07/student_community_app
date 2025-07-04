import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:rmk_community/chatpage/ui_for_files.dart';
import 'package:rmk_community/homepage.dart';
import 'package:rmk_community/login.dart';

// color: Color.fromRGBO(198, 198, 198, 0.1),
//what the fuck
Future main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo00000',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home:  AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData) {
          // User is logged in, retrieve username
          return FutureBuilder<String?>(
            future: getUsernameFromFirestore(snapshot.data!.email),
            builder: (context, usernameSnapshot) {
              if (usernameSnapshot.connectionState == ConnectionState.waiting) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              if (usernameSnapshot.hasData) {

                return Homepage(myname: usernameSnapshot.data!);
                //return ChatScreen(myName: "dinesh" , friendName: "manoj");
               // return AddUser(myname: 'manoj',);
              } else {
                // User not found in Firestore
                return LoginScreen();
                return const Scaffold(
                  body: Center(child: Text('Error: Username not found')),
                );
              }
            },
          );
        } else {
          // User is not logged in, navigate to login screen
          return const LoginScreen();
        }
      },
    );
  }

  Future<String?> getUsernameFromFirestore(String? email) async {
    if (email == null) {
      return null; // Return null if email is null
    }
    try {

      QuerySnapshot<Map<String, dynamic>> querySnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      // If user found, return the username
      if (querySnapshot.docs.isNotEmpty) {
        return querySnapshot.docs.first['username'];
      } else {
        // User not found
        return null;
      }
    } catch (e) {
      print('Error retrieving username: $e');
      return null;
    }
  }
}

