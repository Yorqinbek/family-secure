import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';
import 'package:flutter_timer_countdown/flutter_timer_countdown.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/childs_list.dart';
import 'package:soqchi/components/dialogs.dart';
import 'package:soqchi/dash.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'dart:convert';

import 'package:soqchi/register.dart';

class LoginOtpPage extends StatefulWidget {
  final String phone_number;
  const LoginOtpPage({super.key, required this.phone_number});

  @override
  State<LoginOtpPage> createState() => _LoginOtpPageState();
}

class _LoginOtpPageState extends State<LoginOtpPage> {
  ValueNotifier userCredential = ValueNotifier('');
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  String otp = "";
  bool resend_code = false;


  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } on Exception catch (e) {
      // TODO
      print('exception->$e');
    }
  }

  Future<bool> signOutFromGoogle() async {
    try {
      await FirebaseAuth.instance.signOut();
      return true;
    } on Exception catch (_) {
      return false;
    }
  }

  Future<void> send_otp() async {
    MyCustomDialogs.my_showAlertDialog(context);
    Map data = {
      'otp': otp.toString(),
      'phone':widget.phone_number
    };
    final SharedPreferences prefs = await _prefs;
    print(data);
    var response = await post_helper(data, '/otp');
    if (response != "Error") {
      final Map response_json = json.decode(response);
      if (response_json['status']) {
        if(response_json['regstatus']){
          prefs.setBool("regstatus", true);
          prefs.setString("phone", widget.phone_number);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
                return DashboardPage();
              }));
        }
        else{
          Navigator.pop(context);
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
                return RegisterPage(
                  phone_number: widget.phone_number,
                );
              }));
        }
        print("Togri");
      } else {
        Navigator.pop(context);
        if (response_json['message'].toString().contains("Otp incorrect")) {
          MyCustomDialogs.error_dialog_custom(context,
              "Tekshirish kodi noto`g`ri! Iltimos tekshirib qayta tering.");
        } else {
          MyCustomDialogs.error_network(context);
        }
      }
    } else {
      Navigator.pop(context);
      MyCustomDialogs.error_network(context);
    }
    print(otp);
    // userCredential.value = await signInWithGoogle();
    // if (userCredential.value != null) {
    //   // print(userCredential.value);
    //   var user_email = userCredential.value.user!.email;
    //   var name = userCredential.value.user!.displayName;
    //   var user_id = userCredential.value.user!.uid;
    //   Map data = {'email': user_email, 'password': user_id, 'name': name};
    //   var response = await post_helper(data, '/register');
    //   if (response != "Error") {
    //     var data = jsonDecode(response);
    //     print(data);
    //     // final Map parsed = json.decode(response);

    //     if (data['status'] ||
    //         data['message']
    //             .toString()
    //             .contains('The email has already been taken.')) {
    //       final SharedPreferences prefs = await _prefs;
    //       prefs.setBool("regstatus", true);
    //       prefs.setString("email", user_email);
    //       prefs.setString("uid", user_id);
    //       Navigator.pushReplacement(context,
    //           MaterialPageRoute(builder: (context) {
    //         return ChildListPage();
    //       }));
    //     }
    //   }
    // }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String initialCountry = 'UZ';
    PhoneNumber number = PhoneNumber(isoCode: 'UZ');

    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.grey[200],
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
        backgroundColor: Colors.grey[200],
        body: SafeArea(
            child: ValueListenableBuilder(
                valueListenable: userCredential,
                builder: (context, value, child) {
                  return (userCredential.value == '' ||
                          userCredential.value == null)
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                children: [
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Sms kodni kiriting",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        widget.phone_number.substring(
                                                0,
                                                widget.phone_number.length -
                                                    4) +
                                            ' ** **' +
                                            " raqamga kod yuborildi",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.12,
                                  ),
                                  OtpTextField(
                                    textStyle: TextStyle(fontSize: 25),
                                    autoFocus: true,
                                    numberOfFields: 5,
                                    borderWidth: 4,
                                    enabledBorderColor: Colors.grey,
                                    borderColor: Colors.blue,
                                    onCodeChanged: (String code) {
                                      //handle validation or checks here
                                    },
                                    //runs when every textfield is filled
                                    onSubmit: (String verificationCode) {
                                      setState(() {
                                        otp = verificationCode;
                                      });
                                      send_otp();
                                      // showDialog(
                                      //     context: context,
                                      //     builder: (context) {
                                      //       return AlertDialog(
                                      //         title: Text("Verification Code"),
                                      //         content: Text(
                                      //             'Code entered is $verificationCode'),
                                      //       );
                                      //     });
                                    }, // end onSubmit
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  resend_code
                                      ? Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            InkWell(
                                              onTap: () {
                                                setState(() {
                                                  resend_code = false;
                                                });
                                              },
                                              child: Text(
                                                "Qayta jo'natish",
                                                style: TextStyle(
                                                    color: Colors.blueAccent),
                                              ),
                                            ),
                                          ],
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TimerCountdown(
                                              timeTextStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                              enableDescriptions: false,
                                              spacerWidth: 2,
                                              format: CountDownTimerFormat
                                                  .minutesSeconds,
                                              endTime: DateTime.now().add(
                                                Duration(
                                                  minutes: 3,
                                                  seconds: 0,
                                                ),
                                              ),
                                              onEnd: () {
                                                print("Timer finished");
                                                setState(() {
                                                  resend_code = true;
                                                });
                                              },
                                            ),
                                            Text(
                                              "  dan so'ng qayta yuborish",
                                              style: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize: 16),
                                            ),
                                          ],
                                        ),
                                  SizedBox(
                                    height: 15,
                                  ),
                                  Container(
                                      width: MediaQuery.of(context).size.width *
                                          0.9,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.07,
                                      child: ElevatedButton(
                                        style: ButtonStyle(
                                          backgroundColor:
                                              MaterialStateProperty.all(
                                                  Colors.blueAccent),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  15), // radius of the corners
                                            ),
                                          ),
                                        ),
                                        onPressed: send_otp,
                                        child: Text(
                                          "Davom etish",
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 18),
                                        ),
                                      )),
                                ],
                              ),
                            ],
                          ),
                        )
                      : Container(
                          child: Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                })));
  }
}
