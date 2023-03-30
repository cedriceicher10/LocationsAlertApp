import 'package:flutter/material.dart';
import 'styles.dart';

class TriggerSlider extends StatelessWidget {
  double value;
  final double minValue;
  final double maxValue;
  final int majorTick;
  final int minorTick;
  final Function(double)? onChanged;
  final Color? activeTickColor;
  final Color? inactiveTickColor;
  final Color? activeTrackColor;
  final Color? inactiveTrackColor;
  final int labelValuePrecision;
  final bool linearStep;
  final List<double>? steps;
  final String unit;

  TriggerSlider({
    required this.value,
    required this.minValue,
    required this.maxValue,
    required this.majorTick,
    required this.minorTick,
    required this.onChanged,
    required this.unit,
    this.activeTickColor,
    this.inactiveTickColor,
    this.activeTrackColor,
    this.inactiveTrackColor,
    this.labelValuePrecision = 2,
    this.linearStep = true,
    this.steps,
  });

  @override
  Widget build(BuildContext context) {
    final allocatedHeight = MediaQuery.of(context).size.height; // 1057.45
    final allocatedWidth = MediaQuery.of(context).size.width; // 523.64

    // Generate layout
    double _sliderPadding = (7 / 523.64) * allocatedWidth;
    double _tickFontSize = (17 / 1057.45) * allocatedHeight;

    final divisions = (majorTick - 1) * minorTick + majorTick;
    final double valueHeight =
        allocatedHeight * 0.05 < 41 ? 41 : allocatedHeight * 0.05;
    final double tickHeight =
        allocatedHeight * 0.025 < 20 ? 20 : allocatedHeight * 0.025;
    final labelOffset = (allocatedWidth / divisions / 2) - _sliderPadding;

    // Work-around for weird error where value = 0.0 and throwing exception
    if (value == 0.0) {
      value = steps![0];
    }

    return Column(
      children: [
        Row(
          children: List.generate(
            divisions,
            (index) => Expanded(
              child: Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    height: valueHeight,
                    child: Text(tickText(steps!, index, unit),
                        style: TextStyle(
                          fontSize: _tickFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center),
                  ),
                  Container(
                    alignment: Alignment.center,
                    height: tickHeight,
                    child: VerticalDivider(
                      indent: index % (minorTick + 1) == 0 ? 2 : 6,
                      thickness: 2.0,
                      color: index ==
                              ((value - minValue) /
                                  ((maxValue - minValue) / (divisions - 1)))
                          ? activeTickColor ?? Colors.orange
                          : Colors.grey.shade300,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: labelOffset),
          child: SliderTheme(
            data: SliderThemeData(
              trackHeight:
                  allocatedHeight * 0.011 < 9 ? 9 : allocatedHeight * 0.011,
              activeTickMarkColor: activeTrackColor ?? Colors.orange,
              inactiveTickMarkColor:
                  inactiveTrackColor ?? Colors.orange.shade50,
              activeTrackColor: activeTrackColor ?? Colors.orange,
              inactiveTrackColor: inactiveTrackColor ?? Colors.orange.shade50,
              thumbColor: createAlertSliderThumb,
              overlayColor: activeTickColor == null
                  ? Colors.orange.withOpacity(0.1)
                  : activeTickColor!.withOpacity(0.1),
              thumbShape: RoundSliderThumbShape(enabledThumbRadius: 12.0),
              trackShape: CustomTrackShape(),
              showValueIndicator: ShowValueIndicator.never,
              valueIndicatorTextStyle: TextStyle(
                fontSize: 12,
              ),
            ),
            child: Slider(
              value: value,
              min: minValue,
              max: maxValue,
              divisions: divisions - 1,
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}

String tickText(List<double> steps, int index, String unit) {
  if (index == 0) {
    return '${(steps[index]).toStringAsFixed(2)} $unit';
  } else {
    return '${(steps[index]).toStringAsFixed(1)} $unit';
  }
  // Determining whole numbers: if (steps[index] == steps[index].roundToDouble())
}

class CustomTrackShape extends RoundedRectSliderTrackShape {
  Rect getPreferredRect({
    required RenderBox parentBox,
    Offset offset = Offset.zero,
    required SliderThemeData sliderTheme,
    bool isEnabled = false,
    bool isDiscrete = false,
  }) {
    final double trackHeight = sliderTheme.trackHeight!;
    final double trackLeft = offset.dx;
    final double trackTop =
        offset.dy + (parentBox.size.height - trackHeight) / 2;
    final double trackWidth = parentBox.size.width;
    return Rect.fromLTWH(trackLeft, trackTop, trackWidth, trackHeight);
  }
}
