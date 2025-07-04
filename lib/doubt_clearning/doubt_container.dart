import 'package:flutter/material.dart';
import 'package:rmk_community/doubt_clearning/doubt_comments.dart';
import 'package:rmk_community/firestone_storage/insert_firestone_data.dart';

Widget doubt_container(BuildContext context, String question, String name, String myname) {
  void showDeleteConfirmationDialog(BuildContext context, String collectionName, String documentId) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Deletion'),
          content: const Text('Do you want to delete your doubt question?'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Delete'),
              onPressed: () async {
                await deleteDocument(collectionName, documentId);
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
          ],
        );
      },
    );
  }

  return Column(
    children: [
      const SizedBox(height: 20),
      Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          minHeight: 100,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color.fromRGBO(198, 198, 198, 0.1),
        ),
        child: Column(
          children: [
            SizedBox(height: 10),
            Container(
              alignment: Alignment.topRight,
              padding: const EdgeInsets.only(left: 10, right: 20, top: 2),
              child: Text('~$name', style: const TextStyle(fontSize: 20)),
            ),
            Container(
              padding: EdgeInsets.all(10),
              child: Column(
                children: [
                  Text(
                    question,
                    style: const TextStyle(fontSize: 20, color: Colors.white),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoubtComments(question: question, name: name, myname: myname),
                        ),
                      );
                    },
                    icon: const Icon(Icons.comment),
                  ),
                ),
                Container(
                  child: (name == myname)
                      ? TextButton(
                    onPressed: () {
                      showDeleteConfirmationDialog(context, 'doubt_time', name);
                    },
                    child: const Text(
                      "Delete",
                      style: TextStyle(fontSize: 18, color: Colors.red),
                    ),
                  )
                      : Container(),
                ),
              ],
            ),
          ],
        ),
      ),
    ],
  );
}
