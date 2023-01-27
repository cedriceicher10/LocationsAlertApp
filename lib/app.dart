import 'package:flutter/material.dart';
import 'splash_screen.dart';
import 'language_services.dart';
import 'formatted_text.dart';
import 'styles.dart';

class App extends StatelessWidget {
  App({Key? key}) : super(key: key);

  LanguageServices _languageServices = LanguageServices();

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: _languageServices.checkTranslationStatus(),
        builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
          if (snapshot.hasData) {
            if (snapshot.data!) {
              return FutureBuilder(
                  future: translationCheck(),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      return MaterialApp(
                          home: SplashScreen(),
                          debugShowCheckedModeBanner: false);
                    } else {
                      return MaterialApp(
                          home: loadingScreen('Changing Language...'),
                          debugShowCheckedModeBanner: false);
                    }
                  });
            } else {
              return MaterialApp(
                  home: SplashScreen(), debugShowCheckedModeBanner: false);
            }
          } else {
            return MaterialApp(
                home: loadingScreen('Loading...'),
                debugShowCheckedModeBanner: false);
          }
        });
  }

  Future<bool> translationCheck() async {
    await _languageServices.initLanguage();
    return true;
  }

  Widget loadingScreen(String text) {
    return Container(
        decoration: const BoxDecoration(
            gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Colors.lightBlue,
            Colors.pink,
          ],
        )),
        child: Center(
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
              loadingText(text),
              SizedBox(height: 10),
              CircularProgressIndicator(
                color: Colors.white,
              )
            ])));
  }

  Widget loadingText(String text) {
    return FormattedText(
      text: text,
      size: 24,
      color: Colors.white,
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
      decoration: TextDecoration.none,
    );
  }
}
