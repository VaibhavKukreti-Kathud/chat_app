import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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

class PasswordResetScreen extends StatefulWidget {
  PasswordResetScreen({super.key});

  @override
  State<PasswordResetScreen> createState() => _PasswordResetScreenState();
}

class _PasswordResetScreenState extends State<PasswordResetScreen> {
  final TextEditingController _mailController = TextEditingController();
  bool mailFilled = false;
  bool sent = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: CustomAppBar(title: 'Reset password'),
      body: Padding(
        padding: const EdgeInsets.only(left: 32, right: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Spacer(),
          Icon(
            LineIcons.doorOpen,
            size: 30,
          ),
          SizedBox(height: 10),
          Text(
            'Enter you email below',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          CustomField(
            controller: _mailController,
            hintText: 'Email',
            obscured: false,
            onEdit: (v) {
              setState(() {
                isEmail(v) ? mailFilled = true : mailFilled = false;
              });
            },
          ),
          SizedBox(height: 10),
          Text(
            'A mail address looks like abc@mail.com\nPlease note that you use the same mail address you used while creating your account. ',
            style:
                TextStyle(fontSize: 12, color: Colors.black.withOpacity(0.3)),
          ),
          Spacer(),
          Padding(
            padding: EdgeInsets.only(bottom: 40),
            child: CustomButton(
              disabled: !mailFilled,
              onPressed: mailFilled && !sent
                  ? () {}
                  : () async {
                      setState(() {
                        sent == true;
                      });

                      String res = await AuthProvider(
                              firebaseAuth: FirebaseAuth.instance,
                              prefs: Provider.of<SharedPreferences>(context))
                          .sendPasswordResetLinkMail(_mailController.text);
                      res == FUNCTION_SUCCESSFUL
                          ? () {
                              showSuccessSnackbar(context,
                                  'Password reset link has been sent to your mail.');
                            }
                          : showSnackbar(context, res);
                    },
              text: 'Send reset link',
            ),
          )
        ]),
      ),
    );
  }
}
