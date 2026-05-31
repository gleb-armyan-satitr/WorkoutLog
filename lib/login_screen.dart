import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_theme.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  bool loading = false;
  bool rememberMe = false;
  bool passwordVisible = false;

  Future<void> login() async {
    FocusScope.of(context).unfocus();

    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      showError('Введите email и пароль');
      return;
    }

    if (!email.contains('@')) {
      showError('Введите корректный email');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', rememberMe);

      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on FirebaseAuthException catch (e) {
      showError(authErrorMessage(e.code));
    } catch (e) {
      showError('Неизвестная ошибка. Попробуйте ещё раз');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Future<void> resetPassword() async {
    final email = emailController.text.trim();

    if (email.isEmpty || !email.contains('@')) {
      showError('Введите email, чтобы восстановить пароль');
      return;
    }

    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.card,
          content: Text('Письмо для восстановления пароля отправлено'),
        ),
      );
    } on FirebaseAuthException catch (e) {
      showError(authErrorMessage(e.code));
    }
  }

  String authErrorMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'Аккаунт с таким email не найден. Создайте аккаунт';
      case 'wrong-password':
        return 'Неверный пароль. Попробуйте ещё раз';
      case 'invalid-credential':
        return 'Аккаунт не найден или пароль неверный. Проверьте данные или создайте аккаунт';
      case 'invalid-email':
        return 'Некорректный email';
      case 'user-disabled':
        return 'Этот аккаунт был отключён';
      case 'too-many-requests':
        return 'Слишком много попыток входа. Попробуйте позже';
      case 'network-request-failed':
        return 'Проблема с интернетом. Проверьте подключение';
      case 'channel-error':
        return 'Введите email и пароль';
      default:
        return 'Ошибка входа: $code';
    }
  }

  void showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.card,
        content: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: AppGradients.background,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(31, 60, 31, 24),
            children: [
              const TopWideLogo(),

              const SizedBox(height: 26),

              const Text(
                'WorkoutLog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.2,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Войдите в свой аккаунт',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 35),

              const Text(
                'Email',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                decoration: AppInputDecoration.build(
                  hint: 'your@email.com',
                  icon: Icons.mail_outline,
                ),
              ),

              const SizedBox(height: 15),

              const Text(
                'Пароль',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 7),
              TextField(
                controller: passwordController,
                obscureText: !passwordVisible,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                decoration: AppInputDecoration.build(
                  hint: '********',
                  icon: Icons.lock_outline,
                ).copyWith(
                  suffixIcon: IconButton(
                    onPressed: () {
                      setState(() {
                        passwordVisible = !passwordVisible;
                      });
                    },
                    icon: Icon(
                      passwordVisible
                          ? Icons.visibility_outlined
                          : Icons.visibility_off_outlined,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 15),

              Row(
                children: [
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: Checkbox(
                      value: rememberMe,
                      activeColor: AppColors.accent,
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white, width: 2),
                      onChanged: (value) {
                        setState(() {
                          rememberMe = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'запомнить меня',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: resetPassword,
                    child: const Text(
                      'Забыли пароль?',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 32),

              PrimaryGreenButton(
                text: loading ? 'Входим...' : 'Войти',
                icon: Icons.login,
                height: 57,
                onPressed: loading ? null : login,
              ),

              const SizedBox(height: 16),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Нет аккаунта?',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const RegisterScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'Зарегистрироваться',
                      style: TextStyle(
                        color: AppColors.accent,
                        fontSize: 15,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}