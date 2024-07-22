import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/bloc/dash/dash_bloc.dart';
import 'package:soqchi/childs_list.dart';
import 'package:soqchi/screen/dash.dart';
import 'package:soqchi/home.dart';
import 'package:soqchi/login.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'langua/AppLanguage.dart';
import 'langua/LanguageChangeProvider.dart';
// import 'generated/l10n.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
bool isreg = false;
final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // InAppPurchase.instance.enablePendingPurchases();
  final SharedPreferences prefs = await _prefs;
  AppLanguage appLanguage = AppLanguage();
  await appLanguage.fetchLocale();
  isreg = prefs.getBool("regstatus") ?? false;
  await Firebase.initializeApp(
      options: const FirebaseOptions(
          apiKey: 'AIzaSyBA710fR7PsT1ucvVLs4tC6MJ2t1mMJwHA',
          appId: '1:971402296966:android:b0ff031fe8a7260f7adb07',
          messagingSenderId: '971402296966',
          projectId: 'family-adf60'));
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
              // localizationsDelegates: [
              //   S.delegate,
              //   GlobalMaterialLocalizations.delegate,
              //   GlobalWidgetsLocalizations.delegate,
              //   GlobalCupertinoLocalizations.delegate,
              //   DefaultCupertinoLocalizations.delegate
              // ],
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
                  iconTheme: IconThemeData(
                      color: Colors.blueGrey
                  )
              ),
              home: isreg ? DashboardPage() : LoginPage(),
            ),
        )
      ),
    );
  }
}
