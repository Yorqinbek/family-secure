import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/childs_list.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
            child: ValueListenableBuilder(
                valueListenable: userCredential,
                builder: (context, value, child) {
                  return (userCredential.value == '' ||
                          userCredential.value == null)
                      ? Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                "Sign up",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.05,
                              ),
                              Text(
                                "Lorem ipsum doler set amet lorem ipsum doler set amet",
                                style: TextStyle(
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                              ),
                              SizedBox(
                                height:
                                    MediaQuery.of(context).size.height * 0.25,
                              ),
                              Container(
                                  width:
                                      MediaQuery.of(context).size.width * 0.6,
                                  height:
                                      MediaQuery.of(context).size.height * 0.07,
                                  child: ElevatedButton(
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                      shape: MaterialStateProperty.all<
                                          RoundedRectangleBorder>(
                                        RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                              20), // radius of the corners
                                        ),
                                      ),
                                    ),
                                    onPressed: () async {
                                      // var a = await signInWithGoogle();
                                      userCredential.value =
                                          await signInWithGoogle();
                                      if (userCredential.value != null) {
                                        // print(userCredential.value);
                                        var user_email =
                                            userCredential.value.user!.email;
                                        var name = userCredential
                                            .value.user!.displayName;
                                        var user_id =
                                            userCredential.value.user!.uid;
                                        Map data = {
                                          'email': user_email,
                                          'password': user_id,
                                          'name': name
                                        };
                                        var response = await post_helper(
                                            data, '/register');
                                        if (response != "Error") {
                                          var data = jsonDecode(response);
                                          print(data);
                                          // final Map parsed = json.decode(response);

                                          if (data['status'] ||
                                              data['message'].toString().contains(
                                                  'The email has already been taken.')) {
                                            final SharedPreferences prefs =
                                                await _prefs;
                                            prefs.setBool("regstatus", true);
                                            prefs.setString(
                                                "email", user_email);
                                            prefs.setString("uid", user_id);
                                            Navigator.pushReplacement(context,
                                                MaterialPageRoute(
                                                    builder: (context) {
                                              return ChildListPage();
                                            }));
                                          }
                                        }
                                      }
                                    },
                                    child: Text(
                                      "Google",
                                      style: TextStyle(
                                          color: Colors.white, fontSize: 18),
                                    ),
                                  )),
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
