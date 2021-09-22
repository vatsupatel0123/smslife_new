import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_translate/flutter_translate.dart';
import 'package:get_served/provider/log_in_provider.dart';
import 'package:get_served/provider/msglist_provider.dart';
import 'package:get_served/resources/color_resources.dart';
import 'package:get_served/resources/const_widget/custom_button.dart';
import 'package:get_served/resources/const_widget/custom_scaffold.dart';
import 'package:get_served/resources/const_widget/custom_textformfield.dart';
import 'package:get_served/resources/image_resources.dart';
import 'package:get_served/utils/common_helper.dart';
import 'package:get_served/utils/connectionStatusSingleton.dart';
import 'package:get_served/utils/internetconnection.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  var mobilenumber = new TextEditingController();
  late MsgListProvider _msgListProvider;
  final formKey = new GlobalKey<FormState>();
  late LogInProvider _logInProvider;
  SharedPreferences? preferences;
  bool isOffline=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _loadpref();
    checkconnection();
  }
  void connectionChanged(dynamic hasConnection) {
    setState(() {
      isOffline = !hasConnection;
    });
  }
  void checkconnection()async {
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    isOffline = await connectionStatus.check();
    setState(() {
    });
  }
  _loadpref() async{
    _msgListProvider.init();
    ConnectionStatusSingleton connectionStatus = ConnectionStatusSingleton.getInstance();
    connectionStatus.initialize();
    connectionStatus.connectionChange.listen(connectionChanged);
    preferences = await SharedPreferences.getInstance();
    String language = preferences!.getString("language")??"en_US";
    changeLocale(context, language);
  }
  @override
  Widget build(BuildContext context) {
    _logInProvider = Provider.of<LogInProvider>(context, listen: true);

    if (isOffline) {
      return InternetConnection.nointernetconnection();
    }else{
      return CustomScaffold(
          isoffline: isOffline,
          statusbarcolor: ColorRes.white,
          body: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Container(
                color: ColorRes.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 100,),
                    Center(child: Image.asset(ImageRes.logo,width: 150,)),
                    Padding(
                      padding: const EdgeInsets.only(left: 20,right: 20,top: 120),
                      child: CustomTextFormField(translate('text.mobileNumber'),mobilenumber,inputtype:TextInputType.number,hinttext:translate('text.mobileNumber'),borderRadius: BorderRadius.circular(5),
                      maxLength: 10,
                      validator: CommonHelper.validateMobile,),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 40,bottom: 40),
                      child: CustomButton(translate("text.login"), ColorRes.orange, _logInProvider.isLoading,borderRadius: BorderRadius.circular(0),
                        onTap: () async{
                          FocusScopeNode currentFocus = FocusScope.of(context);
                          if (!currentFocus.hasPrimaryFocus) {
                            currentFocus.unfocus();
                          }
                          if(_logInProvider.isLoading==false)
                          {
                            if(formKey.currentState!.validate())
                            {
                              await _logInProvider.Login(context: context,contactNo: mobilenumber.text);
                            }
                          }

                        },),
                    ),
                  ],
                ),
              ),
            ),
          )
      );
    }
  }
}
