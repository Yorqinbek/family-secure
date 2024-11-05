import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:soqchi/api/child_app_list_model.dart';
import 'package:soqchi/api/child_app_usage_list_model.dart';
import 'package:soqchi/api/child_call_list_model.dart';
import 'package:soqchi/api/child_contact_model.dart';
import 'package:soqchi/api/child_info_model.dart';
import 'package:soqchi/api/child_location_list_model.dart';
import 'package:soqchi/api/child_model.dart';
import 'package:soqchi/api/child_notification_model.dart';
import 'package:soqchi/api/child_sms_info_model.dart';
import 'package:soqchi/api/child_sms_list_model.dart';
import 'package:soqchi/api/child_web_block_list_model.dart';
import 'package:soqchi/api/user_model.dart';

import '../consts/app_consts.dart';
import '../poster_help/post_helper.dart';
import 'package:http/http.dart' as http;
class ParentRepository{

  Future<void> savePostToLocal(Map<String, dynamic> postData) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve existing posts from SharedPreferences
    String? postsString = prefs.getString('savedPosts');
    List<dynamic> posts = postsString != null ? json.decode(postsString) : [];

    // Add the new post to the list
    posts.add(postData);

    // Save the updated list back to SharedPreferences
    prefs.setString('savedPosts', json.encode(posts));
  }

  Future<List<dynamic>> getSavedPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? postsString = prefs.getString('savedPosts');
    List<dynamic> posts = postsString != null ? json.decode(postsString) : [];
    return posts;
  }

  Future<void> postSavedPosts() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Retrieve saved posts from SharedPreferences
    String? postsString = prefs.getString('savedPosts');
    List<dynamic> posts = postsString != null ? json.decode(postsString) : [];

    // Check if there are any posts to send
    if (posts.isEmpty) {
      print("No saved posts to send.");
      return;
    }

    List<dynamic> successfullyPosted = [];

    for (var post in posts) {
      if(await set_tarif2(post)){
        successfullyPosted.add(post);
      }

    }

    // Remove successfully posted items from the original list
    posts.removeWhere((post) => successfullyPosted.contains(post));

    // Update SharedPreferences with remaining (failed) posts
    if (posts.isEmpty) {
      prefs.remove('savedPosts'); // Clear if all posts were successful
    } else {
      prefs.setString('savedPosts', json.encode(posts));
    }
  }

  Future<bool> set_tarif2(Map<String,dynamic> data)async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    var url = Uri.parse(AppConstans.BASE_URL + "/settarif");

    var body = json.encode(data);

    try{
      var response = await http.post(url,
          headers: {
                "Content-Type": "application/json",
                "Authorization": 'Bearer $token',
          }, body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      print(resdata);
      if (response.statusCode == 200) {
        if (resdata['status']) {
            return true;
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await set_tarif2(data);
          }
          else {
           return false;
          }
        }
        else{
          return false;
        }
      }
      else{
        return false;
      }
    }
    catch(e){
      print(("getData->Server error $e"));
      return false;
    }
  }

  Future<void> set_tarif(String purchaseToken,String product_id)async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    var url = Uri.parse(AppConstans.BASE_URL + "/settarif");
    Map<String,dynamic> data = {
      'purchase_token': purchaseToken,
      'product_id': product_id
    };

    var body = json.encode(data);

    try{
      var response = await http.post(url,
          headers: {
              "Content-Type": "application/json",
              "Authorization": 'Bearer $token',
          }, body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      print(resdata);
      if (response.statusCode == 200) {
        if (resdata['status']) {

        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await set_tarif(purchaseToken,product_id);
          }
          else {
            await savePostToLocal(data);
          }
        }
        else{
          await savePostToLocal(data);
        }
      }
      else{
        await savePostToLocal(data);
      }
    }
    catch(e){
      print(("getData->Server error $e"));
      await savePostToLocal(data);
    }
  }

  Future<bool> set_tarif_apple(String transaction_id,String product_id)async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    var url = Uri.parse(AppConstans.BASE_URL + "/settarifapple");
    Map<String,dynamic> data = {
      'transaction_id': transaction_id,
      'product_id': product_id
    };

    var body = json.encode(data);

    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          }, body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      print(resdata);
      if (response.statusCode == 200) {
        if (resdata['status']) {
          return true;
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await set_tarif_apple(transaction_id,product_id);
          }
          else {
            return false;
          }
        }
        else{
          print("Xato"+resdata['message']);
          return false;

        }
      }
      else{
        print("Xato"+response.statusCode.toString());
        return false;

      }
    }
    catch(e){
      print(("getData->Server error $e"));
      return false;
      // await savePostToLocal(data);
    }
  }

  Future<bool> delete_user()async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    var url = Uri.parse(AppConstans.BASE_URL + "/deleteuser");

    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          });
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      print(resdata);
      if (response.statusCode == 200) {
        if (resdata['status']) {
            return true;
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await delete_user();
          }
          else {
            return false;
          }
        }
        else{
          return false;
        }
      }
      else{
        return false;
      }
    }
    catch(e){
      print(("getData->Server error $e"));
      return false;
    }
  }

  Future<bool> refresh_token(String token) async {
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

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
        final Map response_json = json.decode(utf8.decode(response.bodyBytes));
        if (response_json['status']) {
          print("token yangilandi.");
          final SharedPreferences prefs = await _prefs;
          prefs.setString('bearer_token', response_json['token']);
          return true;
        }
        else{
          return false;
        }
      } else {
         print("refresh_token->Server error code ${response.statusCode}");
        return false;
      }
    } catch (e) {
      print("refresh_token->Server error $e");
      return false;
    }
  }

  Future<List<Childs>?> getChilds() async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    List<Childs> childList = [];
    if (token == '') {
      print("Token yoq");
      Map data = {
        'email': prefs.getString('email'),
        'password': prefs.getString('uid')
      };

      var url = Uri.parse(AppConstans.BASE_URL + '/login');

      //malumotlani jsonga moslashtirish
      var body = json.encode(data);
      try {
        var response = await http.post(url,
            headers: {"Content-Type": "application/json"}, body: body);
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        print(resdata);
        if (response.statusCode == 200) {
          if (resdata['status']) {
            final SharedPreferences prefs = await _prefs;
            prefs.setString('bearer_token', resdata['token']);
            return await getChilds();
          }
          else if (resdata['status'] == false &&
              resdata['message'].toString().contains("Token expired")) {
            bool token_isrefresh = await refresh_token(token);
            if (token_isrefresh) {
              return await getChilds();
            }
            else {
              print("Server error code ${response.statusCode}");
              throw Exception("Server error code ${response.statusCode}");
            }
          }
          else{
            print("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
            throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
          }
        }
        else {
          print("Server error code ${response.statusCode}");
          throw Exception("Server error code ${response.statusCode}");
        }
      } catch (e) {
        print("Server error $e");
        throw Exception("Server error $e");
      }
    }
    else{
      print("token bor");
      var url = Uri.parse(AppConstans.BASE_URL + '/getchilds');
      final SharedPreferences prefs = await _prefs;
      var token = prefs.getString('bearer_token') ?? '';
      print(token);
      try{
        var response = await http.get(url, headers: {
          "Content-Type": "application/json",
          "Authorization": 'Bearer $token',
        });
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        print(resdata);
        if (response.statusCode == 200) {
          if (resdata['status']) {
            if (resdata['message'].toString().contains("Expired subscribe")){
              return null;
            }
            else{
              childList = ChildModel.fromJson(resdata).childs!;
              return childList;
            }
          }
          else if (resdata['status'] == false &&
              resdata['message'].toString().contains("Token expired")) {
            bool token_isrefresh = await refresh_token(token);
            if (token_isrefresh) {
              return await getChilds();
            }
            else {
              throw Exception("Server error code ${response.statusCode}");
            }
          }
          else{
            throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode}");
        }
      }
      catch(e){
        print(("getData->Server error $e"));
        throw Exception("getData->Server error $e");
      }
    }
  }

  Future<ChildInfoModel?> getChildInfo(String chuid) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildInfoModel childInfoModel;
    var url = Uri.parse(AppConstans.BASE_URL + "/getchildinfo");
    Map data = {'chid': chuid};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
      try{
        var response = await http.post(url,
            headers: {
              "Content-Type": "application/json",
              "Authorization": 'Bearer $token',
            },
            body: body);
        print(response.body);
        final resdata = json.decode(utf8.decode(response.bodyBytes));
        print(resdata);
        if (response.statusCode == 200) {
          if (resdata['status']) {
            if (resdata['message'].toString().contains("Expired subscribe")){
              return null;
            }
            else {
              childInfoModel = ChildInfoModel.fromJson(resdata);
              return childInfoModel;
            }
          }
          else if (resdata['status'] == false &&
              resdata['message'].toString().contains("Token expired")) {
            bool token_isrefresh = await refresh_token(token);
            if (token_isrefresh) {
              return await getChildInfo(chuid);
            }
            else {
              throw Exception("Server error code ${response.statusCode}");
            }
          }
          else{
            throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode}");
        }
      }
      catch(e){
        throw Exception("getData->Server error $e");
      }
  }

  Future<ChildLocationListModel?> getchildlocations(String chuid,String date) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildLocationListModel? childLocationListModel;
    var url = Uri.parse(AppConstans.BASE_URL + "/getchildlocations");
    Map data = {'chuid': chuid,'date':date};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      // print(response.body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        // print(resdata);
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            print("Keldi122");
            childLocationListModel = ChildLocationListModel.fromJson(resdata);
            return childLocationListModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildlocations(chuid,date);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{

        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }

  Future<ChildNotificationModel?> getchildnotif(String chuid,String? next_page_url,String date) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildNotificationModel? childNotificationModel;
    var url;
    if(next_page_url == null){
      return childNotificationModel;
    }
    else if(next_page_url == ''){
      url = Uri.parse(AppConstans.BASE_URL + "/getchildnotif");
    }
    else{
      url = Uri.parse(next_page_url);
    }
    Map data = {'chuid': chuid,'date':date};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            childNotificationModel = ChildNotificationModel.fromJson(resdata);
            return childNotificationModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildnotif(chuid,next_page_url,date);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      print(e.toString());
      throw Exception("getData->Server error $e");
    }
  }

  Future<ChildCallListModel?> getchildcall(String chuid,String? next_page_url,String date) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildCallListModel? childCallListModel;
    var url;
    if(next_page_url == null){
      return childCallListModel;
    }
    else if(next_page_url == ''){
      url = Uri.parse(AppConstans.BASE_URL + "/getchildcalls");
    }
    else{
      url = Uri.parse(next_page_url);
    }
    Map data = {'chuid': chuid,'date':date};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            childCallListModel = ChildCallListModel.fromJson(resdata);
            return childCallListModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildcall(chuid,next_page_url,date);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }

  Future<ChildWebBlockListModel?> getchildweb(String chuid,String? next_page_url) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildWebBlockListModel? childWebBlockListModel;
    var url;
    if(next_page_url == null){
      return childWebBlockListModel;
    }
    else if(next_page_url == ''){
      url = Uri.parse(AppConstans.BASE_URL + "/webblock");
    }
    else{
      url = Uri.parse(next_page_url);
    }
    Map data = {'chuid': chuid};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            childWebBlockListModel = ChildWebBlockListModel.fromJson(resdata);
            return childWebBlockListModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildweb(chuid,next_page_url);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }

  Future<ChildAppUsageListModel?> getchildappusage(String chuid,String? next_page_url,String date) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildAppUsageListModel? childAppUsageListModel;
    var url;
    if(next_page_url == null){
      return childAppUsageListModel;
    }
    else if(next_page_url == ''){
      url = Uri.parse(AppConstans.BASE_URL + "/getchildappsusage");
    }
    else{
      url = Uri.parse(next_page_url);
    }
    Map data = {'chuid': chuid,'date':date};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      print(resdata);
      print("Qeldi");
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            childAppUsageListModel = ChildAppUsageListModel.fromJson(resdata);
            return childAppUsageListModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildappusage(chuid,next_page_url,date);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }

  Future<ChildAppListModel?> getchildapp(String chuid,String? next_page_url) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildAppListModel? childAppListModel;
    var url;
    if(next_page_url == null){
      return childAppListModel;
    }
    else if(next_page_url == ''){
      url = Uri.parse(AppConstans.BASE_URL + "/getchildapps");
    }
    else{
      url = Uri.parse(next_page_url);
    }
    Map data = {'chuid': chuid};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            childAppListModel = ChildAppListModel.fromJson(resdata);
            return childAppListModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildapp(chuid,next_page_url);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }

  Future<UserModel?> get_sub() async {
    var url = Uri.parse(AppConstans.BASE_URL + '/getsub');
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    UserModel? userModel;
    token = prefs.getString('bearer_token') ?? '';
    try{
      var response = await http.get(url, headers: {
        "Content-Type": "application/json",
        "Authorization": 'Bearer $token',
      });
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      print(resdata);
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            userModel = UserModel.fromJson(resdata)!;
            return userModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await get_sub();
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      print(("getData->Server error $e"));
      throw Exception("getData->Server error $e");
    }
  }

  Future<ChildContactModel?> getchildcontact(String chuid,String? next_page_url) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildContactModel? childContactModel;
    var url;
    if(next_page_url == null){
      return childContactModel;
    }
    else if(next_page_url == ''){
      url = Uri.parse(AppConstans.BASE_URL + "/getchildcontacts");
    }
    else{
      url = Uri.parse(next_page_url);
    }
    Map data = {'chuid': chuid};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            childContactModel = ChildContactModel.fromJson(resdata);
            return childContactModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildcontact(chuid,next_page_url);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }

  Future<ChildSmsListModel?> getchildsms(String chuid,String? next_page_url) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildSmsListModel? childSmsListModel;
    var url;
    if(next_page_url == null){
      return childSmsListModel;
    }
    else if(next_page_url == ''){
      url = Uri.parse(AppConstans.BASE_URL + "/getchildsms");
    }
    else{
      url = Uri.parse(next_page_url);
    }
    Map data = {'chuid': chuid};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            childSmsListModel = ChildSmsListModel.fromJson(resdata);
            return childSmsListModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildsms(chuid,next_page_url);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }

  Future<bool?> set_subscription(String chuid,String product_id,String purchase_token) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    Map data = {'purchase_token':purchase_token,'product_id':product_id};
    var body = json.encode(data);
    var url = Uri.parse(AppConstans.BASE_URL + "/settarif");
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (resdata['status']) {
            return resdata['status'];
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await set_subscription(chuid,product_id,purchase_token);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }


    Future<ChildSmsInfoModel?> getchildsmsinfo(String chuid,String sender,String? next_page_url) async{
    var token = '';
    final Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
    final SharedPreferences prefs = await _prefs;
    token = prefs.getString('bearer_token') ?? '';
    ChildSmsInfoModel? childSmsInfoModel;
    var url;
    if(next_page_url == null){
      return childSmsInfoModel;
    }
    else if(next_page_url == ''){
      url = Uri.parse(AppConstans.BASE_URL + "/getchildsendermsg");
    }
    else{
      url = Uri.parse(next_page_url);
    }
    Map data = {'chuid': chuid,'sender':sender};
    //malumotlani jsonga moslashtirish
    var body = json.encode(data);
    try{
      var response = await http.post(url,
          headers: {
            "Content-Type": "application/json",
            "Authorization": 'Bearer $token',
          },
          body: body);
      final resdata = json.decode(utf8.decode(response.bodyBytes));
      if (response.statusCode == 200) {
        if (resdata['status']) {
          if (resdata['message'].toString().contains("Expired subscribe")){
            return null;
          }
          else{
            childSmsInfoModel = ChildSmsInfoModel.fromJson(resdata);
            return childSmsInfoModel;
          }
        }
        else if (resdata['status'] == false &&
            resdata['message'].toString().contains("Token expired")) {
          bool token_isrefresh = await refresh_token(token);
          if (token_isrefresh) {
            return await getchildsmsinfo(chuid,sender,next_page_url);
          }
          else {
            throw Exception("Server error code ${response.statusCode}");
          }
        }
        else{
          throw Exception("getData->Server error code ${response.statusCode} ${resdata['message'].toString()}");
        }
      }
      else{
        throw Exception("getData->Server error code ${response.statusCode}");
      }
    }
    catch(e){
      throw Exception("getData->Server error $e");
    }
  }
}