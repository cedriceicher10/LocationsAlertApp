import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:locationalertsapp/styles.dart';
import 'package:page_transition/page_transition.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'start_screen.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedSplashScreen(
      splash: SizedBox.expand(
          child: Container(
              child: Center(
                  child: Container(
                      decoration: const BoxDecoration(boxShadow: [
                        BoxShadow(
                          color: Colors.black,
                          spreadRadius: 4,
                          blurRadius: 8,
                          offset: Offset(0, 0),
                        ),
                      ]),
                      child: Image(
                          width: getImageWidth(context),
                          image: AssetImage(
                              'assets/images/CE_Ventures_Square.png')))),
              decoration: const BoxDecoration(
                  gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Colors.lightBlue,
                  Colors.pink,
                ],
              )))),
      splashIconSize: getScreenHeight(context),
      duration: 2500,
      splashTransition: SplashTransition.fadeTransition,
      pageTransitionType: PageTransitionType.fade,
      nextScreen: const StartScreen(),
      // with Bloc configuration
      // nextScreen: BlocProvider(
      //   create: (_) => WeatherCubit(),
      //   child: const WeatherScreen(),
      // ),
    );
  }

  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getImageWidth(BuildContext context) {
    double _screenWidth = MediaQuery.of(context).size.width;
    double _imageWidth = (185 / 392) * _screenWidth;
    return _imageWidth;
  }
}
