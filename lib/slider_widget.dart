import 'package:flutter/material.dart';
import 'custom_slider_thumb_circle.dart';

/**
 * Adapted code from https://medium.com/flutter-community/flutter-sliders-demystified-4b3ea65879c
 * with small tweaks and adjustments to make it mine.
 */

class SliderWidget extends StatefulWidget {
  final double sliderHeight;
  final double sliderWidth;
  final List<double> valueList;
  final double min;
  final double max;
  Color gradientColorStart;
  Color gradientColorEnd;
  final fullWidth;

  SliderWidget(
      {this.sliderHeight = 48,
      this.sliderWidth = 200,
      this.valueList = const [],
      this.max = 10,
      this.min = 0,
      this.gradientColorStart = const Color(0xFF00c6ff),
      this.gradientColorEnd = const Color(0xFF0072ff),
      this.fullWidth = false});

  @override
  _SliderWidgetState createState() => _SliderWidgetState();
}

class _SliderWidgetState extends State<SliderWidget> {
  int _value = 0;

  @override
  Widget build(BuildContext context) {
    double paddingFactor = .2;

    if (this.widget.fullWidth) paddingFactor = .3;

    return Container(
      width: this.widget.sliderWidth,
      height: (this.widget.sliderHeight),
      decoration: new BoxDecoration(
        borderRadius: new BorderRadius.all(
          Radius.circular((this.widget.sliderHeight * .3)),
        ),
        gradient: new LinearGradient(
            colors: [
              this.widget.gradientColorStart,
              this.widget.gradientColorEnd,
            ],
            begin: const FractionalOffset(0.0, 0.0),
            end: const FractionalOffset(1.0, 1.00),
            stops: [0.0, 1.0],
            tileMode: TileMode.clamp),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(this.widget.sliderHeight * paddingFactor,
            2, this.widget.sliderHeight * paddingFactor, 2),
        child: Row(
          children: <Widget>[
            Text(
              '${this.widget.min}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: this.widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            SizedBox(
              width: this.widget.sliderHeight * .1,
            ),
            Expanded(
              child: Center(
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    activeTrackColor: Colors.white.withOpacity(1),
                    inactiveTrackColor: Colors.white.withOpacity(.5),
                    trackHeight: 4.0,
                    thumbShape: CustomSliderThumbCircle(
                      thumbRadius: this.widget.sliderHeight * .4,
                      min: this.widget.min,
                      max: this.widget.max,
                      valueList: this.widget.valueList,
                    ),
                    overlayColor: Colors.white.withOpacity(.4),
                    //valueIndicatorColor: Colors.white,
                    activeTickMarkColor: Colors.white,
                    inactiveTickMarkColor: Colors.white,
                  ),
                  child: Slider(
                      value: _value.toDouble(),
                      min: 0,
                      max: this.widget.valueList.length - 1,
                      label: this.widget.valueList[_value].toString(),
                      divisions: this.widget.valueList.length - 1,
                      onChanged: (double value) {
                        setState(() {
                          _value = value.toInt();
                        });
                      }),
                ),
              ),
            ),
            SizedBox(
              width: this.widget.sliderHeight * .1,
            ),
            Text(
              '${this.widget.max}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: this.widget.sliderHeight * .3,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  double getCurrentValue() {
    return this.widget.valueList[_value];
  }
}
