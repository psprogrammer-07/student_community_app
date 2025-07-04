import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rmk_community/chatpage/chat_page.dart';
import 'package:rmk_community/sections/dart_section.dart';
import 'doubt_clearning/doubt_clearing_page.dart';


Widget circularIconButton(BuildContext context, String imagePath,String myname,String page) {
  return Material(
    borderRadius: BorderRadius.circular(1000),
    clipBehavior: Clip.antiAlias,
    child: Container(
      width: 100,
      height: 100,
      decoration:const BoxDecoration(
        shape: BoxShape.circle,
      ),
      child: TextButton(
        child: Image.asset(
          imagePath,
          fit: BoxFit.fill,
        ),
        onPressed: () {
          if(page=="Doubt_clear"){ 
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => Doubt_clear(myname: myname,)),
          );
          }
          else{
            Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => DartSection(section_name: page, myName:myname),
          ));
          }

        },
      ),
    ),
  );
}

Widget persons(String friendName, String myname, context, String profilepic_url, int unread_message,String m_docid) {
  print("form person1:"+m_docid);
  return ListTile(
    contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
    title: Row(
      children: [
        Material(
          borderRadius: BorderRadius.circular(1000),
          clipBehavior: Clip.antiAlias,
          child: Container(
            width: 50,
            height: 50,
            child: Image.network(
              profilepic_url,
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: 10,),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                friendName,
                style: GoogleFonts.nunito(
                  color: Colors.white54,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
              if (unread_message > 0)
                Text(
                  '$unread_message unread messages',
                  style: TextStyle(color: Colors.redAccent, fontSize: 12),
                ),
            ],
          ),
        ),
        IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatScreen(myName: myname, friendName: friendName,docname: m_docid,),
              ),
            );
          },
          icon: Icon(Icons.chat_bubble_outline),
        ),
      ],
    ),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(myName: myname, friendName: friendName,docname: m_docid,),
        ),
      );
    },
  );
  
}


Future<String> getImageUrl(String username) async {
  const String def_profile_pic="default_profile_pic_url";
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('users').doc(username).get();
    if (doc.exists && doc.data() != null) {
      var data = doc.data() as Map<String, dynamic>;
      return data['imageUrl'];
    } else {
      print('Document does not exist or has no data');
      return def_profile_pic;
    }
  } catch (e) {
    print('Error fetching image URL: $e');
    return def_profile_pic;
  }
  
}