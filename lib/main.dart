import 'dart:typed_data';

import 'package:Tracker/define.dart';
import 'package:Tracker/file_manager/file_manager_page.dart';
import 'package:Tracker/video_recording_page/video_recording_page.dart';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:flutter/services.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

List<CameraDescription> cameras = [];
Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // SystemChrome.setEnabledSystemUIOverlays([]);

  try {
    cameras = await availableCameras();
  } on CameraException catch (e) {
    print('camera error' + e.code);
    print(e.description);
  }
  runApp(TrackerApp());
}

class TrackerApp extends StatelessWidget {
  const TrackerApp({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            brightness: Brightness.dark,
            visualDensity: VisualDensity.adaptivePlatformDensity),
        title: 'Tracker',
        home: VideoRecordingPage(availableCameras: cameras));
  }
}

// FileManagerPage(
//           title: 'Recordings',
//           rootDir: RECORDING_DIR,
//           headingBuilder: (f) {
//             Future<Uint8List> future =
//                 VideoThumbnail.thumbnailData(video: f.path);
//             return FutureBuilder<Uint8List>(
//               builder: (context, snapshot) {
//                 if (snapshot.connectionState == ConnectionState.done) {
//                   return Padding(
//                       padding: EdgeInsets.only(left: 15.0, right: 15.0),
//                       child: Image.memory(
//                         snapshot.data,
//                         height: 30.0,
//                       ));
//                 } else
//                   return Icon(Icons.perm_media);
//               },
//               future: future,
//             );
//           },
//         )
