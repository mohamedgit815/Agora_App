import 'package:agora_app/home_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);


  if(await Permission.microphone.request().isGranted
      &&
     await Permission.camera.request().isGranted){

    runApp(const ProviderScope(child: MyApp()));

  } else {

    runApp(const ProviderScope(child: MyApp()));
  }
}


class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AgoraApp',
      theme: ThemeData(
        primarySwatch: Colors.red,
        colorScheme: const ColorScheme.light() ,
        inputDecorationTheme: const InputDecorationTheme(
          focusColor: Colors.red ,
        )
      ),
      home: const HomePage(),
    );
  }
}

const String appId = 'c15ec5bf8a69400a940f5420095fda0d';
const String channelName = 'test';
const String token = '006c15ec5bf8a69400a940f5420095fda0dIAD7Vl55o7xdOimNYXvHLSlnB02SUQHLaVkn529FnMEzrgx+f9gAAAAAEAAWylBUQaURYgEAAQBBpRFi';