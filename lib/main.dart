import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/dash/dash_bloc.dart';
import 'package:soqchi/language.dart';
import 'package:soqchi/screen/dash.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'langua/AppLanguage.dart';
import 'langua/LanguageChangeProvider.dart';
// import 'generated/l10n.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
bool isreg = false;
final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // InAppPurchase.instance.enablePendingPurchases();
  final SharedPreferences prefs = await _prefs;
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  isreg = prefs.getBool("regstatus") ?? false;
  if(Platform.isAndroid){
    await Firebase.initializeApp(
        options: const FirebaseOptions(
            apiKey: 'AIzaSyB78N3JjKj_yfeTVNGgR2xqRyWqIZ1oeBU',
            appId: '1:557053568991:android:3c6f8b2e9601070a00466a',
            messagingSenderId: '557053568991',
            projectId: 'family-fed05'));
  }
  else{
    await Firebase.initializeApp();
  }
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {

  const MyApp({super.key});


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (ctx) => DashBloc(),
      child: ChangeNotifierProvider<LanguageChangeProvider>(
        create: (context) => LanguageChangeProvider(),
        child: Builder(
            builder: (context) => MaterialApp(
              locale: Provider.of<LanguageChangeProvider>(context, listen: true)
                  .currentLocale,
              localizationsDelegates: [
                AppLocalizations.delegate, // Add this line
                GlobalMaterialLocalizations.delegate,
                GlobalWidgetsLocalizations.delegate,
                GlobalCupertinoLocalizations.delegate,
              ],
              supportedLocales: [
                Locale('en', ''), // English, no country code
                Locale('uz', ''), // English, no country code
                Locale('ru', ''), // English, no country code
              ],
              title: 'Flutter Demo',
              debugShowCheckedModeBanner: false,
              theme: ThemeData(
                  useMaterial3: true,
                  iconTheme: IconThemeData(
                      color: Colors.blueGrey
                  )
              ),
              home: isreg ? DashboardPage() : SelectFirstLanguagePage(),
            ),
        )
      ),
    );
  }
}
