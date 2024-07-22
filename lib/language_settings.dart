import 'package:custom_radio_group_list/custom_radio_group_list.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';

import 'langua/LanguageChangeProvider.dart';


class LanguageSettings extends StatefulWidget {
  const LanguageSettings({Key? key}) : super(key: key);

  @override
  State<LanguageSettings> createState() => _LanguageSettingsState();
}

class _LanguageSettingsState extends State<LanguageSettings> {
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late Future<int> lan_item;
  List<String> languages = [
    'English',
    'Uzbek',
    'Русский'
  ];

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
      appBar: AppBar(
        title: Text("Language"),
      ),
      body: SafeArea(
        child: FutureBuilder<int>(
          future: lan_item,
          builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else {
              return Padding(
                padding: const EdgeInsets.all(12.0),
                // child: TextButton(
                //   onPressed: () async{
                //     // await _setlan(sel_item);
                //     context.read<LanguageChangeProvider>().changeLocale("uz");
                //   },
                //   child: Text("Change lan"),
                // ),
                child: RadioGroup(

                  activeColor: Colors.blue,
                  fillColor: Colors.blue,
                  items: languages,
                  onChanged: (value) async {
                    print('Value: $value');
                    var sel_item = languages.indexOf(value);
                    final prefs = await SharedPreferences.getInstance();
                    await _setlan(sel_item);
                    if (sel_item == 0) {
                      context.read<LanguageChangeProvider>().changeLocale("en");
                    } else if (sel_item == 1) {
                      context.read<LanguageChangeProvider>().changeLocale("uz");
                    } else if (sel_item == 2) {
                      context.read<LanguageChangeProvider>().changeLocale("ru");
                    }
                  },
                  selectedItem: languages[snapshot.data ?? 0],
                  labelBuilder: (context, index) => Text(
                    languages[index],

                  style: TextStyle(color: Colors.black,fontSize: 20),
                  ),
                ),
              );
            }
          },
        ),
      ),
    );
  }
}