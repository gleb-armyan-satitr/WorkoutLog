import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'firebase_options.dart';
import 'login_screen.dart';
import 'main_screen.dart';

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  final prefs = await SharedPreferences.getInstance();
  final rememberMe = prefs.getBool('remember_me') ?? false;

  if (!rememberMe && FirebaseAuth.instance.currentUser != null) {
    await FirebaseAuth.instance.signOut();
  }

  runApp(const WorkoutLogApp());
}

class WorkoutLogApp extends StatelessWidget {
  const WorkoutLogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'WorkoutLog',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: false,
        scaffoldBackgroundColor: AppColors.bgTop,
        fontFamily: 'Roboto',
      ),
      home: const SplashGate(),
    );
  }
}

class SplashGate extends StatefulWidget {
  const SplashGate({super.key});

  @override
  State<SplashGate> createState() => _SplashGateState();
}

class _SplashGateState extends State<SplashGate> {
  bool showSplash = true;

  @override
  void initState() {
    super.initState();

    Timer(const Duration(milliseconds: 1800), () {
      if (mounted) {
        setState(() {
          showSplash = false;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (showSplash) {
      return const SplashScreen();
    }

    return const AuthGate();
  }
}

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: DecoratedBox(
        decoration: AppGradients.background,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _SplashLogo(),
              SizedBox(height: 22),
              Text(
                'WorkoutLog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.4,
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Твой дневник силового прогресса',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
              SizedBox(height: 34),
              SizedBox(
                width: 34,
                height: 34,
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SplashLogo extends StatelessWidget {
  const _SplashLogo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 92,
      height: 92,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: AppColors.accent.withOpacity(0.25),
            blurRadius: 30,
            spreadRadius: 4,
          ),
        ],
      ),
      child: Center(
        child: Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Center(
            child: Text(
              'W',
              style: TextStyle(
                color: AppColors.accent,
                fontSize: 32,
                fontWeight: FontWeight.w900,
                height: 1,
                letterSpacing: -1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: DecoratedBox(
              decoration: AppGradients.background,
              child: Center(
                child: CircularProgressIndicator(
                  color: AppColors.accent,
                ),
              ),
            ),
          );
        }

        if (snapshot.hasData) {
          return const MainScreen();
        }

        return const LoginScreen();
      },
    );
  }
}