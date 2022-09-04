import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:line_icons/line_icons.dart';
import 'package:olx_clone/constants.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final double height;
  final String title;

  const CustomAppBar({
    super.key,
    required this.title,
    this.height = kToolbarHeight,
  });

  @override
  Size get preferredSize => Size.fromHeight(height);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: kBackgroundColor,
          systemNavigationBarColor: kBackgroundColor),
      centerTitle: true,
      leading: IconButton(
        icon: Icon(
          LineIcons.angleLeft,
          color: Colors.black,
        ),
        onPressed: (() => Navigator.pop(context)),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          color: Colors.black,
        ),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
    );
  }
}
