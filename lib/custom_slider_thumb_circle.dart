import 'package:flutter/material.dart';

/**
 * Adapted code from https://medium.com/flutter-community/flutter-sliders-demystified-4b3ea65879c
 * with small tweaks and adjustments to make it mine.
 */

class CustomSliderThumbCircle extends SliderComponentShape {
  final double thumbRadius;
  final double min;
  final double max;
  final List<double> valueList;

  const CustomSliderThumbCircle({
    required this.thumbRadius,
    this.min = 0,
    this.max = 10,
    this.valueList = const [],
  });

  @override
  Size getPreferredSize(bool isEnabled, bool isDiscrete) {
    return Size.fromRadius(thumbRadius);
  }

  @override
  void paint(
    PaintingContext context,
    Offset center, {
    required Animation<double> activationAnimation,
    required Animation<double> enableAnimation,
    required bool isDiscrete,
    required TextPainter labelPainter,
    required RenderBox parentBox,
    required SliderThemeData sliderTheme,
    required TextDirection textDirection,
    required double value,
    required double textScaleFactor,
    required Size sizeWithOverflow,
  }) {
    final Canvas canvas = context.canvas;

    final paint = Paint()
      ..color = Colors.white //Thumb Background Color
      ..style = PaintingStyle.fill;

    TextSpan span = new TextSpan(
      style: new TextStyle(
        fontSize: thumbRadius * .8,
        fontWeight: FontWeight.w700,
        color: sliderTheme.thumbColor, //Text Color of Value on Thumb
      ),
      text: getValue(value),
    );

    TextPainter tp = new TextPainter(
        text: span,
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr);
    tp.layout();
    Offset textCenter =
        Offset(center.dx - (tp.width / 2), center.dy - (tp.height / 2));

    canvas.drawCircle(center, thumbRadius, paint);
    tp.paint(canvas, textCenter);
  }

  String getValue(double value) {
    //return (min + (max - min) * value).round().toString();
    return valueList[(value * valueList.length).toInt()].toString();
  }
}
