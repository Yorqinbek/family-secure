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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          centerTitle: true, // this is all you need
          title: Text("Новый ребенок"),
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
                      Text(
                        "Введите имя вашего ребенка",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.03,
                      ),
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
                                          hintText: "Например: Анвар"
                                          // labelText: 'Email',
                                          ))))),
                    ],
                  ),
                  Padding(
                      padding: const EdgeInsets.all(10),
                      child: Container(
                        height: 50,
                        width: double.infinity,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                                borderRadius: new BorderRadius.circular(18.0),
                                side: BorderSide(color: Colors.green)),
                          ),
                          onPressed: () {
                            if (_nameController.text.isEmpty) {
                              MyCustomDialogs.error_dialog_custom(context,
                                  "Пожалуйста, введите имя вашего ребенка");
                            } else {
                              String name = _nameController.text.toString();
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (context) => AddChild(
                                        child_name: name,
                                      )));
                            }
                          },
                          child: Text(
                            'Продолжать',
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                      )),
                ]),
          ),
        ));
  }
}
