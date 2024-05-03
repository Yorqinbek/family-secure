import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:soqchi/add_child.dart';
import 'package:soqchi/components/dialogs.dart';

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
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.grey[200],
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
          centerTitle: true, // this is all you need
          title: Text("Yangi farzand"),
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
                                color: Colors.white,
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
                                color: Colors.white,
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
                      Column(
                        children: <Widget>[
                          ListTile(
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
                          ListTile(
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
                          ListTile(
                            title: const Text('Boshqa'),
                            leading: Radio<String>(
                              activeColor: Colors.blue,
                              value: 'boshqa',
                              groupValue: _gender,
                              onChanged: (value) {},
                            ),
                            onTap: () {
                              _handleGenderChange('boshqa');
                            },
                          ),
                        ],
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
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => AddChild(
                                      child_name: name,
                                    )));
                          }
                        },
                        child: Text(
                          "Davom etish",
                          style: TextStyle(color: Colors.white, fontSize: 18),
                        ),
                      )),
                ]),
          ),
        ));
  }
}
