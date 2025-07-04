import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rmk_community/forget_pass/forget_password.dart';
import 'package:rmk_community/homepage.dart';
import 'package:rmk_community/register.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController _emailcontroller=TextEditingController();
  TextEditingController _passwordcontroller=TextEditingController();
  bool vpass=true;
  String indicator='';
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: <Widget>[
            Container(
              height: 250,
              decoration: const BoxDecoration(
                color: Colors.black,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(50),
                  bottomRight: Radius.circular(50),
                ),
              ),
              child: const Center(
                child: Icon(
                  Icons.account_circle,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            ),
            SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Login',
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 20),
                  TextField(
                    controller: _emailcontroller,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.nunito(color: Colors.white54),
                    ),
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                const  SizedBox(height: 20),
                  TextField(
                    controller: _passwordcontroller,
                    obscureText: vpass,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(onPressed: () {
                                 setState(() {
                                   vpass=!vpass;
                                 });
                      },icon: Icon(vpass?Icons.visibility:Icons.visibility_off),),
                      labelText: 'Password',
                      labelStyle: GoogleFonts.nunito(color: Colors.white54),
                    ),
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 3),
                    alignment: Alignment.centerRight,
                    child:TextButton(
                      child: const Text("Forget Password?",style: TextStyle(color: Colors.white,fontWeight: FontWeight.w400),),
                      onPressed: (){
                       Navigator.push(context,MaterialPageRoute(builder: (context) => const ForgetPassword(),));
                      },
                    ) ,
                  ),
             
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {

                             setState(() async{
                               indicator =await _signIn();
                             });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                          'Login',
                          style: GoogleFonts.nunito(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),

                    ),
                  ),
                  SizedBox(height: 20),
                  Center(
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => RegisterPage()),
                        );
                      },
                      child: Text(
                        "Don't have any account? Sign Up",
                        style: GoogleFonts.nunito(color: Colors.white54),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10,),
                  Center(child: Text(indicator,style:const TextStyle(fontSize: 15,color: Colors.red),)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  Future<String> _signIn() async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailcontroller.text,
        password: _passwordcontroller.text,
      );

      // Retrieve username from Firestore
      String? username = await getUsernameFromFirestore(_emailcontroller.text);

      // Navigate to the home screen
      if (username != null) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => Homepage(myname: username)),
        );
      } else {
        // Handle error if username is not found
        return('Error: Username not found');
      }

        return "";// Return true if login is successful
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {

        return('No user found for that email.');
      } else if (e.code.contains('wrong-password')) {
        return('Wrong password provided.');
      }

      return 'login failed'; // Return false if login fails
    }
  }

  Future<String?> getUsernameFromFirestore(String email) async {
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

