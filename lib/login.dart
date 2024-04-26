import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/childs_list.dart';
import 'package:soqchi/login_otp.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'dart:convert';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  ValueNotifier userCredential = ValueNotifier('');
  final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  bool isvalidate = false;

  bool next_btn = false;

  String phone_number = "";

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

  Future<void> send_phone(String phone_number) async {
    Navigator.push(context, MaterialPageRoute(builder: (context) {
      return LoginOtpPage(
        phone_number: phone_number,
      );
    }));

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
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String initialCountry = 'UZ';
    PhoneNumber number = PhoneNumber(isoCode: 'UZ');

    return Scaffold(
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
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.05,
                                  ),
                                  Column(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Telefon raqamingizni kiriting",
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 28,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 15,
                                      ),
                                      Text(
                                        "Bu tizimga kirishingiz uchun zarur",
                                        style: TextStyle(
                                          fontSize: 16,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: MediaQuery.of(context).size.height *
                                        0.1,
                                  ),
                                  InternationalPhoneNumberInput(
                                    countries: ["UZ"],
                                    autoFocus: true,
                                    onInputChanged: (PhoneNumber number) {
                                      print(number.phoneNumber);
                                      print(number.phoneNumber!.length);
                                      print(isvalidate);
                                      if (number.phoneNumber!.length == 13 &&
                                          isvalidate) {
                                        setState(() {
                                          phone_number = number.phoneNumber!;
                                          next_btn = true;
                                        });
                                      } else {
                                        setState(() {
                                          next_btn = false;
                                        });
                                      }
                                    },
                                    onInputValidated: (bool value) {
                                      print(value);
                                      setState(() {
                                        isvalidate = true;
                                      });
                                    },
                                    selectorConfig: SelectorConfig(
                                      selectorType:
                                          PhoneInputSelectorType.BOTTOM_SHEET,
                                    ),
                                    hintText: "Telefon raqamingiz",
                                    ignoreBlank: false,
                                    autoValidateMode: AutovalidateMode.disabled,
                                    selectorTextStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    textStyle: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold),
                                    initialValue: number,
                                    textFieldController: controller,
                                    formatInput: true,
                                    keyboardType:
                                        TextInputType.numberWithOptions(
                                            signed: true, decimal: true),
                                    // inputBorder: OutlineInputBorder(),
                                    inputBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide: BorderSide.none),

                                    onSaved: (PhoneNumber number) {
                                      // number.toString()
                                      // print(number.toString());
                                      // print('On Saved: $number');
                                    },
                                  ),
                                ],
                              ),
                              Column(
                                children: [
                                  Text(
                                    "Davom etish tugmasini bosish orqali siz ommaviy oferta shartlariga roziligingizni bildirasiz",
                                    style: TextStyle(
                                        color: Colors.grey, fontSize: 12),
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
                                          backgroundColor: next_btn == true
                                              ? MaterialStateProperty.all(
                                                  Colors.blueAccent)
                                              : MaterialStateProperty.all(
                                                  Colors.grey),
                                          shape: MaterialStateProperty.all<
                                              RoundedRectangleBorder>(
                                            RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(
                                                  15), // radius of the corners
                                            ),
                                          ),
                                        ),
                                        onPressed: next_btn == true
                                            ? () => send_phone(phone_number)
                                            : () {},
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
