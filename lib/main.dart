import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:olx_clone/constants.dart';
import 'package:olx_clone/ui/navigation_screen.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'auth/sign_in_screen.dart';
import 'provider/chat_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: kBackgroundColor,
      statusBarColor: Colors.white,
    ),
  );
  runApp(MyApp(
    prefs: await SharedPreferences.getInstance(),
  ));
}

class MyApp extends StatelessWidget {
  MyApp({Key? key, required this.prefs}) : super(key: key);

  final SharedPreferences prefs;
  final FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          StreamProvider<User?>.value(
              value: FirebaseAuth.instance.authStateChanges(),
              initialData: null),
          Provider<SharedPreferences>.value(value: prefs),
          Provider<ChatProvider>(
            create: (_) => ChatProvider(
              prefs: prefs,
              firebaseFirestore: firebaseFirestore,
            ),
          ),
        ],
        child: MaterialApp(
          title: 'Flutter Demo',
          color: Colors.white,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            textTheme: GoogleFonts.poppinsTextTheme(),
          ),
          debugShowCheckedModeBanner: false,
          home: const AuthGate(),
        ));
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    User? firebaseUser = Provider.of<User?>(context);
    bool loggedIn = firebaseUser != null;
    return Scaffold(
      backgroundColor: Colors.white,
      body: loggedIn ? const NavigationScreen() : const SignInScreen(),
    );
  }
}
