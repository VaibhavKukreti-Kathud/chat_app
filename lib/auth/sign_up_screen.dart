import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icon.dart';
import 'package:line_icons/line_icons.dart';
import 'package:olx_clone/services/auth_functions.dart';
import 'package:olx_clone/services/snackbar.dart';
import 'package:olx_clone/constants.dart';
import 'package:olx_clone/widgets/custom_app_bar.dart';
import 'package:olx_clone/widgets/custom_button.dart';
import 'package:olx_clone/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

class SignUpScreen extends StatefulWidget {
  SignUpScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController _passwordController = TextEditingController();

  final TextEditingController _mailController = TextEditingController();

  final TextEditingController _passwordConfirmController =
      TextEditingController();

  final TextEditingController _nameController = TextEditingController();

  final PageController formPageController = PageController();

  int currentIndex = 0;

  bool filledPassword = false;
  bool filledEmail = false;

  @override
  void initState() {
    super.initState();

    formPageController.addListener(() {
      if (formPageController.page!.round() != currentIndex) {
        setState(() {
          currentIndex = formPageController.page!.round();
        });
      }
    });
  }

  @override
  void dispose() {
    formPageController.dispose();
    super.dispose();
  }

  bool validatePassword(String password, String confirmPassword) {
    setState(() {});
    if (password == confirmPassword && password != '' && password.length >= 6) {
      return true;
    } else {
      return false;
    }
  }

  bool onWillPop() {
    if (currentIndex == 0) {
      return true;
    } else {
      formPageController.previousPage(
          duration: Duration(milliseconds: 500), curve: Curves.easeOutCubic);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () => Future.sync(onWillPop),
      child: Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: const CustomAppBar(
          title: 'Sign up',
        ),
        body: Column(
          children: [
            Expanded(
              child: PageView(
                physics: const NeverScrollableScrollPhysics(),
                controller: formPageController,
                children: [
                  _buildMailPage(),
                  _buildPasswordPage(),
                ],
              ),
            ),
            !filledPassword ? buildNavigationBar() : SizedBox(),
            filledPassword
                ? Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: CustomButton(
                        onPressed: () async {
                          String res = await AuthProvider(
                                  firebaseAuth: FirebaseAuth.instance,
                                  prefs: Provider.of<SharedPreferences>(context,
                                      listen: false))
                              .signUpWithMailAndPassword(
                                  password: _passwordController.text,
                                  email: _mailController.text,
                                  //TODO: enter username and photourl
                                  username: null,
                                  photoUrl: null);
                          res != FUNCTION_SUCCESSFUL
                              ? showSnackbar(context, res.trim())
                              : () {};
                          Navigator.pop(context);
                        },
                        text: 'Create your account'),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Padding _buildPasswordPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LineIcons.lock,
            size: 30,
          ),
          SizedBox(height: 10),
          Text(
            'Now enter a secure password',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          CustomField(
              controller: _passwordController,
              onEdit: (v) {
                setState(() {
                  filledPassword =
                      validatePassword(v, _passwordConfirmController.text);
                });
              },
              hintText: 'Password',
              obscured: true),
          SizedBox(height: 10),
          CustomField(
              onEdit: (v) {
                setState(() {
                  filledPassword =
                      validatePassword(_passwordController.text, v);
                });
              },
              controller: _passwordConfirmController,
              hintText: 'Confirm password',
              obscured: true),
          SizedBox(height: 10),
          Text(
            'A password must be a minimum of 6 characters',
            style:
                TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Padding _buildMailPage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            LineIcons.envelopeOpenText,
            size: 30,
          ),
          SizedBox(height: 10),
          Text(
            'Start by entering your email',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          CustomField(
            controller: _mailController,
            onEdit: (v) {
              setState(() {
                filledEmail = isEmail(v);
              });
            },
            hintText: 'Email',
            obscured: false,
          ),
          SizedBox(height: 10),
          Text(
            'A mail address looks like abc@mail.com',
            style:
                TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3)),
          ),
        ],
      ),
    );
  }

  Widget buildNavigationBar() {
    return Padding(
      padding: const EdgeInsets.only(left: 32, right: 32, bottom: 40),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              currentIndex == 0
                  ? () {}
                  : formPageController.previousPage(
                      duration: Duration(milliseconds: 500),
                      curve: Curves.easeOutCubic);
            },
            child: AnimatedContainer(
                height: 56,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: currentIndex == 0 ? 0 : 30,
                        spreadRadius: -10,
                        offset:
                            currentIndex == 0 ? Offset(0, 0) : Offset(0, 15),
                        color: kButtonShadowColor,
                      )
                    ],
                    color:
                        currentIndex == 0 ? kDiabledButtonColor : kButtonPColor,
                    borderRadius: BorderRadius.circular(kBorderRadius)),
                width: 56,
                duration: Duration(milliseconds: 200),
                child: Center(
                    child: Icon(
                  CupertinoIcons.arrow_left,
                  color: Colors.white,
                ))),
          ),
          Spacer(),
          GestureDetector(
            onTap: () {
              currentIndex != 0
                  ? () {}
                  : !filledEmail
                      ? () {}
                      : formPageController.nextPage(
                          duration: Duration(milliseconds: 500),
                          curve: Curves.easeOutCubic);
            },
            child: AnimatedContainer(
                duration: Duration(milliseconds: 200),
                height: 56,
                decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        blurRadius: !filledEmail ? 0 : 30,
                        spreadRadius: -10,
                        offset: !filledEmail ? Offset(0, 0) : Offset(0, 15),
                        color: kButtonShadowColor,
                      )
                    ],
                    color: !filledEmail ? kDiabledButtonColor : kButtonPColor,
                    borderRadius: BorderRadius.circular(kBorderRadius)),
                width: 56,
                child: Center(
                    child: Icon(
                  CupertinoIcons.arrow_right,
                  color: Colors.white,
                ))),
          ),
        ],
      ),
    );
  }
}
