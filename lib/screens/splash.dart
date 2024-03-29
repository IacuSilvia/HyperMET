import 'package:flutter/material.dart';
import 'package:progetto/screens/homepage.dart';
import 'package:progetto/screens/login_screen.dart';
import 'package:progetto/screens/onboarding/onboarding_impact.dart';
import 'package:provider/provider.dart';

import '../services/impact.dart';
import '../utils/shared_preferences.dart';

class Splash extends StatelessWidget {
  static const route = '/splash/';
  static const routeDisplayName = 'SplashPage';

  const Splash({Key? key}) : super(key: key);

  // Method for navigation SplashPage -> Login
  void _toLoginPage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: (context) => const LoginPage( 
            )));
  } //_toLoginPage

  // Method for navigation SplashPage -> HomePage
  void _toHomePage(BuildContext context) {
    Navigator.of(context).pushReplacement(MaterialPageRoute(
        builder: ((context) => const HomePage(
              title: '',
            ))));
  } //_toHomePage

  // Method for navigation SplashPage -> Impact
  void _toImpactPage(BuildContext context) {
    Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: ((context) => ImpactOnboarding())));
  }

  void _checkAuth(BuildContext context) async {
    var prefs = Provider.of<Preferences>(context, listen: false);
    String? username = prefs.username;
    String? password = prefs.password;

    // no user logged in the app
    if (username == null || password == null) {
      Future.delayed(const Duration(seconds: 1), () => _toLoginPage(context));
    } else {
      //ImpactService è in serveces/impact.dart
      ImpactService service =
          Provider.of<ImpactService>(context, listen: false);
      bool responseAccessToken =
          service.checkSavedToken(); //Check if there is a token
      bool refreshAccessToken = service.checkSavedToken(refresh: true);

      //if we have a valid token for impact, proceed
      if (responseAccessToken || refreshAccessToken) {
        Future.delayed(const Duration(seconds: 1), () => _toHomePage(context));
      } else {
        Future.delayed(
            const Duration(seconds: 1), () => _toImpactPage(context));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
   
    Future.delayed(const Duration(seconds: 1), () => _checkAuth(context));
    return Material(
      child: Container(
        color: Color(0xFFA271DC),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            const Text(
              'HyperMET',
              style: TextStyle(
                  color: Color(0xFFE4DFD4),
                  fontSize: 40,
                  fontWeight: FontWeight.bold),
            ),
            const Center(
              child: CircularProgressIndicator(
                strokeWidth: 4,
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF89453C)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
