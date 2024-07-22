import 'package:flutter/material.dart';

class MyCustomDialogs {
  static void error_dialog_custom(BuildContext context, String message) {
    var snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void error_network(BuildContext context) {
    var snackBar = SnackBar(
      backgroundColor: Colors.red,
      content: Text(
        "Serverga ulanishda xatolik! Qayta urunib ko'ring",
        style: TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void success_dialog_custom(BuildContext context, String message) {
    var snackBar = SnackBar(
      backgroundColor: Colors.green,
      content: Text(
        message,
        style: TextStyle(color: Colors.white),
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static Widget my_loading() {
    return Scaffold(
      body: Center(
          child: Padding(
        padding: const EdgeInsets.all(30.0),
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      )),
    );
  }

  static Widget server_conn_err(){
    return
          Center(
            child: Text("Ошибка подключения к серверу!",style: TextStyle(fontSize: 16),),
          );
  }

  static Widget LoadingWidget(){
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(4.0),
        child: SizedBox(
          height: 30,
          width: 30,
          child: CircularProgressIndicator(),
        ),
      ),
    );
  }

  static my_showAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.transparent,
          // <-- SEE HERE
          content: Center(
              child: CircularProgressIndicator(
            color: Colors.black,
          )),
        );
      },
    );
  }

  static my_infodialog(BuildContext context, String message) {
    showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.white,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30.0)), //this right here
            child: Container(
              color: Colors.white,
              height: MediaQuery.of(context).size.height * 0.25,
              width: MediaQuery.of(context).size.width * 0.8,
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        SizedBox(
                          height: 10,
                        ),
                        Text(
                          message,
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * 0.1,
                    ),
                    Column(
                      children: [
                        Divider(),
                        SizedBox(
                          height: 5,
                        ),
                        InkWell(
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            "Ok",
                            style: TextStyle(
                                fontSize: 16,
                                color: Colors.blue,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          );
        });

    // set up the button
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // // set up the AlertDialog
    // AlertDialog alert = AlertDialog(
    //   // title: Text("My title"),
    //   content: Text(message),
    //   actions: [
    //     okButton,
    //   ],
    // );

    // // show the dialog
    // showDialog(
    //   context: context,
    //   builder: (BuildContext context) {
    //     return alert;
    //   },
    // );
  }
}
