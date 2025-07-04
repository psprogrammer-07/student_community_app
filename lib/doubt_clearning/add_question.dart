import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rmk_community/firestone_storage/insert_firestone_data.dart';

class AddQuestion extends StatefulWidget {
  final String myname;
  const AddQuestion({Key? key, required this.myname}) : super(key: key);

  @override
  State<AddQuestion> createState() => _AddQuestionState();
}

class _AddQuestionState extends State<AddQuestion> {
  TextEditingController question = TextEditingController();
  Radius ra = const Radius.circular(30);

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: const Color.fromARGB(0, 0, 0, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(0, 0, 0, 1),
      ),
      body: SingleChildScrollView(
        child: Container(
          child: Column(
            children: [
              Container(
                height: 300,
                width: double.infinity,
                child: const Image(image: AssetImage('local_icons/doubt_page_intro2.png')),
              ),
              Container(
                padding: const EdgeInsets.all(20),
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                decoration: BoxDecoration(
                  color: const Color.fromRGBO(198, 198, 198, 0.1),
                  borderRadius: BorderRadius.only(topLeft: ra, topRight: ra),
                ),
                child: Column(
                  children: [
                    TextField(
                      controller: question,
                      decoration: InputDecoration(
                        labelText: 'Enter Your Doubt',
                        labelStyle: GoogleFonts.nunito(color: Colors.white54, fontSize: 20, fontWeight: FontWeight.w900),
                      ),
                      style: GoogleFonts.nunito(color: Colors.white),
                    ),
                    SizedBox(height: screenHeight * 0.04),
                    Container(
                      alignment: Alignment.center,
                      child: TextButton(
                        onPressed: () async {
                          if (await checkDocumentExists("doubt_time", widget.myname)) {
                            showConfirmationDialog(context);
                          } else {
                            addDataToFirestore("doubt_time", widget.myname);
                          }
                        },
                        child: const Text("Submit", style: TextStyle(fontSize: 20)),
                      ),
                    )
                  ],
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<void> addDataToFirestore(String collectionName, String docName) async {
  CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
  DocumentReference document = collection.doc(docName);

  // Calculate expiration time (10 seconds from now)
  DateTime Time = DateTime.now();

  await document.set({
    'name': docName,
    'question': question.text,
    'time': Time, // Add expiration time
  }, SetOptions(merge: true));

  print('Data added to Firestore successfully');
}

  Future<bool> checkDocumentExists(String collectionName, String docName) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection(collectionName).doc(docName).get();
      return doc.exists;
    } catch (e) {
      print("Error checking document existence: $e");
      return false;
    }
  }

  void showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Confirmation"),
          content: const Text("Do you want to delete the existing question and introduce a new question?"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: const Text("No"),
            ),
            TextButton(
              onPressed: () {
                deleteDocument('doubt_time', widget.myname);
                addDataToFirestore("doubt_time", widget.myname);
                Navigator.of(context).pop();
              },
              child: const Text("Yes"),
            ),
          ],
        );
      },
    );
  }
}
