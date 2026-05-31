import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
  final phoneController = TextEditingController();
  final birthDateController = TextEditingController();

  final goalController = TextEditingController(text: 'Набор мышечной массы');
  final currentWeightController = TextEditingController();
  final targetWeightController = TextEditingController();
  final bodyFatController = TextEditingController();
  final weeklyGoalController = TextEditingController(text: '4');

  final passwordController = TextEditingController();
  final repeatPasswordController = TextEditingController();

  bool accepted = false;
  bool loading = false;
  bool passwordVisible = false;
  bool repeatPasswordVisible = false;

  Future<void> register() async {
    FocusScope.of(context).unfocus();

    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final phone = phoneController.text.trim();
    final birthDate = birthDateController.text.trim();

    final goal = goalController.text.trim().isEmpty
        ? 'Набор мышечной массы'
        : goalController.text.trim();

    final currentWeight = double.tryParse(
      currentWeightController.text.trim().replaceAll(',', '.'),
    );
    final targetWeight = double.tryParse(
      targetWeightController.text.trim().replaceAll(',', '.'),
    );
    final bodyFat = double.tryParse(
      bodyFatController.text.trim().replaceAll(',', '.'),
    );
    final weeklyGoal = int.tryParse(weeklyGoalController.text.trim());

    final password = passwordController.text.trim();
    final repeat = repeatPasswordController.text.trim();

    if (name.isEmpty ||
        email.isEmpty ||
        phone.isEmpty ||
        birthDate.isEmpty ||
        currentWeight == null ||
        targetWeight == null ||
        bodyFat == null ||
        weeklyGoal == null ||
        password.isEmpty ||
        repeat.isEmpty) {
      showError('Заполните все поля корректно');
      return;
    }

    if (!email.contains('@')) {
      showError('Введите корректный email');
      return;
    }

    if (!phone.startsWith('+7')) {
      showError('Номер телефона должен начинаться с +7');
      return;
    }

    if (phone.length < 12) {
      showError('Введите полный номер телефона');
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

      final user = credential.user;

      if (user == null) {
        showError('Не удалось создать пользователя');
        return;
      }

      await user.updateDisplayName(name);
      await user.reload();

      await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
        'name': name,
        'email': email,
        'phone': phone,
        'birthDate': birthDate,
        'goal': goal,
        'currentWeight': currentWeight,
        'targetWeight': targetWeight,
        'bodyFat': bodyFat,
        'weeklyWorkoutsGoal': weeklyGoal,
        'workoutsDone': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('remember_me', true);

      if (!mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const MainScreen()),
        (_) => false,
      );
    } on FirebaseAuthException catch (e) {
      showError(authErrorMessage(e.code));
    } catch (e) {
      showError('Ошибка при создании профиля. Попробуйте ещё раз');
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  String authErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Аккаунт с таким email уже существует. Войдите в аккаунт';
      case 'invalid-email':
        return 'Некорректный email';
      case 'weak-password':
        return 'Пароль слишком слабый. Используйте минимум 8 символов';
      case 'network-request-failed':
        return 'Проблема с интернетом. Проверьте подключение';
      case 'operation-not-allowed':
        return 'Регистрация по email отключена в Firebase';
      default:
        return 'Ошибка регистрации: $code';
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
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    goalController.dispose();
    currentWeightController.dispose();
    targetWeightController.dispose();
    bodyFatController.dispose();
    weeklyGoalController.dispose();
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
            padding: const EdgeInsets.fromLTRB(31, 34, 31, 22),
            children: [
              const TopWideLogo(),

              const SizedBox(height: 22),

              const Text(
                'WorkoutLog',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 29,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Создайте аккаунт и заполните профиль',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 25),

              _SectionTitle('Личные данные'),

              _RegisterField(
                label: 'Имя',
                controller: nameController,
                icon: Icons.person_outline,
                hint: 'Например, NN',
              ),
              _RegisterField(
                label: 'Email',
                controller: emailController,
                icon: Icons.mail_outline,
                hint: 'your@email.com',
                keyboardType: TextInputType.emailAddress,
              ),
              _RegisterField(
                label: 'Телефон',
                controller: phoneController,
                icon: Icons.phone_outlined,
                hint: '+7 999 123-45-67',
                keyboardType: TextInputType.phone,
              ),
              _RegisterField(
                label: 'Дата рождения',
                controller: birthDateController,
                icon: Icons.calendar_month_outlined,
                hint: '15 марта 1995',
              ),

              const SizedBox(height: 10),

              _SectionTitle('Цели тренировок'),

              _RegisterField(
                label: 'Цель',
                controller: goalController,
                icon: Icons.track_changes,
                hint: 'Набор мышечной массы',
              ),
              _RegisterField(
                label: 'Текущий вес',
                controller: currentWeightController,
                icon: Icons.monitor_weight_outlined,
                hint: '78',
                suffix: 'кг',
                keyboardType: TextInputType.number,
              ),
              _RegisterField(
                label: 'Целевой вес',
                controller: targetWeightController,
                icon: Icons.flag_outlined,
                hint: '82',
                suffix: 'кг',
                keyboardType: TextInputType.number,
              ),
              _RegisterField(
                label: 'Процент жира',
                controller: bodyFatController,
                icon: Icons.percent,
                hint: '12',
                suffix: '%',
                keyboardType: TextInputType.number,
              ),
              _RegisterField(
                label: 'Тренировок в неделю',
                controller: weeklyGoalController,
                icon: Icons.calendar_view_week,
                hint: '4',
                suffix: 'раз',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 10),

              _SectionTitle('Безопасность'),

              _RegisterField(
                label: 'Пароль',
                controller: passwordController,
                icon: Icons.lock_outline,
                hint: 'Минимум 8 символов',
                obscureText: !passwordVisible,
                trailing: IconButton(
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
              _RegisterField(
                label: 'Подтвердите пароль',
                controller: repeatPasswordController,
                icon: Icons.lock_outline,
                hint: 'Повторите пароль',
                obscureText: !repeatPasswordVisible,
                trailing: IconButton(
                  onPressed: () {
                    setState(() {
                      repeatPasswordVisible = !repeatPasswordVisible;
                    });
                  },
                  icon: Icon(
                    repeatPasswordVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: AppColors.accent,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    width: 25,
                    height: 25,
                    child: Checkbox(
                      value: accepted,
                      activeColor: AppColors.accent,
                      checkColor: Colors.black,
                      side: const BorderSide(color: Colors.white, width: 2),
                      onChanged: (value) {
                        setState(() {
                          accepted = value ?? false;
                        });
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Text.rich(
                      TextSpan(
                        text: 'Я согласен с ',
                        style: TextStyle(color: Colors.white, fontSize: 13),
                        children: [
                          TextSpan(
                            text: 'условиями использования\n',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                          TextSpan(text: 'и '),
                          TextSpan(
                            text: 'политикой конфиденциальности',
                            style: TextStyle(
                              color: AppColors.accent,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              PrimaryGreenButton(
                text: loading ? 'Создаем...' : 'Создать аккаунт',
                height: 60,
                onPressed: loading ? null : register,
              ),

              const SizedBox(height: 14),

              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Уже есть аккаунт?',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text(
                      'Войти',
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

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppColors.accent,
          fontSize: 18,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _RegisterField extends StatelessWidget {
  const _RegisterField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.suffix,
    this.trailing,
    this.keyboardType = TextInputType.text,
    this.obscureText = false,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final String? suffix;
  final Widget? trailing;
  final TextInputType keyboardType;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 74,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 27),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  obscureText: obscureText,
                  cursorColor: AppColors.accent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (suffix != null) ...[
            const SizedBox(width: 8),
            Text(
              suffix!,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
          if (trailing != null) ...[
            const SizedBox(width: 4),
            trailing!,
          ],
        ],
      ),
    );
  }
}