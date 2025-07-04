import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:rmk_community/chatpage/fileformet_keyboard.dart';
import 'package:rmk_community/chatpage/ui_for_audio.dart';
import 'package:rmk_community/chatpage/ui_for_document.dart';
import 'package:rmk_community/chatpage/ui_for_files.dart';
import 'package:rmk_community/chatpage/ui_for_video.dart';
import 'package:rmk_community/firestone_storage/insert_firestone_data.dart';
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatefulWidget {
  final String myName;
  final String friendName;
  final String docname;


  const ChatScreen({Key? key, required this.myName, required this.friendName,required this.docname}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  TextEditingController messageController = TextEditingController();
  late String chatDocId;
  bool isChatDocIdDetermined = false;
  final ScrollController _scrollController = ScrollController();
  

  String? repliedToMessageId; // Holds the ID of the message being replied to
  Map<String, GlobalKey> messageKeys = {}; // To store keys for each message
  Map<String, int> messageIndexMap = {}; // To store the index of each message

late SentFile sentFile;

  @override
  void initState() {
    super.initState();
    determineChatDocId();
    initializeSentFile();
  }

  @override
  void dispose() {
    
    super.dispose();
     markAllMessagesAsRead(widget.docname,widget.myName, widget.friendName);
  }

  

 

  Future<void> initializeSentFile() async {
    String mainPath = await determineMainPath(widget.myName, widget.friendName);
    sentFile = SentFile(
      context: context,
      myname: widget.myName,
      friendname: widget.friendName,
      main_path: mainPath,
      coll_name: 'chat_data',
      from: 'chat_data',
    );
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

 void determineChatDocId() async {
  String id1 = '${widget.myName}__|__${widget.friendName}';
  String id2 = '${widget.friendName}__|__${widget.myName}';

  DocumentSnapshot doc1 = await FirebaseFirestore.instance.collection('chat_data').doc(id1).get();
  DocumentSnapshot doc2 = await FirebaseFirestore.instance.collection('chat_data').doc(id2).get();

  if (doc1.exists) {
    setState(() {
      chatDocId = id1;
      isChatDocIdDetermined = true;
    });
  } else if (doc2.exists) {
    setState(() {
      chatDocId = id2;
      isChatDocIdDetermined = true;
    });
  } else {
    setState(() {
      chatDocId = id1; // default to id1 if neither exists
      isChatDocIdDetermined = true;
    });
  }

  // Print the determined chatDocId
  print('Chat Doc ID: $chatDocId');
}


  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      String messageId = '${widget.myName}_${DateTime.now().millisecondsSinceEpoch}';
      await FirebaseFirestore.instance.collection('chat_data').doc(chatDocId).set({
        messageId: {
          'message': messageController.text,
          'sentby': widget.myName,
          'time': Timestamp.now(),
          'messageId': messageId,
          'type': "txt",
          'filename': '',
          'repliedToMessageId': repliedToMessageId,
          'read':false // Include the ID of the message being replied to
        }
      }, SetOptions(merge: true));
      messageController.clear();
      setState(() {
        repliedToMessageId = null; // Reset repliedToMessageId after sending a message
      });
      _scrollToEnd(); // Scroll to bottom after sending a message
    }
  }

  void _scrollToEnd() {
    // Ensure the ListView has been built
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: Duration(seconds: 1),
        curve: Curves.easeInOut,
      );
    } else {
      // If the ListView is not yet attached, retry after a delay
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToEnd());
    }
  }


  String formatTimestamp(Timestamp timestamp) {
    final DateTime dateTime = timestamp.toDate();
    return DateFormat('h:mm a').format(dateTime);
  }

  Future<Map<String, dynamic>?> fetchMessageById(String messageId) async {
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('chat_data').doc(chatDocId).get();
    if (doc.exists) {
      var data = doc.data() as Map<String, dynamic>?;
      if (data != null && data.containsKey(messageId)) {
        return data[messageId];
      }
    }
    return null;
  }

