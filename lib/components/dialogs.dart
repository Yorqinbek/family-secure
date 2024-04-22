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

  static my_showAlertDialog(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
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
}
