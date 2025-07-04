import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:rmk_community/chatpage/fileformet_keyboard.dart';
import 'package:rmk_community/chatpage/ui_for_audio.dart';
import 'package:rmk_community/chatpage/ui_for_document.dart';
import 'package:rmk_community/chatpage/ui_for_files.dart';
import 'package:rmk_community/chatpage/ui_for_video.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../firestone_storage/insert_firestone_data.dart';

class DoubtComments extends StatefulWidget {
  final String question;
  final String name;
  final String myname;

  const DoubtComments({Key? key, required this.question, required this.name, required this.myname}) : super(key: key);

  @override
  _DoubtCommentsState createState() => _DoubtCommentsState();
}

class _DoubtCommentsState extends State<DoubtComments> {
  TextEditingController commandController = TextEditingController();
  String? repliedToMessageId; // Holds the ID of the message being replied to
  Map<String, GlobalKey> messageKeys = {}; // To store keys for each message

  void sendMessage() async {
    if (commandController.text.isNotEmpty) {
      String messageId = '${widget.myname}_${DateTime.now().millisecondsSinceEpoch}';
      await addDataToFirestore("doubt_time", widget.name, widget.name, commandController.text, widget.myname, repliedToMessageId??"", "","");
      commandController.clear();
      setState(() {
        repliedToMessageId = null; // Reset repliedToMessageId after sending a message
      });
    }
  }

  void deleteMessage(String messageId) async {
    await FirebaseFirestore.instance.collection('doubt_time').doc(widget.name).update({
      messageId: FieldValue.delete(),
    });
  }

  Future<Map<String, dynamic>?> fetchMessageById(String messageId) async {
  DocumentSnapshot doc = await FirebaseFirestore.instance.collection('doubt_time').doc(widget.name).get();
  if (doc.exists) {
    var data = doc.data() as Map<String, dynamic>?;
    if (data != null && data.containsKey(messageId)) {
      return data[messageId];
    }
  }
  return null;
}


 

