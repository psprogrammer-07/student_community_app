import 'package:flutter/material.dart';
import 'package:rmk_community/sections/dart_section.dart';


PopupMenuButton menubar(String myname,BuildContext context){
  return
    PopupMenuButton<String>(

      onSelected: (String value) {

        
          Navigator.push(context, MaterialPageRoute(builder: (context) => DartSection(section_name: value, myName: myname),));
      
      
      },
      itemBuilder: (BuildContext context) {
        return {"dart",'python','c++','c','c#','java',}.map((String choice) {
          return PopupMenuItem<String>(

            value: choice,
            child:  Column(
              children: [
                SizedBox(height: 20,),
                Row(
                  children: [

                    Material(
                      borderRadius: BorderRadius.circular(1000),
                      clipBehavior: Clip.antiAlias,
                      child: Container(
                          width: 40,
                          height: 40,
                          child: Image(image:AssetImage("local_icons/${choice}_logo.png"),
                            fit: BoxFit.fill,
                          )
                      ),
                    ),
                    const SizedBox(width: 20,),
                    Text(choice),
                  ],

                ),
              ],
            ),
          );
        }).toList();
      },
    );
}


