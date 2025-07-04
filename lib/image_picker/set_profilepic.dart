import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';



Future<void> pickAndUploadImage(BuildContext context,String myName) async {
  try {
    // Step 1: Pick an image
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return; // User canceled the picker

    File imageFile = File(pickedFile.path);

    // Step 2: Upload the image to Firebase Storage
    String fileName = '${myName}_${DateTime.now().millisecondsSinceEpoch}.jpg';
    Reference storageRef = FirebaseStorage.instance.ref().child('profile_pic/$myName/$fileName');
    UploadTask uploadTask = storageRef.putFile(imageFile);

    // Wait for the upload to complete
    await uploadTask;

    // Get the download URL
    String downloadURL = await storageRef.getDownloadURL();

    // Step 3: Store the download URL in Firestore
    await FirebaseFirestore.instance.collection('users').doc(myName).set({
      'imageUrl': downloadURL,
    }, SetOptions(merge: true));

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Image uploaded successfully')));
  } catch (e) {
    print('Error uploading image: $e');
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to upload image')));
  }
}