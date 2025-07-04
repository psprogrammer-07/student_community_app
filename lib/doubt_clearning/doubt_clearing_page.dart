import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:rmk_community/doubt_clearning/add_question.dart';
import 'doubt_container.dart';

class Doubt_clear extends StatefulWidget {
  final String myname;
  const Doubt_clear({Key? key, required this.myname}) : super(key: key);

  @override
  State<Doubt_clear> createState() => _Doubt_clearState();
}

class _Doubt_clearState extends State<Doubt_clear> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 0, 0, 1),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 0, 0, 1),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('doubt_time')
            .orderBy('time', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            print('Error: ${snapshot.error}');
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final doubts = snapshot.data?.docs ?? [];
          print('Number of documents: ${doubts.length}');

          if (doubts.isEmpty) {
            return const Center(child: Text('No doubts available.'));
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  height: 300,
                  width: double.infinity,
                  child: const Image(
                    image: AssetImage('local_icons/doubt_page_intro2.png'),
                  ),
                ),
                ...doubts.map((doubt) {
                  final data = doubt.data() as Map<String, dynamic>?;

                  if (data == null) {
                    print('Document with null data: ${doubt.id}');
                    return const Center(child: Text('No data available'));
                  }

                  final String name = data['name'] ?? 'No name';
                  final String question = data['question'] ?? 'No question';
                  final Timestamp time = data['time'] ?? Timestamp.now();

                  print('Document ID: ${doubt
                      .id}, Name: $name, Question: $question, Time: $time');

                  return doubt_container(
                      context,
                      question,
                      name,
                    widget.myname
                  );
                }).toList(),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => AddQuestion(myname: widget.myname),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String convertToShortTime(Timestamp timestamp) {
    // Convert Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Define the output format
    final outputFormat = DateFormat("h:mm a");

    // Format the DateTime to the desired output format
    final outputString = outputFormat.format(dateTime);

    return outputString;
  }

}