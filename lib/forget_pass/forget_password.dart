import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';


class ForgetPassword extends StatefulWidget {
  const ForgetPassword({super.key});

  @override
  State<ForgetPassword> createState() => _ForgetPasswordState();
}

class _ForgetPasswordState extends State<ForgetPassword> {
  final TextEditingController _emailcontroller =TextEditingController();

  @override
  void dispose() {
    _emailcontroller.dispose();
    super.dispose();
  }

  Future passwordReset()async{
    try{
      await FirebaseAuth.instance.sendPasswordResetEmail(email: _emailcontroller.text.trim());
    showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(
           "The Reset Link Sent Your E-mail Check it"
          ),
        );
      }
    );
    } on FirebaseAuthException catch(e){
      print("drtyjm cfcgggggggggggggggggggggggg"+e.code);
      showDialog(context: context, builder: (context){
        return AlertDialog(
          content: Text(
            e.message.toString(),
          ),
        );
      }
      
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Container(
        child: Column(
          children: [
          Padding(
            padding: const EdgeInsets.all(9.0),
            child: Container(
              
              child: Image.asset("local_icons/forgetpass1.png",)
            
            ),
          ),
          Center(
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Text("Enter Your Realtime E-mail Address For forget your Password",
                  style:  GoogleFonts.nunito(color: Colors.white,fontWeight: FontWeight.bold),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 29),
                  child: TextField(
                      controller: _emailcontroller,
                      decoration: InputDecoration(
                        labelText: 'Email',
                        labelStyle: GoogleFonts.nunito(color: Colors.white54),
                      ),
                      style: GoogleFonts.nunito(color: Colors.white),
                    ),
                ),
                TextButton(
                  child:const  Text("Enter"),
                  onPressed: (){
                   passwordReset();
                  },
                ),
              ],
            ),
          )
          ],
        ),
      ),
    );
  }
}