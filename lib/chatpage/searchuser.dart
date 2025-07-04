import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rmk_community/chatpage/chat_page.dart';

Widget searchuser(
    String friendname, String myname, String searchQuery, BuildContext context, String pic_url) {
  // Function to build text with highlighted search query
  RichText buildHighlightedText(String text, String query) {
    if (query.isEmpty) {
      return RichText(
        text: TextSpan(
          text: text,
          style: GoogleFonts.nunito(
            color: Colors.white54,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      );
    }

    final matches = text.toLowerCase().split(query.toLowerCase());
    final List<TextSpan> spans = [];

    int startIndex = 0;
    for (var i = 0; i < matches.length; i++) {
      if (i > 0) {
        spans.add(TextSpan(
          text: text.substring(startIndex, startIndex + query.length),
          style: GoogleFonts.nunito(
            color: Colors.yellow, // Highlight color
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ));
        startIndex += query.length;
      }

      spans.add(TextSpan(
        text: matches[i],
        style: GoogleFonts.nunito(
          color: Colors.white54,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ));
      startIndex += matches[i].length;
    }

    return RichText(
      text: TextSpan(children: spans),
    );
  }

  return Container(
    padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20), // Padding for spacing
    margin: const EdgeInsets.symmetric(vertical: 5), // Margin for spacing between containers
    decoration: BoxDecoration(
      color: Colors.white10,
      borderRadius: BorderRadius.circular(15),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.1),
          blurRadius: 5,
          spreadRadius: 1,
        ),
      ],
    ),
    child: Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(50),
          child: Image.network(
            pic_url,
            width: 60,
            height: 60,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 15),
        Expanded(
          child: buildHighlightedText(friendname, searchQuery),
        ),
        IconButton(
          onPressed: () {
            checkAndAddUser(myname, friendname, context);
          },
          icon: Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ],
    ),
  );
}

Future<void> checkAndAddUser(String myname, String friendname, BuildContext context) async {
  String forwardDocName = "${myname}__|__${friendname}";
  String reverseDocName = "${friendname}__|__${myname}";

  CollectionReference chatData = FirebaseFirestore.instance.collection('chat_data');

  DocumentSnapshot forwardDoc = await chatData.doc(forwardDocName).get();
  DocumentSnapshot reverseDoc = await chatData.doc(reverseDocName).get();

  if (myname == friendname) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Your name cannot be added (This is Your Username)")),
    );
    return;
  }

  if (forwardDoc.exists || reverseDoc.exists) {
   
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("This user is already added")),
    );
  } else {
    await chatData.doc(forwardDocName).set({
      'null': null,
    });
    deleteMessage("null", forwardDocName);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("User added successfully")),
    );
  }
}

