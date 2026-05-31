import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';
import 'main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool accepted = false;
  bool loading = false;

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final repeat = repeatPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty || repeat.isEmpty) {
      showError('Заполните все поля');
      return;
    }

    if (password.length < 8) {
      showError('Пароль должен быть минимум 8 символов');
      return;
    }

    if (password != repeat) {
      showError('Пароли не совпадают');
      return;
    }

    if (!accepted) {
      showError('Нужно принять условия использования');
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await credential.user?.updateDisplayName(name);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      showError(e.code);
    } catch (e) {
      showError('Неизвестная ошибка');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showError(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.card,
        content: Text('Ошибка: $text'),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    repeatPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: AppGradients.background,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(34, 48, 34, 24),
            children: [
              const WorkoutLogo(),
              const SizedBox(height: 10),
              const Text(
                'WorkoutLog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 25,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Создайте новый аккаунт',
                style: TextStyle(color: Colors.white, fontSize: 13),
              ),
              const SizedBox(height: 24),

              _label('Имя'),
              TextField(
                controller: nameController,
                style: const TextStyle(color: Colors.white),
                decoration: AppInputDecoration.build(
                  hint: 'Иван Петров',
                  icon: Icons.person_outline,
                ),
              ),

              const SizedBox(height: 10),

              _label('Email'),
              TextField(
                controller: emailController,
                keyboardType: TextInputType.emailAddress,
                style: const TextStyle(color: Colors.white),
                decoration: AppInputDecoration.build(
                  hint: 'your@email.com',
                  icon: Icons.mail_outline,
                ),
              ),

              const SizedBox(height: 10),

              _label('Пароль'),
              TextField(
                controller: passwordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: AppInputDecoration.build(
                  hint: 'Минимум 8 символов',
                  icon: Icons.lock_outline,
                ),
              ),

              const SizedBox(height: 10),

              _label('Подтвердите пароль'),
              TextField(
                controller: repeatPasswordController,
                obscureText: true,
                style: const TextStyle(color: Colors.white),
                decoration: AppInputDecoration.build(
                  hint: 'Повторите пароль',
                  icon: Icons.lock_outline,
                ),
              ),

              const SizedBox(height: 14),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 20,
                    height: 20,
                    child: Checkbox(
                      value: accepted,
                      activeColor: AppColors.accent,
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white70),
                      onChanged: (value) {
                        setState(() {
                          accepted = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Я согласен с ',
                        style: TextStyle(color: Colors.white, fontSize: 12),
                        children: [
                          TextSpan(
                            text: 'условиями использования\n',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          TextSpan(text: 'и '),
                          TextSpan(
                            text: 'политикой конфиденциальности',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              PrimaryGreenButton(
                text: loading ? 'Создаем...' : 'Создать аккаунт',
                onPressed: loading ? null : register,
              ),

              const SizedBox(height: 4),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Уже есть аккаунт?',
                    style: TextStyle(color: Colors.white, fontSize: 13),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Войти',
                      style: TextStyle(
                        color: AppColors.accent,
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

  Widget _label(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white70, fontSize: 12),
      ),
    );
  }
}