import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isPasswordVisible1 = true;
  bool isPasswordVisible2 = true;
  String indicator = '';
  bool isIndicatorGreen = false;

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
              child: Center(
                child: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ),
            ),
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sign Up',
                    style: GoogleFonts.nunito(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text('User The RealTime E-Mail Address For Use The Forget Password Feature'),
                  const SizedBox(height: 20),
                  TextField(
                    controller: usernameController,
                    decoration: InputDecoration(
                      labelText: 'User Name',
                      labelStyle: GoogleFonts.nunito(color: Colors.white54),
                    ),
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: emailController,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: GoogleFonts.nunito(color: Colors.white54),
                    ),
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: passwordController,
                    obscureText: isPasswordVisible1,
                    decoration: InputDecoration(
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible1 = !isPasswordVisible1;
                          });
                        },
                        icon: Icon(isPasswordVisible1
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                      labelText: 'Password',
                      labelStyle: GoogleFonts.nunito(color: Colors.white54),
                    ),
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: confirmPasswordController,
                    obscureText: isPasswordVisible2,
                    decoration: InputDecoration(
                      labelText: 'Confirm password',
                      labelStyle: GoogleFonts.nunito(color: Colors.white54),
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() {
                            isPasswordVisible2 = !isPasswordVisible2;
                          });
                        },
                        icon: Icon(isPasswordVisible2
                            ? Icons.visibility
                            : Icons.visibility_off),
                      ),
                    ),
                    style: GoogleFonts.nunito(color: Colors.white),
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        String result = await _signUp(
                          usernameController.text,
                          emailController.text,
                          passwordController.text,
                          confirmPasswordController.text,
                        );

                        setState(() {
                          indicator = result;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        'Sign Up',
                        style: GoogleFonts.nunito(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: Column(
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Already have an account? Sign In',
                            style: GoogleFonts.nunito(color: Colors.white54),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          indicator,
                          style: TextStyle(
                            fontSize: 15,
                            color: isIndicatorGreen ? Colors.green : Colors.red,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }




  Future<String> _signUp(String username, String email, String password,
      String confirmPassword) async {
    if (password != confirmPassword) {
      return "Check your confirm password";
    }

    if (await _isUsernameTaken(username)) {
      return "Username already exists";
    }

    RegExp emailRegExp = RegExp(r'^[a-zA-Z0-9._%+-]+@gmail\.com$');
    if (!emailRegExp.hasMatch(email)) {

      return "Use @gmail.com address";

    }

    try {
      UserCredential userCredential =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        return "The password provided is too weak";
      } else if (e.code == 'email-already-in-use') {
        return "The account already exists for that email";
      }
    } catch (e) {
      return e.toString();
    }

    if (await addUser(username, email, password)) {
      setState(() {
        isIndicatorGreen = true;
      });
      return "Successfully Signed Up";
    }

    return "Sign Up Failed";
  }

  Future<bool> _isUsernameTaken(String username) async {
    final result = await FirebaseFirestore.instance
        .collection('users')
        .where('username', isEqualTo: username)
        .get();

    return result.docs.isNotEmpty;
  }

  Future<bool> addUser(String username, String email, String password) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(username).set({
        'username': username,
        'email': email,
        'password': password,
        'Created_time': Timestamp.now(),
        'status':"new-user",
        'imageUrl':"default_profile_pic_url",
      });
      print('User added successfully!');
      return true;
    } catch (e) {
      print('Error adding user: $e');
      return false;
    }
  }
}