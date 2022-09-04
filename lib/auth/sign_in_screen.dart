import 'dart:async';
import 'dart:ui';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:olx_clone/auth/sign_up_screen.dart';
import 'package:olx_clone/services/snackbar.dart';
import 'package:olx_clone/constants.dart';
import 'package:olx_clone/widgets/custom_button.dart';
import 'package:olx_clone/widgets/custom_text_field.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:validators/validators.dart';

import '../services/auth_functions.dart';
import 'password_reset_screen.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({Key? key}) : super(key: key);

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _mailController = TextEditingController();
  bool mailFilled = false;
  bool passwordFilled = false;
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: Stack(
        children: [
          Container(
            padding: const EdgeInsets.only(left: 32, top: 80),
            child: const Text(
              "Welcome\nBack",
              style: TextStyle(
                  color: Color.fromARGB(255, 99, 185, 255), fontSize: 40),
            ),
          ),
          Container(
            padding: EdgeInsets.only(right: 32, left: 32),
            child: Column(
              children: [
                Spacer(),
                CustomField(
                  controller: _mailController,
                  hintText: 'Email',
                  onEdit: (v) {
                    setState(() {
                      isEmail(v) ? mailFilled = true : mailFilled = false;
                    });
                  },
                ),
                const SizedBox(
                  height: 10,
                ),
                CustomField(
                    controller: _passwordController,
                    hintText: 'Password',
                    obscured: true,
                    onEdit: (v) {
                      setState(() {
                        v.length >= 6
                            ? passwordFilled = true
                            : passwordFilled = false;
                      });
                    }),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => PasswordResetScreen())),
                    child: Text(
                      'Forgot passoword?',
                      style: TextStyle(
                          fontSize: 12, color: Colors.black.withOpacity(0.4)),
                    ),
                  ),
                ),
                const SizedBox(
                  height: 30,
                ),
                CustomButton(
                  disabled: !mailFilled || !passwordFilled || loading,
                  onPressed: !mailFilled || !passwordFilled || loading
                      ? () {}
                      : () async {
                          setState(() {
                            loading = true;
                          });
                          if (_mailController.text == '') {
                            showSnackbar(
                                context, 'Please enter your mail address');
                          } else if (_passwordController.text == '') {
                            showSnackbar(context, 'Please enter the password');
                          } else {
                            String res = await AuthProvider(
                                    firebaseAuth: FirebaseAuth.instance,
                                    prefs: Provider.of<SharedPreferences>(
                                        context,
                                        listen: false))
                                .handleSignIn(_mailController.text,
                                    _passwordController.text, null, null)
                                .onError((error, stackTrace) {
                              setState(() {
                                loading = false;
                              });
                              return showSnackbar(context, error.toString());
                            });
                            res != FUNCTION_SUCCESSFUL
                                ? showSnackbar(context, res)
                                : () {};
                          }
                        },
                  text: 'Login',
                ),
                SizedBox(height: 5),
                Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(
                    'If you dont have an account,',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xff4c505b),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(context,
                          MaterialPageRoute(builder: (_) => SignUpScreen()));
                    },
                    child: const Text(
                      'click here',
                      style: TextStyle(
                        decoration: TextDecoration.underline,
                        fontWeight: FontWeight.w700,
                        fontSize: 14,
                        color: Color(0xff4c505b),
                      ),
                    ),
                  ),
                ]),
                SizedBox(height: 15),
              ],
            ),
          ),
          loading
              ? BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 400),
                    color: loading ? Colors.white30 : Colors.transparent,
                  ),
                )
              : SizedBox(),
          loading ? SafeArea(child: LinearProgressIndicator()) : SizedBox(),
          loading
              ? Center(
                  child: Text('Hold on!'),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
