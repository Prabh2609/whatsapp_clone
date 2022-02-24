import 'dart:async';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:whatsapp_clone/Signin.dart';
import 'package:whatsapp_clone/main.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _isAuthenticated = false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    FirebaseAuth.instance
        .authStateChanges()
        .listen((User? user) {
          if(user != null){
              setState(() {
                _isAuthenticated = true;
              });
          }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        color:Colors.white,
        child:AnimatedSplashScreen(
          duration: 5000,
          splash: '[n]https://upload.wikimedia.org/wikipedia/commons/thumb/6/6b/WhatsApp.svg/1021px-WhatsApp.svg.png',
          nextScreen:_isAuthenticated?const Home():const SignIn(),
          splashTransition: SplashTransition.fadeTransition,
        )

    );
  }
}
