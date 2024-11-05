import 'package:country_flags/country_flags.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/login.dart';

import 'langua/LanguageChangeProvider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
class SelectFirstLanguagePage extends StatefulWidget {
  const SelectFirstLanguagePage({super.key});

  @override
  State<SelectFirstLanguagePage> createState() => _SelectFirstLanguagePageState();
}

class _SelectFirstLanguagePageState extends State<SelectFirstLanguagePage> {
  late Future<int>  lan_item;
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  Future<void> _setlan(int a) async {
    final SharedPreferences prefs = await _prefs;
    setState(() {
      lan_item = prefs.setInt('lan', a).then((bool success) {
        return a;
      });
    });
  }
  @override
  void initState() {
    super.initState();

    lan_item = _prefs.then((SharedPreferences prefs) {
      return prefs.getInt('lan') ?? 0;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: FutureBuilder<int>(
            future: lan_item,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            switch (snapshot.connectionState) {
              default:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  return Center(
                    child: Column(
                      children: [
                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.03,),
                        Text(
                          "Family Secure", style: TextStyle(color: Colors.black,
                            fontSize: 32,
                            fontWeight: FontWeight.bold),),
                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.01,),
                        Padding(
                          padding: const EdgeInsets.only(left: 10,right: 19),
                          child: Text(AppLocalizations.of(context)!.welcome_intro,
                            style: TextStyle(color: Colors.black, fontSize: 18),),
                        ),
                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.2,),
                        InkWell(
                          onTap: () async {
                            await _setlan(0);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('lan', 0);
                            context.read<LanguageChangeProvider>()
                                .changeLocale("en");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListTile(
                              tileColor: snapshot.data == 0 ? Colors.blueAccent :  Colors.grey[100],
                              title: Text("English", style: TextStyle(
                                  color:  snapshot.data == 0 ? Colors.white:Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),),
                              leading: CountryFlag.fromCountryCode(
                                'GB',
                                height: 35,
                                width: 35,
                                borderRadius: 8,
                              ),
                              trailing: snapshot.data == 0 ? Icon(Icons.check, color: Colors.white,): SizedBox(),
                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await _setlan(1);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('lan', 1);
                            context.read<LanguageChangeProvider>()
                                .changeLocale("uz");

                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListTile(
                              tileColor: snapshot.data == 1 ? Colors.blueAccent :  Colors.grey[100],
                              title: Text("Uzbek", style: TextStyle(
                                  color:  snapshot.data == 1 ? Colors.white:Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),),
                              leading: CountryFlag.fromCountryCode(
                                'uz',
                                height: 35,
                                width: 35,
                                borderRadius: 8,
                              ),
                              trailing: snapshot.data == 1 ? Icon(Icons.check, color: Colors.white,): SizedBox(),

                            ),
                          ),
                        ),
                        InkWell(
                          onTap: () async {
                            await _setlan(2);
                            final prefs = await SharedPreferences.getInstance();
                            await prefs.setInt('lan', 2);
                            context.read<LanguageChangeProvider>()
                                .changeLocale("ru");
                          },
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: ListTile(
                              tileColor: snapshot.data == 2 ? Colors.blueAccent :  Colors.grey[100],
                              title: Text("Russian", style: TextStyle(
                                  color:  snapshot.data == 2 ? Colors.white:Colors.black,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold),),
                              leading: CountryFlag.fromCountryCode(
                                'ru',
                                height: 35,
                                width: 35,
                                borderRadius: 8,
                              ),
                              trailing: snapshot.data == 2 ? Icon(Icons.check, color: Colors.white,): SizedBox(),

                            ),
                          ),
                        ),
                        SizedBox(height: MediaQuery
                            .of(context)
                            .size
                            .height * 0.2,),
                        Container(
                            width: MediaQuery
                                .of(context)
                                .size
                                .width * 0.9,
                            height: MediaQuery
                                .of(context)
                                .size
                                .height * 0.07,
                            child: ElevatedButton(
                              style: ButtonStyle(
                                backgroundColor:
                                MaterialStateProperty.all(Colors.blueAccent),
                                shape:
                                MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                  RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(
                                        15), // radius of the corners
                                  ),
                                ),
                              ),
                              onPressed: () {
                                Navigator.pushReplacement(context,
                                    MaterialPageRoute(builder: (context) {
                                      return LoginPage();
                                    }));
                              },
                              child: Text(
                                AppLocalizations.of(context)!.next,
                                style: TextStyle(
                                    color: Colors.white, fontSize: 20),
                              ),
                            )),
                      ],
                    ),
                  );
                }
            }
          }
        ),
      ),
    );
  }
}
