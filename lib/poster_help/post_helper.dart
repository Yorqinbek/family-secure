import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/consts/app_consts.dart';
import 'dart:convert';

final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

Future<String> post_helper(Map data, String link) async {
  //chack bu kodni tekshirishku
  var url = Uri.parse(AppConstans.BASE_URL + link);

  //malumotlani jsonga moslashtirish
  var body = json.encode(data);
  try {
    var response = await http.post(url,
        headers: {"Content-Type": "application/json"}, body: body);
    print(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      return utf8.decode(response.bodyBytes);
    } else {
      return "Error";
    }
  } catch (e) {
    return "Error";
  }
}

Future<String> post_helper_token(Map data, String link, String token) async {
  //chack bu kodni tekshirishku
  var url = Uri.parse(AppConstans.BASE_URL + link);

  //malumotlani jsonga moslashtirish
  var body = json.encode(data);
  try {
    var response = await http.post(url,
        headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        },
        body: body);
    print(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      final Map response_json = json.decode(utf8.decode(response.bodyBytes));
      if (!response_json['status'] &&
          response_json['message'].toString().contains("Token expired")) {
        String response2 = await refresh_token(token);
        final Map response_json = json.decode(response2);
        if (response_json['status']) {
          print("token yangilandi.");
          final SharedPreferences prefs = await _prefs;
          prefs.setString('bearer_token', response_json['token']);
          String b =
              await post_helper_token(data, link, response_json['token']);
          return b;
        } else {
          String b =
              await post_helper_token(data, link, response_json['token']);
          return b;
        }
      } else {
        return utf8.decode(response.bodyBytes);
      }
      // print(utf8.decode(response.bodyBytes));
      // return utf8.decode(response.bodyBytes);
    } else {
      return "Error";
    }
  } catch (e) {
    return "Error";
  }
}

Future<String> get_helper(String link) async {
  //chack bu kodni tekshirishku
  var url = Uri.parse(AppConstans.BASE_URL + link);
  final SharedPreferences prefs = await _prefs;
  var token = prefs.getString('bearer_token') ?? '';
  print(token);
  //malumotlani jsonga moslashtirish
  try {
    var response = await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": 'Bearer $token',
    });
    print(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200) {
      final Map response_json = json.decode(utf8.decode(response.bodyBytes));
      if (!response_json['status'] &&
          response_json['message'].toString().contains("Token expired")) {
        print("refresh_token()");
        String response2 = await refresh_token(token);
        final Map response_json = json.decode(response2);
        print(response_json);
        if (response_json['status']) {
          print("token yangilandi.");
          final SharedPreferences prefs = await _prefs;
          prefs.setString('bearer_token', response_json['token']);
          String b = await get_helper(link);
          return b;
        } else {
          String b = await get_helper(link);
          return b;
        }
      } else {
        return utf8.decode(response.bodyBytes);
      }
      // print(utf8.decode(response.bodyBytes));
      // return utf8.decode(response.bodyBytes);
    } else {
      return "Error";
    }
  } catch (e) {
    return "Error";
  }
}

Future<String> refresh_token(String token) async {
  //chack bu kodni tekshirishku
  var url = Uri.parse(AppConstans.BASE_URL + "/refreshToken");

  try {
    var response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print(utf8.decode(response.bodyBytes));
      return utf8.decode(response.bodyBytes);
    } else {
      return "Error";
    }
  } catch (e) {
    return "Error";
  }
}
