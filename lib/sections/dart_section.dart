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
import 'package:url_launcher/url_launcher.dart';

class DartSection extends StatefulWidget {
  final String section_name;
  final String myName;
  

  const DartSection({Key? key, required this.section_name,required this.myName}) : super(key: key);

  @override
  _DartSectionState createState() => _DartSectionState();
}

class _DartSectionState extends State<DartSection> with TickerProviderStateMixin {
  TextEditingController messageController = TextEditingController();
  late String chatDocId;
  bool isChatDocIdDetermined = true;
  final ScrollController _scrollController = ScrollController();
  

  String? repliedToMessageId; // Holds the ID of the message being replied to
  Map<String, GlobalKey> messageKeys = {}; // To store keys for each message
  Map<String, int> messageIndexMap = {}; // To store the index of each message

late SentFile sentFile;

  @override
  void initState() {
    super.initState();
    initializeSentFile();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scrollToEnd();
    });
  }

  Future<void> initializeSentFile() async {
    String mainPath ='dart';
    sentFile = SentFile(
      context: context,
      myname: widget.myName,
      friendname: widget.section_name,
      main_path: mainPath,
      coll_name: 'Sections',
      from: 'Sections',
    );
  }





  void sendMessage() async {
    if (messageController.text.isNotEmpty) {
      String messageId = '${widget.myName}_${DateTime.now().millisecondsSinceEpoch}';
      await FirebaseFirestore.instance.collection('Sections').doc(widget.section_name).set({
        messageId: {
          'message': messageController.text,
          'sentby': widget.myName,
          'time': Timestamp.now(),
          'messageId': messageId,
          'type': "txt",
          'filename': '',
          'repliedToMessageId': repliedToMessageId, // Include the ID of the message being replied to
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
    DocumentSnapshot doc = await FirebaseFirestore.instance.collection('Sections').doc(widget.section_name).get();
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
        title: Text(widget.section_name),
      ),
      body: isChatDocIdDetermined
          ? Column(
              children: [
                Expanded(
                  child: StreamBuilder<DocumentSnapshot>(
                    stream: FirebaseFirestore.instance.collection('Sections').doc(widget.section_name).snapshots(),
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
                          String mess_by=(isSentByMe)?widget.myName:message['sentby'];

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
                                        
                                          //alignment: isSentByMe ? Alignment.topRight : Alignment.topLeft,
                                         child: Text("~"+mess_by)
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
                  Navigator.pop(context);
                  _copyMessageToClipboard(message['message']);
                },
              ),
              if (isSentByMe)
                ListTile(
                  title: Text('Delete'),
                  onTap: () {
                    Navigator.pop(context);
                    deleteMessage(messageId); // Pass message ID for deletion
                  },
                ),
              ListTile(
                title: Text('Reply'),
                onTap: () {
                  Navigator.pop(context);
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
  void deleteMessage(String messageId) async {
  try {
    await FirebaseFirestore.instance.collection('Sections').doc(widget.section_name).update({
      messageId: FieldValue.delete(),
    });
    print('Message deleted successfully');
  } catch (e) {
    print('Error deleting message: $e');
  }
}
 @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

}



