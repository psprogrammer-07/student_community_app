import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';

import '../firestone_storage/insert_firestone_data.dart';

class SentFile {
  final String myname;
  final String friendname;
  final BuildContext context;
  final String main_path;
  final String coll_name;
  final String from;

  SentFile({
    required this.context,
   required this.myname,
    required this.friendname,
    required this.main_path,
    required this.coll_name,
    required this.from,
    
    });

  void showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Wrap(
        children: <Widget>[
          ListTile(
            leading: const Icon(Icons.image),
            title: const Text('Gallery'),
            onTap: () {
              Navigator.of(context).pop();
              _promptFileNameAndUpload(uploadImageFromGallery);
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt),
            title: const Text('Camera'),
            onTap: () {
              Navigator.of(context).pop();
              _promptFileNameAndUpload(uploadImageFromCamera);
            },
          ),
          ListTile(
            leading: const Icon(Icons.audiotrack),
            title: const Text('Audio'),
            onTap: () {
            Navigator.of(context).pop();
              _promptFileNameAndUpload(uploadAudio);
            },
          ),
          ListTile(
            leading: const Icon(Icons.video_file),
            title: const Text('Video'),
            onTap: () {
           Navigator.of(context).pop();
              _promptFileNameAndUpload(uploadVideo);
            },
          ),
          ListTile(
            leading: const Icon(Icons.insert_drive_file),
            title: const Text('PDF'),
            onTap: () {
              Navigator.of(context).pop();
              _promptFileNameAndUpload(uploadDocument);
            },
          ),
        ],
      ),
    );
  }

  void _promptFileNameAndUpload(Function(String) uploadFunction) {
    TextEditingController fileNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter File Name'),
          content: TextField(
            controller: fileNameController,
            decoration: const InputDecoration(hintText: 'File name (max 25 characters)'),
            maxLength: 25,
          ),
          actions: [
            TextButton(
              child: const Text('CANCEL'),
              onPressed: () {
               Navigator.of(context).pop(); 
              },
            ),
            TextButton(
              child: const Text('OK'),
              onPressed: () {
                String fileName = fileNameController.text.trim();
                if (fileName.isNotEmpty) {
                  uploadFunction(fileName);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  final ImagePicker _picker = ImagePicker();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadFile(File file, String folderName, String fileName,) async {
 
    Reference ref = _storage.ref().child('${(from=='chat_data')?'chat_data':from}/${main_path}/$folderName/$fileName');
    UploadTask uploadTask = ref.putFile(file);
    TaskSnapshot taskSnapshot = await uploadTask;
    String downloadUrl = await taskSnapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> uploadImageFromGallery(String fileName) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String downloadUrl = await uploadFile(file, 'images', fileName);
      await saveFileUrlToFirestore(downloadUrl, 'image',fileName);
    }
  }

  Future<void> uploadImageFromCamera(String fileName) async {
    final pickedFile = await _picker.pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String downloadUrl = await uploadFile(file, 'images', fileName);
      await saveFileUrlToFirestore(downloadUrl, 'image',fileName);
    }
  }

  Future<void> uploadAudio(String fileName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.audio);
    if (result != null) {
      File file = File(result.files.single.path!);
      String downloadUrl = await uploadFile(file, 'audio', fileName);
      await saveFileUrlToFirestore(downloadUrl, 'audio',fileName);
    }
  }

  Future<void> uploadDocument(String fileName) async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.custom, allowedExtensions: ['pdf', 'doc', 'docx', 'xls', 'xlsx']);
    if (result != null) {
      File file = File(result.files.single.path!);
      String downloadUrl = await uploadFile(file, 'documents', fileName);
      await saveFileUrlToFirestore(downloadUrl, 'document',fileName);
    }
  }

  Future<void> uploadVideo(String fileName) async {
    final pickedFile = await _picker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      File file = File(pickedFile.path);
      String downloadUrl = await uploadFile(file, 'videos', fileName);
      await saveFileUrlToFirestore(downloadUrl, 'video',fileName);
    }
  }

  Future<void> saveFileUrlToFirestore(String downloadUrl, String fileType,String filename) async {

    String messageId = '${myname}_${DateTime.now().millisecondsSinceEpoch}';
    await FirebaseFirestore.instance.collection(coll_name).doc((from=='chat_data')? main_path:friendname).set({
      messageId: {
        'message': null,
        'messageId': messageId,
        'read':false,
        'sentby': myname,
        'time': Timestamp.now(),
        "type": fileType,
        'url': downloadUrl,
        'filename':filename
      }
    }, SetOptions(merge: true));
  }
}
