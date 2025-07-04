import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmk_community/iconbutton.dart';
import 'chatpage/searchuser.dart';

class AddUser extends StatefulWidget {
  final String myname;
  const AddUser({Key? key, required this.myname}) : super(key: key);

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  TextEditingController adduserController = TextEditingController();
  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Opaque black color
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 0), // Opaque black color
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(16.0), // Adding padding to the container
          child: Column(
            children: [
              const Center(
                child: Icon(Icons.person_add_alt_rounded, size: 250, color: Colors.grey),
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter Users Name...',
                        hintStyle: TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      style: TextStyle(color: Colors.white),
                      controller: adduserController,
                      onChanged: (value) {
                        setState(() {
                          searchQuery = value.toLowerCase();
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: const Icon(Icons.search),
                    color: Colors.white,
                    onPressed: () {
                      setState(() {
                        searchQuery = adduserController.text.toLowerCase();
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),
              StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance.collection('users').snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator(
                      strokeWidth: 2,
                    );
                  }
                  if (!snapshot.hasData) {
                    return const Text('No users found', style: TextStyle(color: Colors.white));
                  }

                  final users = snapshot.data!.docs.where((doc) {
                    final username = doc['username'].toString().toLowerCase();
                    return username.contains(searchQuery);
                  }).toList();

                  if (users.isEmpty) {
                    return const Text('No users found', style: TextStyle(color: Colors.white));
                  }

                  return ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: users.length,
                    itemBuilder: (context, index) {
                      var user = users[index];
                      if (user['username'].toString() == widget.myname) {
                        return Container();
                      }
                      return FutureBuilder<String?>(
                        future: getImageUrl(user["username"]),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          }
                          if (snapshot.hasError) {
                            return Text('Error: ${snapshot.error}');
                          }
                          String? imageUrl = snapshot.data;
                          return searchuser(user['username'], widget.myname, searchQuery, context, imageUrl ?? "");   
                        },
                      );
                    },
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

