import 'package:cloud_firestore/cloud_firestore.dart';


Future<void> addDataToFirestore(String collectionName, String docName, String username,String message,String myname,String repliedToMessageIdString,String url,String filename) async {
  CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
  DocumentReference document = collection.doc(docName);

  // Fetch the current document data
  DocumentSnapshot docSnapshot = await document.get();

  // Calculate the new field name
 // Map<String, dynamic>? docData = docSnapshot.data() as Map<String, dynamic>?;
  // Get the number of fields
   String messageId = '${myname}_${DateTime.now().millisecondsSinceEpoch}';



  // Prepare the new field data
  Map<String, dynamic> newData = {
    'sentby': myname,
    'message':message,
    'messageId':messageId,
    'time': Timestamp.now(),
    'type':"txt",
    'url':url,
    'filename':filename,
    'repliedToMessageId':(repliedToMessageIdString!='')?repliedToMessageIdString:null,


  };


  // Update the document with the new field
  await document.set({
    messageId: newData,
  }, SetOptions(merge: true));

  print('Data added to Firestore successfully');
}

Future<void> deleteDocument(String collectionName, String documentId) async {
  try {
    await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(documentId)
        .delete();
    print('Document successfully deleted!');
  } catch (e) {
    print('Error deleting document: $e');
  }
}



Future<List<Map<String, dynamic>>> getMessagesFromFirestore(String collectionName, String docName) async {
  CollectionReference collection = FirebaseFirestore.instance.collection(collectionName);
  DocumentReference document = collection.doc(docName);

  // Fetch the current document data
  DocumentSnapshot docSnapshot = await document.get();

  // Ensure the document exists and has data
  if (!docSnapshot.exists || docSnapshot.data() == null) {
    return []; // Return an empty list if the document doesn't exist or has no data
  }

  // Cast the document data to Map<String, dynamic>
  Map<String, dynamic> docData = docSnapshot.data() as Map<String, dynamic>;

  // Extract and sort the fields in reverse order based on the field names
  List<Map<String, dynamic>> messages = [];
  docData.entries.toList().reversed.forEach((entry) {
    // Assuming the structure is { "randomvalue": {"message": ..., "name": ..., "time": ...} }
    if (entry.value is Map<String, dynamic>) {
      Map<String, dynamic> messageData = entry.value as Map<String, dynamic>;
      messages.add(messageData);
    }
  });

  return messages;
}



Future<bool> checkDocumentExists(String collectionName, String docName) async {
  try {
    DocumentSnapshot doc = await FirebaseFirestore.instance
        .collection(collectionName)
        .doc(docName)
        .get();

    return doc.exists;
  } catch (e) {
    print("Error checking document existence: $e");
    return false;
  }
}

