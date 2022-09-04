import 'package:flutter/material.dart';
import 'package:olx_clone/constants.dart';

class CustomField extends StatefulWidget {
  CustomField({
    Key? key,
    required this.controller,
    required this.hintText,
    this.obscured = false,
    this.onTap,
    this.onEdit,
    this.prefixIcon,
  }) : super(key: key);

  final TextEditingController controller;
  final bool obscured;
  final String hintText;
  var onTap;
  var onEdit;
  Icon? prefixIcon;

  @override
  State<CustomField> createState() => _CustomFieldState();
}

class _CustomFieldState extends State<CustomField> {
  @override
  Widget build(BuildContext context) {
    bool showing = widget.obscured;

    return Container(
      height: 56,
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
          color: kBGFieldColor,
          borderRadius: BorderRadius.circular(kBorderRadius)),
      child: Center(
        child: Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: widget.controller,
                obscureText: showing,
                onChanged: widget.onEdit,
                onTap: widget.onTap,
                decoration: InputDecoration(
                    prefixIcon: widget.prefixIcon,
                    constraints: BoxConstraints(maxHeight: 56, minHeight: 56),
                    hintText: widget.hintText,

                    // fillColor: Colors.red,
                    // filled: true,
                    hintStyle: TextStyle(
                        fontSize: 17, color: Colors.black.withOpacity(0.35)),
                    contentPadding: EdgeInsets.symmetric(),
                    border: InputBorder.none),
              ),
            ),
            widget.obscured
                ? SizedBox(
                    width: 30,
                    child: IconButton(
                      onPressed: () {
                        setState(() {
                          showing = !showing;
                        });
                      },
                      icon: Icon(
                        !showing
                            ? Icons.visibility_off_rounded
                            : Icons.visibility,
                        color: Colors.black54,
                        size: 17,
                      ),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}
