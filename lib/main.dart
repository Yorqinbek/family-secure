import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/childs_list.dart';
import 'package:soqchi/dash.dart';
import 'package:soqchi/home.dart';
import 'package:soqchi/login.dart';

bool isreg = false;
final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final SharedPreferences prefs = await _prefs;

  isreg = prefs.getBool("regstatus") ?? false;
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyBVLsnpreKU19VpliskFe_puujj-NI3avU',
          appId: '1:870724131998:android:ac6ec8855c1f47faceaf8f',
          messagingSenderId: '870724131998',
          projectId: 'soqchi-bd3e9'));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        // This is the theme of your application.
        //
        // TRY THIS: Try running your application with "flutter run". You'll see
        // the application has a blue toolbar. Then, without quitting the app,
        // try changing the seedColor in the colorScheme below to Colors.green
        // and then invoke "hot reload" (save your changes or press the "hot
        // reload" button in a Flutter-supported IDE, or press "r" if you used
        // the command line to start the app).
        //
        // Notice that the counter didn't reset back to zero; the application
        // state is not lost during the reload. To reset the state, use hot
        // restart instead.
        //
        // This works for code too, not just values: Most code changes can be
        // tested with just a hot reload.
        // colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: isreg ? DashboardPage() : LoginPage(),
    );
  }
}
