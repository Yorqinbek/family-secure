import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:material_dialogs/dialogs.dart';
import 'package:material_dialogs/shared/types.dart';
import 'package:material_dialogs/widgets/buttons/icon_button.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:soqchi/add_child.dart';
import 'package:soqchi/bloc/dash/dash_bloc.dart';
import 'package:soqchi/components/dialogs.dart';
import 'package:url_launcher/url_launcher.dart';

import '../widgets/loadingwidget.dart';
import '../widgets/upgradewidget.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddChildName extends StatefulWidget {
  const AddChildName({super.key});

  @override
  State<AddChildName> createState() => _AddChildNameState();
}

class _AddChildNameState extends State<AddChildName> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _oldController = TextEditingController();
  TextEditingController txt = TextEditingController();
  String _gender = 'ogil';

  void _handleGenderChange(String value) {
    setState(() {
      _gender = value;
    });
  }
  @override
  void initState(){
    // TODO: implement initState
    super.initState();
    BlocProvider.of<DashBloc>(context).add(DashLoadingData());

  }

  Future<void> open_website() async {
    final Uri _url = Uri.parse('https://bbpro.me/templates/template31/index.html');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true, // this is all you need
          title: Text(AppLocalizations.of(context)!.new_child,),
          // actions: [
          //   IconButton(onPressed: ()async{
          //     await open_website();
          //   }, icon: Icon(Icons.info,color: Colors.blue,))
          // ],
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),

        ),
        body: SafeArea(
    child:BlocBuilder<DashBloc, DashState>(
  builder: (context, state) {
    if (state is DashSuccess || state is DashEmpty) {
      return SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    // Text(
                    //   "Farzandim haqida ma`lumot",
                    //   style: TextStyle(
                    //       fontSize: 18, fontWeight: FontWeight.bold),
                    // ),
                    // SizedBox(
                    //   height: MediaQuery.of(context).size.height * 0.03,
                    // ),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(

                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 5),
                                child: TextFormField(
                                    controller: _nameController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: AppLocalizations.of(context)!.child_name_info,
                                      // labelText: 'Email',
                                    ))))),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[200],
                              borderRadius: new BorderRadius.circular(10.0),
                            ),
                            child: Padding(
                                padding: EdgeInsets.only(
                                    left: 15, right: 15, top: 5),
                                child: TextFormField(
                                    keyboardType: TextInputType.number,
                                    controller: _oldController,
                                    decoration: InputDecoration(
                                        border: InputBorder.none,
                                        hintText: AppLocalizations.of(context)!.child_old_info,
                                      // labelText: 'Email',
                                    ))))),
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        children: <Widget>[
                          ListTile(
                            // tileColor: Colors.grey[200],
                            title: Text(AppLocalizations.of(context)!.boy,),
                            leading: Radio<String>(
                              activeColor: Colors.blue,
                              value: 'ogil',
                              groupValue: _gender,
                              onChanged: (value) {},
                            ),
                            onTap: () {
                              _handleGenderChange('ogil');
                            },
                          ),
                          SizedBox(
                            height: 10,
                          ),
                          ListTile(
                            // tileColor: Colors.grey[200],
                            title:  Text(AppLocalizations.of(context)!.girl_s,),
                            leading: Radio<String>(
                              activeColor: Colors.blue,
                              value: 'qiz',
                              groupValue: _gender,
                              onChanged: (value) {},
                            ),
                            onTap: () {
                              _handleGenderChange('qiz');
                            },
                          ),
                          // ListTile(
                          //   title: const Text('Boshqa'),
                          //   leading: Radio<String>(
                          //     activeColor: Colors.blue,
                          //     value: 'boshqa',
                          //     groupValue: _gender,
                          //     onChanged: (value) {},
                          //   ),
                          //   onTap: () {
                          //     _handleGenderChange('boshqa');
                          //   },
                          // ),
                        ],
                      ),
                    ),
                    Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: [
                            Text(AppLocalizations.of(context)!.download_child_app_text),
                            TextButton(
                              onPressed: (){
                                txt.text = "https://bbpro.me/templates/template31/img/Family-Secure-Child.apk";
                                Dialogs.materialDialog(
                                    color: Colors.white,
                                    msg: AppLocalizations.of(context)!.download_child_app_info,
                                    titleAlign: TextAlign.center,
                                    title: AppLocalizations.of(context)!.download_child_app_title,
                                    onClose: (a){

                                    },
                                    customView: Column(
                                      children: [
                                        QrImageView(
                                          data: 'https://bbpro.me/templates/template31/img/Family-Secure-Child.apk',
                                          version: QrVersions.auto,
                                          size: 200.0,
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: TextField(
                                            controller: txt,
                                            decoration:  InputDecoration(
                                                border:const OutlineInputBorder(),
                                                suffixIcon: GestureDetector(
                                                    onTap: (){
                                                      Clipboard.setData(ClipboardData(text: txt.text));
                                                    },
                                                    child: Icon(Icons.copy))
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    customViewPosition: CustomViewPosition.BEFORE_ACTION,
                                    context: context,
                                    actions: [
                                      IconsButton(
                                        onPressed: () {
                                          Navigator.pop(context);
                                        },
                                        text: 'Ok',
                                        iconData: Icons.done,
                                        color: Colors.blue,
                                        textStyle: TextStyle(color: Colors.white),
                                        iconColor: Colors.white,
                                      ),
                                    ]);
                              },
                              child: Text(AppLocalizations.of(context)!.download_child_app_title,style: TextStyle(fontWeight: FontWeight.bold),),
                            ),
                          ],
                        )
                    ),
                  ],
                ),
                Container(
                    width: MediaQuery.of(context).size.width * 0.9,
                    height: MediaQuery.of(context).size.height * 0.07,
                    child: ElevatedButton(
                      style: ButtonStyle(
                        backgroundColor:
                        MaterialStateProperty.all(Colors.blueAccent),
                        shape:
                        MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                                15), // radius of the corners
                          ),
                        ),
                      ),
                      onPressed: () {
                        if (_nameController.text.isEmpty) {
                          MyCustomDialogs.my_infodialog(
                              context, AppLocalizations.of(context)!.text_error,);
                        } else if (_oldController.text.isEmpty) {
                          MyCustomDialogs.my_infodialog(
                              context, AppLocalizations.of(context)!.text_error,);
                        } else {
                          String name = _nameController.text.toString();
                          var jins = 0;
                          if (_gender.contains("ogil")){
                            jins = 1;
                          }
                          else if(_gender.contains("boshqa")){
                            jins = 2;
                          }
                          else{
                            jins = 0;
                          }
                          int yoshi = int.parse(_oldController.text.toString());
                          Navigator.of(context).push(MaterialPageRoute(
                              builder: (context) => AddChild(
                                child_name: name,
                                jins: jins,
                                old: yoshi,
                              )));
                        }
                      },
                      child: Text(
            AppLocalizations.of(context)!.next,
                        style: TextStyle(color: Colors.white, fontSize: 18),
                      ),
                    )),
              ]),
        ),
      );
    }
    if(state is DashError){
      return SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(height: MediaQuery.of(context).size.height*0.3,),
            Center(
              child: Text(AppLocalizations.of(context)!.server_error,style: TextStyle(fontSize: 16),),
            )
          ]
          )
      );
    }
    if(state is DashExpired){
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          UpgradeWidget(),
        ],
      );
    }
  return    LoadingWidget();
  },
),
        ));
  }
}
