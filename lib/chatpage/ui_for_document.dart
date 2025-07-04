import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class DocumentView extends StatefulWidget {
  final String documentUrl;
  final String filename;

  DocumentView({required this.documentUrl,required this.filename});

  @override
  _DocumentViewState createState() => _DocumentViewState();
}

class _DocumentViewState extends State<DocumentView> {
  String localPath = '';

  @override
  void initState() {
    super.initState();
    downloadFile();
  }

Future<void> downloadFile() async {
  try {
    var data = await http.get(Uri.parse(widget.documentUrl));
    if (data.statusCode != 200) {
      throw Exception('Failed to load document');
    }
    var bytes = data.bodyBytes;
    String dir = (await getApplicationDocumentsDirectory()).path;
    File file = File('$dir/document.pdf');
    File urlFile = await file.writeAsBytes(bytes);
    setState(() {
      localPath = urlFile.path;
    });
  } catch (e) {
    print('Error: $e');
  }
}


@override
Widget build(BuildContext context) {
  if (localPath.isEmpty) {
    // Show a loading indicator while the file is being downloaded
    return const  Center(child: CircularProgressIndicator());
  } else {
    // Show the PDF document
    return Container(
      
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2000),
            ),
            constraints: const BoxConstraints(
              maxHeight: 270,
              maxWidth: 270
            ),
            child: AspectRatio(
              aspectRatio: 1, // Adjust this value as needed
              child: Container(
                child: PDFView(
                  filePath: localPath,
                  pageSnap: true,
                  swipeHorizontal: true,
                  autoSpacing: false,
                  pageFling: true,
                  onRender: (_pages) {
                    setState(() {});
                  },
                  onError: (error) {
                    print(error.toString());
                  },
                  onPageError: (page, error) {
                    print('$page: ${error.toString()}');
                  },
                  onViewCreated: (PDFViewController pdfViewController) {},
                  onPageChanged: (int? page, int? total) {
                    print('page change: $page/$total');
                  },
                ),
              ),
            ),
          ),
          Text(widget.filename,style:const TextStyle(fontWeight: FontWeight.bold),),
          TextButton(onPressed: ()async {
            
          if (await canLaunch(widget.documentUrl)||true) {
            await launch(widget.documentUrl);
          } 
        
          }, child: const Text("Open and download",style: TextStyle(color: Colors.white),))
        ],
      ),
    );
  }
}


}


class DocumentWidget extends StatelessWidget {
  final String documentUrl;

  DocumentWidget({required this.documentUrl});

  @override
  Widget build(BuildContext context) {
    String documentName = getDocumentName(documentUrl);

    return InkWell(
      onTap: () async {
        if (await canLaunch(documentUrl)||true) {
          await launch(documentUrl);
        } 
      },
      child: Container(
        padding: EdgeInsets.all(8.0),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: <Widget>[
            Icon(Icons.insert_drive_file), // An icon for the document
            SizedBox(width: 8.0), // A little spacing
            Text(
              documentName,
              style: TextStyle(fontSize: 16.0),
            ),
          ],
        ),
      ),
    );
  }
  String getDocumentName(String documentUrl) {
  return Uri.decodeFull(Uri.parse(documentUrl).pathSegments.last);
}

}


