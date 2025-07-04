import 'package:flutter/material.dart';
import 'package:rmk_community/image_picker/set_profilepic.dart';


Widget navbar(BuildContext context,String myname,String profile_pic_url){
  return Drawer(
    child: ListView(
      children: [
        UserAccountsDrawerHeader(
            accountName: Text(myname),
            accountEmail: Text(myname+"@gmail.com"),
        currentAccountPicture: CircleAvatar(
          child: ClipOval(
            child: Image.network(profile_pic_url,
            width: 90,
            height: 90,
            fit: BoxFit.cover,
            ),
          ),
        ),
        ),
         ListTile(
           leading: Icon(Icons.image),
           title: Text("Add profile pic"),
           onTap:  () {
             pickAndUploadImage(context,myname);
           },
         )

      ],
    ),
  );
}