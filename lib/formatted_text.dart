import 'package:flutter/material.dart';

class FormattedText extends StatelessWidget {
  final String text;
  final TextAlign? align;
  final double? size;
  final String? font;
  final Color? color;
  final FontWeight? weight;
  final FontStyle? style;

  const FormattedText(
      {Key? key,
      required this.text,
      this.align,
      this.size,
      this.font,
      this.color,
      this.weight,
      this.style})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
        padding: EdgeInsets.all(1),
        child: Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: size,
            fontFamily: font,
            fontWeight: weight,
            fontStyle: style,
            color: color,
          ),
        ));
  }
}