void point_the_message(Map<String, dynamic> repliedMessage) {
  print("workkkkkkkkkkk");
  String messageId = repliedMessage['messageId'];
  if (messageKeys.containsKey(messageId)) {
    final key = messageKeys[messageId];
    if (key != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (key.currentContext != null) {
          final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
          if (renderBox.hasSize) {
            final position = renderBox.localToGlobal(Offset.zero);
            _scrollController.animateTo(
              0,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOut,
            ).then((_) { // Completion callback for the scroll animation
              _scrollController.animateTo(
                position.dy,
                duration: Duration(milliseconds: 500),
                curve: Curves.easeInOut,
              ).then((_) { // Completion callback for the second scroll animation
                AnimationController controller = AnimationController(
                  duration: Duration(milliseconds: 500),
                  vsync: this,
                );
                Animation<double> animation = Tween(begin: 0.0, end: 1.0).animate(controller)
                  ..addListener(() {
                    setState(() {});
                  });
                controller.forward();
                controller.addStatusListener((status) {
                  if (status == AnimationStatus.completed) {
                    controller.reverse();
                  }
                });
              });
            });
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              point_the_message(repliedMessage);
            });
          }
        }
      });
    }
  }
}

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Text(widget.friendName),
            find_status(context)
          ],
        ),
      ),
      body: isChatDocIdDetermined
          ? Column(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('chat_data').doc(chatDocId).snapshots(),
                    builder: (context, snapshot) {
                      if (!snapshot.hasData) {
                        return Center(child: CircularProgressIndicator());
                      }

                      var data = snapshot.data!.data() as Map<String, dynamic>?;
                      if (data == null || data.isEmpty) {
                        return Center(child: Text('No messages yet.'));
                      }

                      // Extracting messages from the map
                      var messages = data.values.toList();
                      messages.sort((a, b) => (a['time'] as Timestamp).compareTo(b['time'] as Timestamp));

                      return ListView.builder(
                        controller: _scrollController,
                        reverse: false,
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          var message = messages[index];
                          bool isSentByMe = message['sentby'] == widget.myName;
                          String mess_by=(isSentByMe)?widget.myName:widget.friendName;
                          String messageId = message['messageId'];
                          messageKeys[messageId] = GlobalKey();
                          messageIndexMap[messageId] = index;
                         
                          


                          return GestureDetector(
                            onLongPress: () {
                              _showMessageOptions(context, message);
                            },
                            onTap: () {
                              if (!isSentByMe) {
                                setState(() {
                                  repliedToMessageId = messageId;
                                });
                              }
                            },
                            child: Container(
                              key: messageKeys[messageId],
                              padding: EdgeInsets.symmetric(horizontal: 0, vertical: 10),
                              child: Align(
                                alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
                                child: Container(
                                  constraints: BoxConstraints(maxWidth: screenWidth * 0.8),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: isSentByMe ? Color.fromRGBO(198, 198, 198, 0.1) : Color.fromRGBO(204, 153, 255, 0.3),
                                  ),
                                  padding: const EdgeInsets.all(13),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      if (message['repliedToMessageId'] != null) // Display quoted message if available
                                        FutureBuilder<Map<String, dynamic>?>(
                                          future: fetchMessageById(message['repliedToMessageId']),
                                          builder: (context, snapshot) {
                                            if (snapshot.connectionState == ConnectionState.waiting) {
                                              return CircularProgressIndicator();
                                            } else if (snapshot.hasError || !snapshot.hasData) {
                                              return Text('Failed to load replied message');
                                            } else {
                                              var repliedMessage = snapshot.data!;
                                              return TextButton(
                                                onPressed: () {
                                                  point_the_message(repliedMessage);
                                                },
                                                child: buildRepliedMessageContent(repliedMessage)
                                              );
                                            }
                                          },
                                        ),
                                        Container(
                                        
                                         // alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
                                         child: Text(mess_by),
                                        ),
                                      buildMessageContent(message),
                                      const SizedBox(height: 5),
                                      Text(
                                        formatTimestamp(message['time']),
                                        style: const TextStyle(fontSize: 12, color: Colors.grey),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            
                          );
                          
                        },
                      );
                    },
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          sentFile.showAttachmentOptions();
                        },
                        icon: Icon(Icons.attach_file),
                      ),
                      Expanded(
                        child: TextField(
                          controller: messageController,
                          decoration: InputDecoration(
                            hintText: 'Enter your message...',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () => sendMessage(),
                      ),
                    ],
                  ),
                ),
              ],
            )
                      : Center(child: CircularProgressIndicator()),
    );
  }

  Widget buildMessageContent(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'audio':
        return AudioMessageWidget(audioUrl: message['url'], filename: message['filename'], myname: message['sentby']);
      case 'image':
        return uiImage(message['url'], message['filename']);
      case 'video':
        return VideoThumbnail(videoUrl: message['url'], filename: message['filename']);
      case 'document':
        return DocumentView(documentUrl: message['url'], filename: message['filename']);
      default:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Linkify(
              onOpen: (link) async {
                if (link.url.contains('youtube.com') || link.url.contains('youtu.be')) {
                  if (await canLaunch(link.url) || true) {
                    await launch(link.url, forceSafariVC: false, forceWebView: false);
                  }
                } else {
                  if (await canLaunch(link.url) || true) {
                    await launch(link.url, forceSafariVC: true, forceWebView: true);
                  }
                }
              },
              text: message['message'] ?? "",
              style: GoogleFonts.nunito(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white, // Update color based on your design
              ),
              linkStyle: const TextStyle(
                color: Colors.blue,
                decoration: TextDecoration.underline,
              ),
            ),
          ],
        );
    }
  }

  Widget buildRepliedMessageContent(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'audio':
        return const Row(
          children: [
            Icon(Icons.audiotrack, color: Colors.grey),
            SizedBox(width: 5),
            Text(
              'Audio message',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        );
      case 'image':
        return const Row(
          children: [
            Icon(Icons.image, color: Colors.grey),
            SizedBox(width: 5),
            Text(
              'Image message',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        );
      case 'video':
        return const Row(
          children: [
            Icon(Icons.videocam, color: Colors.grey),
            SizedBox(width: 5),
            Text(
              'Video message',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        );
      case 'document':
        return const Row(
          children: [
            Icon(Icons.insert_drive_file, color: Colors.grey),
            SizedBox(width: 5),
            Text(
              'Document message',
              style: TextStyle(
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            ),
          ],
        );
      default:
        return Text(
          "replied to: ${message['message'] ?? ""}",
          style: const TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        );
    }
  }

  void _showMessageOptions(BuildContext context, Map<String, dynamic> message) {
    bool isSentByMe = message['sentby'] == widget.myName;
    String messageId = message['messageId']; // Retrieve the message ID from the message map

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: Text('Copy'),
                onTap: () {
                  Navigator.of(context).pop();
                  _copyMessageToClipboard(message['message']);
                },
              ),
              if (isSentByMe)
                ListTile(
                  title: Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    deleteMessage(messageId, chatDocId); // Pass message ID for deletion
                  },
                ),
              ListTile(
                title: Text('Reply'),
                onTap: () {
               Navigator.of(context).pop();
                  setState(() {
                    // Set the repliedToMessageId when replying
                    repliedToMessageId = messageId;
                  });
                },
              ),
            ],
          ),
        );
      },
    ); 
  }

  void _copyMessageToClipboard(String message) {
    Clipboard.setData(ClipboardData(text: message));
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Message copied to clipboard')));
  }

   Widget find_status(BuildContext context) {
    FirebaseFirestore _firestore = FirebaseFirestore.instance;


    return StreamBuilder<DocumentSnapshot>(
      stream: _firestore.collection('users').doc(widget.friendName).snapshots(),
      builder: (BuildContext context, AsyncSnapshot<DocumentSnapshot> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator(); // Loading indicator while waiting for data
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Text('User not found');
        }

        final status = snapshot.data!['status'];
        return Text(status,style: TextStyle(fontSize: 17),);
      },
    );
  }

void markMessageAsRead(String chatId, String messageId) {
  FirebaseFirestore.instance
      .collection('chat_data')
      .doc(chatId)
      .update({
    '$messageId.read': true,
  });
}

void markAllMessagesAsRead(String docId, String myname, String friendname) {
  FirebaseFirestore.instance.collection('chat_data').doc(docId).get().then((docSnapshot) {
    if (docSnapshot.exists) {
      Map<String, dynamic>? messages = docSnapshot.data() as Map<String, dynamic>?;

      if (messages != null) {
        WriteBatch batch = FirebaseFirestore.instance.batch();

        messages.forEach((messageId, messageData) {
          if (messageData['sentby'] != myname) {
            batch.update(
              FirebaseFirestore.instance.collection('chat_data').doc(docId),
              {
                '$messageId.read': true,
              },
            );
          }
        });

        batch.commit();
      }
    }
  });
}



}

void deleteMessage(String messageId, String chatDocId) async {
  try {
    await FirebaseFirestore.instance.collection('chat_data').doc(chatDocId).update({
      messageId: FieldValue.delete(),
    });
    print('Message deleted successfully');
  } catch (e) {
    print('Error deleting message: $e');
  }
}