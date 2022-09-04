import 'package:flutter/material.dart';
import 'package:olx_clone/constants.dart';

class CustomButton extends StatelessWidget {
  CustomButton(
      {super.key,
      required this.onPressed,
      this.text = '',
      this.icon,
      this.disabled = false});

  final Function() onPressed;
  final String text;
  bool disabled;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: disabled ? () {} : onPressed,
      child: AnimatedContainer(
        duration: Duration(milliseconds: 300),
        height: 56,
        decoration: BoxDecoration(
            boxShadow: disabled
                ? []
                : [
                    BoxShadow(
                      blurRadius: 30,
                      spreadRadius: -20,
                      offset: Offset(0, 20),
                      color: kButtonShadowColor,
                    )
                  ],
            color: disabled ? kDiabledButtonColor : kButtonPColor,
            borderRadius: BorderRadius.circular(kBorderRadius)),
        width: MediaQuery.of(context).size.width - 64,
        child: Center(
            child: icon ??
                Text(
                  text,
                  style: TextStyle(color: Colors.white),
                )),
      ),
    );
  }
}
