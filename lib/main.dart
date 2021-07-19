import 'package:assets_audio_player/assets_audio_player.dart';
import 'package:flutter/material.dart';
import 'package:flutter_neumorphic/flutter_neumorphic.dart';
import 'package:full_audio/table_event.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  AssetsAudioPlayer.setupNotificationsOpenAction((notification) {
    print(notification.audioId);
    return true;
  });

//  runApp(
//    NeumorphicTheme(
//      theme: NeumorphicThemeData(
//        intensity: 0.8,
//        lightSource: LightSource.topLeft,
//      ),
//      child: MyApp(),
//    ),
//  );

  initializeDateFormatting().then((_) => runApp(MyApp()));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Calendar',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
//      home: StartPage(),
      home: TableEvent(),
    );
  }
}