  void pointToMessage(Map<String, dynamic> repliedMessage) {
    String messageId = repliedMessage['messageId'];
    if (messageKeys.containsKey(messageId)) {
      final key = messageKeys[messageId];
      if (key != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (key.currentContext != null) {
            final RenderBox renderBox = key.currentContext!.findRenderObject() as RenderBox;
            if (renderBox.hasSize) {
              final position = renderBox.localToGlobal(Offset.zero);
              Scrollable.ensureVisible(key.currentContext!, duration: Duration(milliseconds: 500));
            } else {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                pointToMessage(repliedMessage);
              });
            }
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final sentFile = SentFile(
      context: context,
      myname: widget.myname,
      friendname: widget.name,
      main_path: "${widget.name}'_doubt",
      coll_name: 'doubt_time',
      from: 'doubt_time',
    );

    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: const Text("Discussion"),
      ),
      body: Stack(
        children: [
          StreamBuilder<DocumentSnapshot>(
            stream: FirebaseFirestore.instance.collection('doubt_time').doc(widget.name).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              if (!snapshot.hasData || snapshot.data == null || !snapshot.data!.exists) {
                return const Center(child: Text('No data available.'));
              }

              final data = snapshot.data!.data() as Map<String, dynamic>;
              final messages = data.entries.where((entry) {
                return entry.key != 'name' && entry.key != 'question' && entry.key != 'time';
              }).toList();

              messages.sort((a, b) => a.value['time'].compareTo(b.value['time']));

              return SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 100),
                child: Column(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(40),
                        color: const Color.fromRGBO(198, 198, 198, 0.1),
                      ),
                      padding: EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Container(
                            alignment: Alignment.topLeft,
                            child: const Text("~Doubt:", style: TextStyle(fontSize: 20)),
                          ),
                          Center(
                            child: Text(
                              widget.question,
                              style: GoogleFonts.nunito(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 11),
                    ...messages.map((entry) {
                      final messageId = entry.key;
                      final messageData = entry.value;
                      bool isSentByMe = messageData['sentby'] == widget.myname;
                      messageKeys[messageId] = GlobalKey();

                      return Align(
                        alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
                        child: GestureDetector(
                          onLongPress: () {
                            _showMessageOptions(context, messageData);
                          },
                          onTap: () {
                            if (!isSentByMe) {
                              setState(() {
                                repliedToMessageId = messageId;
                              });
                            }
                          },
                          child: IntrinsicWidth(
                            child: Container(
                              key: messageKeys[messageId],
                              constraints: BoxConstraints(maxWidth: screenWidth * 0.87),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(20),
                                color: Colors.grey[800],
                              ),
                              margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                              padding: const EdgeInsets.all(10),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (messageData['repliedToMessageId'] != null) // Display quoted message if available
                                    FutureBuilder<Map<String, dynamic>?>(
                                      future: fetchMessageById(messageData['repliedToMessageId']),
                                      builder: (context, snapshot) {
                                        if (snapshot.connectionState == ConnectionState.waiting) {
                                          return const CircularProgressIndicator();
                                        } else if (snapshot.hasError || !snapshot.hasData) {
                                          return const Text('Failed to load replied message');
                                        } else {
                                          var repliedMessage = snapshot.data!;
                                          return TextButton(
                                            onPressed: () {
                                              pointToMessage(repliedMessage);
                                            },
                                            child: buildRepliedMessageContent(repliedMessage),
                                          );
                                        }
                                      },
                                    ),
                                  Container(
                                    alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
                                    child: Text(
                                      '~${messageData['sentby']}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 12,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  buildMessageContent(messageData),
                                  Container(
                                    alignment: Alignment.bottomRight,
                                    child: Text(
                                      '${convertToShortTime(messageData['time'])}',
                                      style: GoogleFonts.nunito(
                                        fontSize: 10,
                                        color: Colors.white,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              );
            },
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              color: Colors.black12,
              child: Row(
                children: [
                  IconButton(
                    onPressed: () {
                      sentFile.showAttachmentOptions();
                    },
                    icon: const Icon(Icons.file_present),
                  ),
                  Expanded(
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Enter your comment...',
                        hintStyle: const TextStyle(color: Colors.white54),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white10,
                      ),
                      style: const TextStyle(color: Colors.white),
                      controller: commandController,
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    icon: Icon(Icons.send),
                    color: Colors.white,
                    onPressed: sendMessage,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String convertToShortTime(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    final outputFormat = DateFormat("h:mm a");
    final outputString = outputFormat.format(dateTime);
    return outputString;
  }

  void copyToClipboard(String value) {
    Clipboard.setData(ClipboardData(text: value));
  }

  Widget buildMessageContent(Map<String, dynamic> messageData) {
      if (!messageData.containsKey('sentby')) {return Container();}
    switch (messageData['type']) {
      case 'image':
        return SizedBox(
          width: 200, // Adjust the width as needed
          child: uiImage(messageData['url'], messageData['filename']),
        );
      case 'audio':
        return SizedBox(
          height: 68,
          child: AudioMessageWidget(audioUrl: messageData['url'], filename: messageData['filename'], myname: messageData['sentby']),
        );
      case 'document':
        return SizedBox(
          width: 200, // Adjust the width as needed
          child: DocumentView(filename: messageData['filename'], documentUrl: messageData['url']),
        );
      case 'video':
        return SizedBox(
          width: 200, // Adjust the width as needed
          child: VideoThumbnail(videoUrl: messageData['url'], filename: messageData['filename']),
        );
      default:
        return Linkify(
          onOpen: (link) async {
            print('Opening link: ${link.url}');
            if (await canLaunch(link.url) || true) {
              await launch(link.url);
            }
          },
          text: messageData['message'],
          style: GoogleFonts.nunito(
            fontSize: 17,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
          linkStyle: const TextStyle(
            color: Colors.blue,
            decoration: TextDecoration.underline,
          ),
        );
    }
  }

  Widget buildRepliedMessageContent(Map<String, dynamic> message) {
    switch (message['type']) {
      case 'image':
        return const Text(
          'Image message',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        );
      case 'audio':
        return const Text(
          'Audio message',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        );
      case 'document':
        return const Text(
          'Document message',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
        );
      case 'video':
        return const Text(
          'Video message',
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: Colors.grey,
          ),
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
    bool isSentByMe = message['sentby'] == widget.myname;
    String messageId = message['messageId'];

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Message Options'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                title: const Text('Copy'),
                onTap: () {
                 Navigator.of(context).pop(); 
                  copyToClipboard(message['message']);
                },
              ),
              if (isSentByMe)
                ListTile(
                  title: const Text('Delete'),
                  onTap: () {
                   Navigator.of(context).pop(); 
                    deleteMessage(messageId);
                  },
                ),
              ListTile(
                title: const Text('Reply'),
                onTap: () {
                  Navigator.of(context).pop(); 
                  setState(() {
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

  @override
  void dispose() {
    commandController.dispose();
    super.dispose();
  }
}

