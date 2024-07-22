import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:soqchi/add_child.dart';
import 'package:soqchi/bloc/dash/dash_bloc.dart';
import 'package:soqchi/components/dialogs.dart';

import '../widgets/loadingwidget.dart';
import '../widgets/upgradewidget.dart';

class AddChildName extends StatefulWidget {
  const AddChildName({super.key});

  @override
  State<AddChildName> createState() => _AddChildNameState();
}

class _AddChildNameState extends State<AddChildName> {
  TextEditingController _nameController = TextEditingController();
  TextEditingController _oldController = TextEditingController();
  String _gender = 'ogil';

  void _handleGenderChange(String value) {
    setState(() {
      _gender = value;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    BlocProvider.of<DashBloc>(context).add(DashLoadingData());

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          centerTitle: true, // this is all you need
          title: Text("Yangi farzand"),
          actions: [
            IconButton(onPressed: (){}, icon: Icon(Icons.info,color: Colors.blue,))
          ],
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
      return Container(
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
                            color: Colors.grey[100],
                            borderRadius: new BorderRadius.circular(10.0),
                          ),
                          child: Padding(
                              padding: EdgeInsets.only(
                                  left: 15, right: 15, top: 5),
                              child: TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                      border: InputBorder.none,
                                      hintText: "Ismi: Anvar"
                                    // labelText: 'Email',
                                  ))))),
                  Padding(
                      padding: EdgeInsets.all(10),
                      child: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey[100],
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
                                      hintText: "Yoshi: 14"
                                    // labelText: 'Email',
                                  ))))),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: <Widget>[
                        ListTile(
                          tileColor: Colors.grey[100],
                          title: const Text('O`gil'),
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
                          tileColor: Colors.grey[100],
                          title: const Text('Qiz'),
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
                            context, "Barcha maydonlarni to'ldiring!");
                      } else if (_oldController.text.isEmpty) {
                        MyCustomDialogs.my_infodialog(
                            context, "Barcha maydonlarni to'ldiring!");
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
                      "Davom etish",
                      style: TextStyle(color: Colors.white, fontSize: 18),
                    ),
                  )),
            ]),
      );
    }
    if(state is DashError){
      return SliverList(
          delegate: SliverChildListDelegate([
            SizedBox(height: MediaQuery.of(context).size.height*0.3,),
            Center(
              child: Text("Ошибка подключения к серверу!",style: TextStyle(fontSize: 16),),
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
