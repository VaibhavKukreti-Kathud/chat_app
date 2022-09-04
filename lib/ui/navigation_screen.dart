import 'package:animations/animations.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:olx_clone/constants.dart';
import 'package:olx_clone/ui/home_screen.dart';

class NavigationScreen extends StatefulWidget {
  const NavigationScreen({
    Key? key,
  }) : super(key: key);

  @override
  State<NavigationScreen> createState() => _NavigationScreenState();
}

class _NavigationScreenState extends State<NavigationScreen> {
  int _selectedIndex = 0;
  bool reverse = false;
  final Color _selectedColor = kButtonPColor;
  final Color _unselectedColor = Colors.black.withOpacity(0.2);

  final List<Widget> _pages = [
    HomePage(),
    Container(color: kBackgroundColor),
    Container(color: kBackgroundColor),
  ];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async {
        if (_selectedIndex == 0) {
          return true;
        } else {
          setState(() {
            _selectedIndex = 0;
          });
          return false;
        }
      }),
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        backgroundColor: Colors.transparent,
        body: Stack(
          alignment: Alignment.bottomCenter,
          children: [
            PageTransitionSwitcher(
              reverse: !reverse,
              transitionBuilder: (
                Widget child,
                Animation<double> primaryAnimation,
                Animation<double> secondaryAnimation,
              ) {
                return SharedAxisTransition(
                  animation: primaryAnimation,
                  secondaryAnimation: secondaryAnimation,
                  transitionType: SharedAxisTransitionType.horizontal,
                  fillColor: kBackgroundColor,
                  child: child,
                );
              },
              child: Container(
                  key: ValueKey<int>(_selectedIndex),
                  child: _pages[_selectedIndex]),
            ),
            Container(
              margin: EdgeInsets.only(bottom: 20),
              height: 64,
              padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width / 7.2),
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                  blurRadius: 30,
                  offset: Offset(0, -5),
                  color: Colors.black.withOpacity(0.1),
                )
              ], color: Colors.white, borderRadius: BorderRadius.circular(20)),
              width: MediaQuery.of(context).size.width - 32,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => setState(() {
                      reverse = false;
                      _selectedIndex = 0;
                    }),
                    child: Icon(
                      LineIcons.home,
                      size: 25,
                      color: _selectedIndex == 0
                          ? _selectedColor
                          : _unselectedColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      reverse = _selectedIndex < 1 ? true : false;
                      _selectedIndex = 1;
                    }),
                    child: Icon(
                      LineIcons.camera,
                      size: 25,
                      color: _selectedIndex == 1
                          ? _selectedColor
                          : _unselectedColor,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => setState(() {
                      reverse = _selectedIndex < 2 ? true : false;
                      _selectedIndex = 2;
                    }),
                    child: Icon(
                      LineIcons.userAlt,
                      size: 25,
                      color: _selectedIndex == 2
                          ? _selectedColor
                          : _unselectedColor,
                    ),
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
