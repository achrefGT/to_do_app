import 'package:flutter/material.dart';
import 'package:to_do_app/ui/theme.dart';

class MyButton extends StatelessWidget {
  const MyButton({
    Key? key,
    required this.lable,
    required this.onTap,
    this.color = primaryClr,
    this.width = 120.0,
  }) : super(key: key);

  final String lable;
  final Function onTap;
  final Color? color;
  final double width;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onTap(),
      child: Container(
        width: width,
        height: 60,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: color ?? primaryClr,
        ),
        child: Center(
          child: Text(
            lable,
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
