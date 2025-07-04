import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

  Widget uiImage(String imageUrl,String filename) {
    return Column(
      children: [
        Container(
          constraints: const BoxConstraints(
            maxHeight: 160,
            maxWidth: 180,
          ),
          width: 180,
          height: 180,
          child: Image.network(imageUrl),
        ),
        Text(filename,style:const TextStyle(fontWeight: FontWeight.bold),),
        TextButton(
          onPressed: () async {
            String no=getFileExtensionFromUrl(imageUrl);
            await openFile(imageUrl,"$filename$no");
          },
          child: Text('open'),
        ),
      ],
    );
  }



Future openFile(String url,String filename)async{
 final file=   await downloadFile(url,filename);
 if(file==null) return;
 print("path:"+file.path);
 OpenFile.open(file.path);
}

Future<File?> downloadFile(String url,String name)async{
    final appstorage=await getApplicationCacheDirectory();
    final file=File('${appstorage.path}/$name');

    final response =await Dio().get(
      url,
      options: Options(
        responseType: ResponseType.bytes,
        followRedirects: false,
        receiveTimeout: Duration.zero,
      ),
    );

    final raf=file.openSync(mode: FileMode.write);
    raf.writeFromSync(response.data);
    await raf.close();
    return file;
}



  String getFileExtensionFromUrl(String url) {
    // Parse the URL
    Uri uri = Uri.parse(url);

    // Get the path segments
    List<String> pathSegments = uri.pathSegments;

    // Iterate through the path segments to find keywords
    for (String segment in pathSegments) {
      // Check for keywords
      if (segment.contains('images')) {
        return '.png';
      } else if (segment.contains('audios')) {
        return '.mp3';
      } else if (segment.contains('videos')) {
        return '.mp4';
      }
    }

    
    return '.pdf';
  }






