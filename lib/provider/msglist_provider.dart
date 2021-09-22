import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get_served/model/msglist_model.dart';
import 'package:get_served/model/user_model.dart';
import 'package:get_served/resources/url_resources.dart';
import 'package:get_served/utils/api_handler.dart';
import 'package:get_served/utils/date_time_utils.dart';
import 'package:get_served/utils/error_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';

class MsgListProvider with ChangeNotifier {

  // MsgListProvider(){
  //   refreshlist("");
  // }

  init() {
    refreshlist("");
  }

  Future<List<MsgListModel>>? msglistdata;
  String? appVersion,title,description,isCompulsory,appLink;
  refreshlist(String date) async{
    msglistdata = getMsgListdata(date);
  }

// Msg List
  Future<List<MsgListModel>> getMsgListdata(String date) async {
    SharedPreferences? preferences = await SharedPreferences.getInstance();
    String language = await preferences.getString("language")??"en_US";
    var currentdate;
    if(date==""){
      currentdate = await DateTimeUtils.currentDate();
    }else{
      currentdate = date;
    }
    try {
      return await ApiHandler.post(UrlResources.GET_MSG_LIST,body: {
        "filterDate":currentdate,
        "language": language
      }).then((dynamic value) async {
        if(value["status"] == "true") {
          final items = value["data"].cast<Map<String, dynamic>>();
          List<MsgListModel> listofusers = items.map<MsgListModel>((json) {
            return MsgListModel.fromJson(json);
          }).toList();
          List<MsgListModel> revdata = listofusers.toList();
          print("length "+revdata.length.toString());
          return revdata;
        }else{
          return null!;
        }
      });
    } on ErrorHandler catch (ex) {
      return null!;
      //styledtoast(context, ex.getMessage());
    }
  }
// Msg List

// Login
  Future<dynamic> getVersion() async {
    try {
      await ApiHandler.get(UrlResources.APP_UPDATE).then((dynamic value) async {
        if(value["status"] == "true") {
          print(value["data"]);
          appVersion = value["data"]["appVersion"];
          title = value["data"]["title"];
          description = value["data"]["description"];
          isCompulsory = value["data"]["isCompulsory"];
          appLink = value["data"]["appLink"];
          return value["data"].toString();
          //notifyListeners();
        }
      });
    } on ErrorHandler catch (ex) {
      // isLoading = false;
      // styledtoast(context,ex.getMessage());
    }
  }
// Login


// Msg List
  updateUserLanguage() async {
    SharedPreferences? preferences = await SharedPreferences.getInstance();
    User user = User.fromJson(json.decode(preferences.getString("USER")!));
    String language = await preferences.getString("language")??"en_US";
    try {
      return await ApiHandler.post(UrlResources.UPDATE_USER_LANGUAGE,body: {
        "userId":user.userId,
        "userLanguage": language
      });
    } on ErrorHandler catch (ex) {
      return null!;
      //styledtoast(context, ex.getMessage());
    }
  }
// Msg List
}