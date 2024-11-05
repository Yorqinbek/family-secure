import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:soqchi/childs_list.dart';
import 'package:soqchi/login_otp.dart';
import 'package:soqchi/poster_help/post_helper.dart';
import 'dart:convert';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';
import 'screen/dash.dart';
import 'dart:io';
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

  final _scrollController = ScrollController();
  final GoogleSignIn _googleSignIn = GoogleSignIn();


  void _handleSignInSilently() async {
    await _googleSignIn.signInSilently();
  }


  Future<dynamic> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      final GoogleSignInAuthentication? googleAuth =
          await googleUser?.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth?.accessToken,
        idToken: googleAuth?.idToken,
      );

      return await FirebaseAuth.instance.signInWithCredential(credential);
    } catch (e) {
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
  void initState(){
    // TODO: implement initState
    super.initState();
    _handleSignInSilently();
    _scrollController.addListener(_onScroll);
  }


  @override
  void dispose() {
    _scrollController
      ..removeListener(_onScroll)
      ..dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_isNearBottom()) {
        setState(() {
          oferta = true;
        });
    }
  }

  bool _isNearBottom() {
    if (!_scrollController.hasClients || _scrollController.position.maxScrollExtent == 0) return false;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.offset;
    return currentScroll >= (maxScroll * 0.9);
  }

  Future<void> appleSign() async {
    try {


      // Requesting Apple Sign-In Credentials
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      // Constructing the OAuth Credential for Firebase
      final oauthCredential = OAuthProvider("apple.com").credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      context.loaderOverlay.show();
      // Signing in with Firebase using the Apple credentials
      UserCredential userCredential = await FirebaseAuth.instance.signInWithCredential(oauthCredential);

      // Checking if user is signed in successfully
      if (userCredential.user != null) {
        // Get user information
        final name = appleCredential.givenName != null
            ? appleCredential.givenName.toString()
            : appleCredential.familyName != null
            ? appleCredential.familyName.toString()
            : 'Name';
        var userEmail = userCredential.user!.email;
        var userId = userCredential.user!.uid;

        // Prepare data for backend
        Map<String, String> data = {
          'email': userEmail ?? '',
          'password': userId,
          'name': name,
        };

        // Make the backend request (assuming post_helper is defined elsewhere)
        var response = await post_helper(data, '/register');

        if (response != "Error") {
          var responseData = jsonDecode(response);

          if (responseData['status'] ||
              responseData['message'].toString().contains('The email has already been taken.')) {
            // Storing necessary info in SharedPreferences
            final SharedPreferences prefs = await SharedPreferences.getInstance();
            prefs.setBool("regstatus", true);
            prefs.setString("email", userEmail ?? '');
            prefs.setString("uid", userId);
            prefs.setString("tarif", "free");

            // Navigate to Dashboard if successful
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) {
              return DashboardPage();  // Assuming DashboardPage is defined
            }));
          } else {
            print("Registration failed: ${responseData['message']}");
          }
        } else {
          print("Error in backend response");
        }
      }
      else{
        Fluttertoast.showToast(
            msg: "Apple sign error! Try again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,

            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    } catch (e) {
      // Catching and printing error for debugging
      print("Error during Apple sign-in: $e");

      // Optionally handle specific error cases
      if (e is FirebaseAuthException) {
        switch (e.code) {
          case 'account-exists-with-different-credential':
            print('Account exists with a different credential');
            break;
          case 'invalid-credential':
            print('The credential is invalid.');
            break;
          case 'operation-not-allowed':
            print('Apple sign-in is not enabled in Firebase console.');
            break;
          case 'internal-error':
            print('Internal Firebase error: ${e.message}');
            break;
          default:
            print('Unhandled FirebaseAuthException: ${e.message}');
        }
      }
    }
    context.loaderOverlay.hide();
  }

  Future<void> google_sign() async {

    context.loaderOverlay.show();
    userCredential.value = await signInWithGoogle();
    if (userCredential.value != null) {
      // print(userCredential.value);
      var user_email = userCredential.value.user!.email;
      var name = userCredential.value.user!.displayName;
      var user_id = userCredential.value.user!.uid;
      Map data = {'email': user_email, 'password': user_id, 'name': name};
      var response = await post_helper(data, '/register');
      if (response != "Error") {
        var data = jsonDecode(response);
        // final Map parsed = json.decode(response);

        if (data['status'] ||
            data['message']
                .toString()
                .contains('The email has already been taken.')) {
          final SharedPreferences prefs = await _prefs;
          prefs.setBool("regstatus", true);
          prefs.setString("email", user_email);
          prefs.setString("uid", user_id);
          prefs.setString("tarif", "free");
          Navigator.pushReplacement(context,
              MaterialPageRoute(builder: (context) {
            return DashboardPage();
          }));
        }
      }
      else{
        Fluttertoast.showToast(
            msg: "Server connection error! Try again",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 1,

            backgroundColor: Colors.red,
            textColor: Colors.white,
            fontSize: 16.0
        );
      }
    }
    else{
      Fluttertoast.showToast(
          msg: "Google sign error! Try again",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 1,

          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0
      );
    }
    context.loaderOverlay.hide();
  }

  Future<void> _launchUrl() async {
    final Uri _url = Uri.parse('https://bbpro.me');
    if (!await launchUrl(_url)) {
      throw Exception('Could not launch $_url');
    }
  }

  bool oferta = false;
  bool oferta2 = false;

  @override
  Widget build(BuildContext context) {
    final TextEditingController controller = TextEditingController();
    String initialCountry = 'UZ';
    PhoneNumber number = PhoneNumber(isoCode: 'UZ');

    return Scaffold(
        backgroundColor: Colors.white,
        body: SafeArea(
            child: LoaderOverlay(
              child: ValueListenableBuilder(
                  valueListenable: userCredential,
                  builder: (context, value, child) {
                    return (userCredential.value == '' ||
                            userCredential.value == null)
                        ? Padding(
                            padding: EdgeInsets.all(20.0),
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
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppLocalizations.of(context)!.login_title,
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 28,
                                          ),
                                        ),
                                        SizedBox(
                                          height: 15,
                                        ),
                                        Text(
                                          AppLocalizations.of(context)!.login_subtitle,                                        style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                Image.asset('assets/images/sign.jpg'),
                                // Expanded(
                                //   child: Markdown(
                                //     controller: _scrollController,
                                //     selectable: true,
                                //     styleSheet: MarkdownStyleSheet(
                                //       p: TextStyle(fontSize: 16)
                                //     ),
                                //     data: 'Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.Contrary to popular belief, Lorem Ipsum is not simply random text. It has roots in a piece of classical Latin literature from 45 BC, making it over 2000 years old. Richard McClintock, a Latin professor at Hampden-Sydney College in Virginia, looked up one of the more obscure Latin words, consectetur, from a Lorem Ipsum passage, and going through the cites of the word in classical literature, discovered the undoubtable source. Lorem Ipsum comes from sections 1.10.32 and 1.10.33 of "de Finibus Bonorum et Malorum" (The Extremes of Good and Evil) by Cicero, written in 45 BC. This book is a treatise on the theory of ethics, very popular during the Renaissance. The first line of Lorem Ipsum, "Lorem ipsum dolor sit amet..", comes from a line in section 1.10.32.',
                                //   ),
                                // ),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Checkbox(
                                            activeColor: Colors.blue,
                                            value: oferta,
                                        onChanged: (value){
                                              if(!oferta){
                                                showModalBottomSheet(
                                                    backgroundColor: Colors.white,
                                                    enableDrag: true,
                                                    isDismissible: true,
                                                    context: context,
                                                    isScrollControlled: true,
                                                    showDragHandle: true,
                                                    builder: (context) {
                                                      return FractionallySizedBox(
                                                        heightFactor: 0.9,
                                                        child: Markdown(
                                                          controller: _scrollController,
                                                          selectable: true,
                                                          styleSheet: MarkdownStyleSheet(
                                                              p: TextStyle(fontSize: 16)
                                                          ),
                                                          data:AppLocalizations.of(context)!.privacy_policy,
                                                          ),
                                                      );
                                                    });
                                              }
                                              else{
                                                setState(() {
                                                  oferta = value!;
                                                });
                                              }
                                        },
                                        // onChanged: (value){
                                        //     setState(() {
                                        //       oferta = value!;
                                        //     });
                                        // }),
                                        ),
                                        Container(
                                          // onPressed: ()async{
                                          //   await _launchUrl();
                                          // },
                                          child: Text(AppLocalizations.of(context)!.oferta,
                                          style: TextStyle(
                                              color: Colors.blue, fontSize: 14),
                                          )
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Platform.isIOS ? SizedBox():Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.9,
                                        height:
                                            MediaQuery.of(context).size.height *
                                                0.07,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor: oferta ?  MaterialStateProperty.all(
                                            Colors.blueAccent):MaterialStateProperty.all(
                                                Colors.grey),
                                            // backgroundColor: next_btn == true
                                            //     ? MaterialStateProperty.all(
                                            //         Colors.blueAccent)
                                            //     : MaterialStateProperty.all(
                                            //         Colors.grey),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    15), // radius of the corners
                                              ),
                                            ),
                                          ),
                                          // onPressed: next_btn == true
                                          //     ? () => send_phone(phone_number)
                                          //     : () {},
                                          onPressed: oferta ? () async{
                                            await google_sign();
                                          } : null,
                                          child: Text(
                                            AppLocalizations.of(context)!.login_button,
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 18),
                                          ),
                                        )),
                                    SizedBox(
                                      height: 15,
                                    ),
                                    Platform.isIOS ?
                                    Container(
                                        width: MediaQuery.of(context).size.width *
                                            0.9,
                                        height:
                                        MediaQuery.of(context).size.height *
                                            0.07,
                                        child: ElevatedButton(
                                          style: ButtonStyle(
                                            backgroundColor: oferta ?  MaterialStateProperty.all(
                                                Colors.blueAccent):MaterialStateProperty.all(
                                                Colors.grey),
                                            // backgroundColor: next_btn == true
                                            //     ? MaterialStateProperty.all(
                                            //         Colors.blueAccent)
                                            //     : MaterialStateProperty.all(
                                            //         Colors.grey),
                                            shape: MaterialStateProperty.all<
                                                RoundedRectangleBorder>(
                                              RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    15), // radius of the corners
                                              ),
                                            ),
                                          ),
                                          // onPressed: next_btn == true
                                          //     ? () => send_phone(phone_number)
                                          //     : () {},
                                          onPressed: oferta ? () async{
                                            await appleSign();
                                          } : null,
                                          child: Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              Icon(Icons.apple,color: Colors.black,size: 30,),
                                              SizedBox(width: 2,),
                                              Text(
                                                AppLocalizations.of(context)!.login_button_apple,
                                                style: TextStyle(
                                                    color: Colors.white,
                                                    fontSize: 18),
                                              ),
                                            ],
                                          ),
                                        )):SizedBox(),
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
                  }),
            )));
  }
}
