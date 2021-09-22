import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:awesome_notifications/awesome_notifications.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_served/provider/msglist_provider.dart';
import 'package:get_served/provider/user_provider.dart';
import 'package:get_served/resources/color_resources.dart';
import 'package:get_served/resources/const_widget/custom_scaffold.dart';
import 'package:get_served/resources/image_resources.dart';
import 'package:get_served/screen/home_screen.dart';
import 'package:get_served/screen/login_screen.dart';
import 'package:get_served/utils/common_helper.dart';
import 'package:get_served/utils/connectionStatusSingleton.dart';
import 'package:get_served/utils/internetconnection.dart';
import 'package:package_info/package_info.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  late UserProvider _userProvider;
  late MsgListProvider _msgListProvider;
  late bool isloging;
  late BuildContext _ctx;
  var versiondetails;
  bool isOffline = false;

  @override
  void initState() {
    super.initState();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    checkconnection();
    connectionStatus.connectionChange.listen(connectionChanged);
    _userProvider = Provider.of<UserProvider>(context,listen: false);
    _msgListProvider = Provider.of<MsgListProvider>(context,listen: false);
    //checkIsLogin();
    FirebaseMessaging.instance
        .getInitialMessage()
        .then((RemoteMessage? message) {
      if (message != null) {
        // Navigator.pushNamed(context, '/message',
        //     arguments: MessageArguments(message, true));
      }
    });

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null && !kIsWeb) {
        var data = jsonDecode(message.data["message"].toString());
        showBigPictureNetworkNotification(notification,data["image"].toString());
      }
    });

    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _msgListProvider.init();
      print('A new onMessageOpenedApp event was published!');
      // Navigator.pushNamed(context, '/message',
      //     arguments: MessageArguments(message, true));
    });
    // WidgetsBinding.instance!.addPostFrameCallback((_) async
    // {
    //   _displayDialog(_ctx);
    // });
  }
  Future<void> showBigPictureNetworkNotification(RemoteNotification notification,String imageUrl) async {
    if(imageUrl==""){
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 3,
            channelKey: 'big_text',
            title: notification.title,
            body: notification.body,
            notificationLayout: NotificationLayout.BigText,));
      }else{
      await AwesomeNotifications().createNotification(
          content: NotificationContent(
            id: 11,
            channelKey: 'big_picture',
            title: notification.title,
            body: notification.body,
            hideLargeIconOnExpand: true,
            largeIcon: imageUrl,
            bigPicture: imageUrl,
            notificationLayout: NotificationLayout.BigPicture,));
    }
  }
  void _displayDialog(BuildContext context) async {
    return showDialog(
        barrierDismissible: false,
        context: context,
        builder: (context) {
          // this was required, rest is same
          return StatefulBuilder(
              builder: (BuildContext context, setState){
                return WillPopScope(
                  onWillPop: () async => false,
                  child: Dialog(
                      shape: RoundedRectangleBorder(
                          borderRadius:
                          BorderRadius.circular(20.0)),
                      elevation: 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(20.0))),
                        height: 550,
                        child: Stack(
                          children: [
                            SizedBox(height: 10,),
                            ClipRRect(
                                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                                child: Image.asset(ImageRes.update)),
                            // Padding(
                            //   padding: const EdgeInsets.only(top: 25),
                            //   child: Align(
                            //       alignment: Alignment.topCenter,
                            //       child: Image.asset(ImageRes.logo,height: 100,width: 100,)),
                            // ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Center(
                                  child: Padding(
                                    padding: const EdgeInsets.only(top: 100),
                                    child: Text(_msgListProvider.title.toString(),style: TextStyle(fontSize: 35,color: ColorRes.orange),),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(top: 10,left: 10,right: 10),
                                  child: Container(
                                      height: MediaQuery.of(context).size.height * 0.25,
                                      child: SingleChildScrollView(child: Text(_msgListProvider.description.toString(),textAlign: TextAlign.center,style: TextStyle(fontSize: 20,color: ColorRes.black),))),
                                ),
                              ],
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: <Widget>[
                                    Expanded(
                                      child: InkWell(
                                        onTap: () {
                                          if(_msgListProvider.isCompulsory.toString()=="Y") {
                                              exit(0);
                                            }else{
                                            navigate();
                                          }
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                                          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //       color: Color(0xffcccccc),
                                            //       blurRadius: 8.0
                                            //   )
                                            // ],
                                            borderRadius: BorderRadius.only(bottomLeft: Radius.circular(20)),
                                            border: Border.all(
                                              color: ColorRes.orange,
                                            ),
                                            color:Colors.white,
                                          ),
                                          child: Text(_msgListProvider.isCompulsory.toString()=="Y"?"Exit":"Skip", style: TextStyle(color: Colors.black,fontSize: 15.0,fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                    ),

                                    Expanded(
                                      child: InkWell(
                                        onTap: () async{
                                          print(_msgListProvider.appLink.toString());
                                          CommonHelper.getWebSiteUrl(_msgListProvider.appLink.toString());
                                        },
                                        child: Container(
                                          padding: EdgeInsets.symmetric(vertical: 20, horizontal: 0),
                                          margin: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          alignment: Alignment.center,
                                          decoration: BoxDecoration(
                                            // boxShadow: [
                                            //   BoxShadow(
                                            //       color: Color(0xffcccccc),
                                            //       blurRadius: 8.0
                                            //   )
                                            // ],
                                            borderRadius: BorderRadius.only(bottomRight: Radius.circular(20)),
                                            border: Border.all(
                                              color: ColorRes.orange,
                                            ),

                                            color: ColorRes.orange,
                                          ),
                                          child: Text("Update", style: TextStyle(color: Colors.white,fontSize: 15.0,fontWeight: FontWeight.bold),),
                                        ),
                                      ),
                                    ),


                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      )
                  ),
                );
              }
          );
        });
  }

  checkIsLogin() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    _msgListProvider.init();
    isloging = await _userProvider.isUserLogin();
    await _msgListProvider.getVersion();
    print(packageInfo.version.toString());
    if(packageInfo.version.toString()==_msgListProvider.appVersion.toString()) {
        startTime();
      }else {
      _displayDialog(_ctx);
    }
  }
  void checkconnection()async {
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    isOffline = await connectionStatus.check();
    print(isOffline);
    if(!isOffline){
      checkIsLogin();
    }
    setState(() {
    });
  }
  startTime() async {
    var _duration = new Duration(seconds: 2);
    return new Timer(_duration, navigate);
  }
  navigate() async {
    if(isloging){
      Navigator.pushReplacement(context, PageTransition(child: HomeScreen(), type: PageTransitionType.scale,alignment: Alignment.center,duration: Duration(milliseconds: 700)));
    }else{
      Navigator.pushReplacement(context, PageTransition(child: LoginScreen(), type: PageTransitionType.scale,alignment: Alignment.center,duration: Duration(milliseconds: 700)));
    }

  }
  void connectionChanged(dynamic hasConnection) {
    print(hasConnection);
    setState(() {
      isOffline = !hasConnection;
    });
    if(!isOffline){
      checkIsLogin();
    }
  }

  @override
  Widget build(BuildContext context) {
    setState(() {
      _ctx=context;
    });
    if (isOffline) {
      return InternetConnection.nointernetconnection();
    }else{
      return CustomScaffold(
        isoffline:isOffline,
        statusbarcolor:ColorRes.white,
        body: Stack(
            children:[
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      height: 300,
                      width: 300,
                      child: Image.asset(
                        ImageRes.logo,
                        fit: BoxFit.cover,
                        alignment: Alignment.center,
                      ),
                    ),
                    // SizedBox(
                    //   height: 20,
                    // ),
                    //Text("${StringResources.appname}",style: StyleResources.accountTabStyle,),
                  ],
                ),
              ),
              Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 30),
                    child: CircularProgressIndicator(backgroundColor: ColorRes.orangeLight,valueColor: AlwaysStoppedAnimation<Color>(ColorRes.orange),),
                  ))
            ]
        ),
      );
    }
  }
}