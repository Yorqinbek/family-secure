import 'dart:convert';
import 'dart:developer';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/components/dialogs.dart';
import 'package:soqchi/childs_list.dart';
import 'package:soqchi/screen/dash.dart';
import 'package:soqchi/poster_help/post_helper.dart';

class AddChild extends StatefulWidget {
  final String child_name;
  final int old;
  final int jins;
  const AddChild({super.key, required this.child_name,required this.old,required this.jins});

  @override
  State<AddChild> createState() => _AddChildState();
}

class _AddChildState extends State<AddChild> {
  Barcode? result;
  QRViewController? controller;
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  @override
  void reassemble() {
    super.reassemble();
    if (Platform.isAndroid) {
      controller!.pauseCamera();
    }
    controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(flex: 4, child: _buildQrView(context)),
        ],
      ),
    );
  }

  Widget _buildQrView(BuildContext context) {
    // For this example we check how width or tall the device is and change the scanArea and overlay accordingly.
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 200.0
        : 300.0;
    // To ensure the Scanner view is properly sizes after rotation
    // we need to listen for Flutter SizeChanged notification and update controller
    return QRView(
      key: qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
          borderColor: Colors.black,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: scanArea),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      this.controller = controller;
    });
    controller.scannedDataStream.listen((scanData) async {
      setState(() {
        result = scanData;
        controller.pauseCamera();
      });
      final SharedPreferences prefs = await _prefs;
      var token = prefs.getString("bearer_token") ?? "";
      Map data = {
        'chid': result!.code,
        'chname': widget.child_name,
        'jins':widget.jins,
        'old':widget.old
      };
      var response = await post_helper_token(data, '/addchild', token);
      if (response != "Error") {
        final Map response_json = json.decode(response);
        if (response_json['status']) {
          MyCustomDialogs.success_dialog_custom(
              context, "Добавлен новый ребенок!");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return DashboardPage();
          }));
        } else {
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return DashboardPage();
          }));
          MyCustomDialogs.error_dialog_custom(
              context, "Пользователь с данным qr-кодом не найден!");
        }
      } else {
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) {
          return DashboardPage();
        }));
        MyCustomDialogs.error_dialog_custom(
            context, "Ошибка подключения к серверу. Попробуйте еще раз!");
      }
    });
  }

  void _onPermissionSet(BuildContext context, QRViewController ctrl, bool p) {
    log('${DateTime.now().toIso8601String()}_onPermissionSet $p');
    if (!p) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('no Permission')),
      );
    }
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
