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
                  future: _languageServices.translate(),
                  builder:
                      (BuildContext context, AsyncSnapshot<bool> snapshot) {
                    if (snapshot.hasData) {
                      return MaterialApp(
                          home: SplashScreen(),
                          debugShowCheckedModeBanner: false);
                    } else {
                      return MaterialApp(
                          home: changingLanguageScreen(
                              _languageServices.getChangingLanguageTitle(),
                              _languageServices.getChangingLanguageBody()),
                          debugShowCheckedModeBanner: false);
                    }
                  });
            } else {
              return MaterialApp(
                  home: SplashScreen(), debugShowCheckedModeBanner: false);
            }
          } else {
            return MaterialApp(
                home: loadingScreen(_languageServices.getLoading()),
                debugShowCheckedModeBanner: false);
          }
        });
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
              titleText(text),
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: Colors.white,
              )
            ])));
  }

  Widget changingLanguageScreen(String title, String body) {
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
              titleText(title),
              SizedBox(height: 10),
              bodyText(body),
              SizedBox(height: 20),
              CircularProgressIndicator(
                color: Colors.white,
              )
            ])));
  }

  Widget titleText(String text) {
    return FormattedText(
      text: text,
      size: 28,
      color: Colors.white,
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
      decoration: TextDecoration.none,
      align: TextAlign.center,
    );
  }

  Widget bodyText(String text) {
    return FormattedText(
      text: text,
      size: 18,
      color: Colors.white,
      font: s_font_IBMPlexSans,
      weight: FontWeight.bold,
      decoration: TextDecoration.none,
      align: TextAlign.center,
    );
  }
}
