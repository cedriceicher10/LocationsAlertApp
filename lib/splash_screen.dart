import 'package:flutter/material.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:locationalertsapp/styles.dart';
import 'package:page_transition/page_transition.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_slides_screen.dart';
//import 'package:flutter_bloc/flutter_bloc.dart';
import 'start_screen.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({Key? key}) : super(key: key);

  double _screenWidth = 0;
  double _screenHeight = 0;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: getSharedPrefsVar(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
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
              nextScreen: nextScreenDeterminer(snapshot.data!),
              // with Bloc configuration
              // nextScreen: BlocProvider(
              //   create: (_) => WeatherCubit(),
              //   child: const WeatherScreen(),
              // ),
            );
          } else {
            return const Center(
                child: CircularProgressIndicator(
              color: Color(s_darkSalmon),
            ));
          }
        });
  }

  Future<bool> getSharedPrefsVar() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool? introSlidesShownBefore = prefs.getBool('introSlidesShownBefore');
    if ((introSlidesShownBefore == null) || (introSlidesShownBefore == false)) {
      prefs.setBool('introSlidesShownBefore', true);
      // Show the intro slides
      return true;
    } else {
      // Do not show the intro slides
      return false;
    }
  }

  Widget nextScreenDeterminer(bool showIntroSlides) {
    if (showIntroSlides) {
      return IntroSlidesScreen(
          screenWidth: _screenWidth, screenHeight: _screenHeight);
    } else {
      return StartScreen();
    }
  }

  double getScreenHeight(BuildContext context) {
    return MediaQuery.of(context).size.height;
  }

  double getImageWidth(BuildContext context) {
    _screenWidth = MediaQuery.of(context).size.width;
    _screenHeight = MediaQuery.of(context).size.height;
    double _imageWidth = (185 / 392) * _screenWidth;
    return _imageWidth;
  }
}
