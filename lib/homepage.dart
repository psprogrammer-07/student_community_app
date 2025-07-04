import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmk_community/add_user.dart';
import 'package:rmk_community/firestone_storage/insert_firestone_data.dart';
import 'package:rmk_community/iconbutton.dart';
import 'package:rmk_community/login.dart';
import 'package:rmk_community/slidebar/homepage_sidebar.dart';
import 'package:rmk_community/slidebar/slidebar.dart';

class Homepage extends StatefulWidget {
  final String myname;

  const Homepage({Key? key, required this.myname}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with WidgetsBindingObserver {
  Future<String?> getImageUrl(String username) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(username).get();
      if (doc.exists && doc.data() != null) {
        var data = doc.data() as Map<String, dynamic>;
        return data["imageUrl"] as String?;
      } else {
        print('Document does not exist or has no data');
        return null;
      }
    } catch (e) {
      print('Error fetching image URL: $e');
      return null;
    }
  }

  Future<int> getUnreadMessageCount(String chatId, String myname) async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection('chat_data').doc(chatId).get();

    if (!documentSnapshot.exists || documentSnapshot.data() == null) {
      return 0;
    }

    Map<String, dynamic> messages = documentSnapshot.data() as Map<String, dynamic>;

    int unreadCount = 0;
    messages.forEach((key, value) {
      if (value is Map<String, dynamic>) {
        if (value['read'] == false && value['sentby'] != myname) {
          unreadCount++;
        }
      }
    });

    return unreadCount;
  }

  Future<String> determineMainPath(String myName, String friendName) async {
    String doc = '';
    if (await checkDocumentExists('chat_data', '${myName}__|__$friendName')) {
      doc = '${myName}__|__$friendName';
    }
    if (await checkDocumentExists('chat_data', '${friendName}__|__$myName')) {
      doc = '${friendName}__|__$myName';
    }
    return doc;
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      update_state(widget.myname, "online");
    } else {
      update_state(widget.myname, "offline");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: FutureBuilder<String?>(
        future: getImageUrl(widget.myname),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator(); // Show a loading indicator while waiting
          }
          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Handle error
          }
          String? imageUrl = snapshot.data;
          return navbar(context, widget.myname, imageUrl ?? "");
        },
      ),
      appBar: AppBar(
        title: Text(widget.myname),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => LoginScreen()),
              );
            },
            icon: const Icon(Icons.exit_to_app),
          ),
          menubar(widget.myname, context),
        ],
      ),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                circularIconButton(context, 'local_icons/ask_questions.png', widget.myname, "Doubt_clear"),
                circularIconButton(context, 'local_icons/web_dev.jpeg', widget.myname, "Web Development"),
                circularIconButton(context, 'local_icons/app_dev.png', widget.myname, "App Development"),
                circularIconButton(context, 'local_icons/flutter_dev.png', widget.myname, "Flutter Development"),
                circularIconButton(context, 'local_icons/machine_learning.jpeg', widget.myname, "Machine Learning"),
                circularIconButton(context, 'local_icons/deep_learning.png', widget.myname, "Deep Learning"),
                circularIconButton(context, 'local_icons/data_science_sec.png', widget.myname, "Data Science"),
                circularIconButton(context, 'local_icons/cyber_sec.png', widget.myname, "Cyber Security"),
                circularIconButton(context, 'local_icons/game_dev.png', widget.myname, "Game Development"),
              ],
            ),
          ),
          Container(
            width: double.infinity,
            height: 5,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(200),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(198, 198, 198, 0.1),
                  blurRadius: 2,
                  spreadRadius: 3,
                ),
              ],
            ),
          ),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('chat_data').snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data == null) {
                  return Center(child: Text('No data available.'));
                }

                final documents = snapshot.data!.docs;
                List<String> friendNames = [];

                for (var doc in documents) {
                  String docId = doc.id;
                  List<String> names = docId.split('__|__');
                  if (names.contains(widget.myname)) {
                    friendNames.add(names.firstWhere((name) => name != widget.myname));
                  }
                }

                return ListView.builder(
                  itemCount: friendNames.length,
                  itemBuilder: (context, index) {
                    String friendName = friendNames[index];
                    String chatId = '${widget.myname}__|__$friendName';

                    return FutureBuilder<int>(
                      future: getUnreadMessageCount(chatId, widget.myname),
                      builder: (context, unreadSnapshot) {
                        if (unreadSnapshot.connectionState == ConnectionState.waiting) {
                          return const CircularProgressIndicator();
                        }
                        if (unreadSnapshot.hasError) {
                          return Text('Error: ${unreadSnapshot.error}');
                        }
                        int unreadCount = unreadSnapshot.data ?? 0;

                        return FutureBuilder<String?>(
                          future: getImageUrl(friendName),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return CircularProgressIndicator();
                            }
                            if (snapshot.hasError) {
                              return Text('Error: ${snapshot.error}');
                            }
                            String? imageUrl = snapshot.data;
                            return update_person(friendName, imageUrl ?? "", unreadCount);
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddUser(myname: widget.myname),
            ),
          );
        },
        child: Icon(Icons.add),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget update_person(String friendName, String imageUrl, int unreadCount) {
    return FutureBuilder<String>(
      future: determineMainPath(widget.myname, friendName),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        }
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        String chatId = snapshot.data ?? '';
        print("from_update_person:" + chatId);
        return persons(friendName, widget.myname, context, imageUrl, unreadCount, chatId);
      },
    );
  }

  Future<void> update_state(String myname, String status) async {
    CollectionReference collection = FirebaseFirestore.instance.collection("users");
    DocumentReference document = collection.doc(myname);
    DocumentSnapshot docSnapshot = await document.get();
    await document.set({
      'status': status
    }, SetOptions(merge: true));

    print('Data added to Firestore successfully');
  }
}
