import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    final name = user?.displayName?.isNotEmpty == true
        ? user!.displayName!
        : 'Иван Петров';

    final email = user?.email ?? 'ivan@example.com';

    return DecoratedBox(
      decoration: AppGradients.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 32),
          children: [
            const Text(
              'Профиль',
              style: TextStyle(
                color: Colors.white,
                fontSize: 25,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 8),

            CircleAvatar(
              radius: 42,
              backgroundColor: AppColors.accent,
              child: const Icon(
                Icons.person,
                color: AppColors.card,
                size: 58,
              ),
            ),

            const SizedBox(height: 8),

            Center(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Активен 45 дней',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
            ),

            const SizedBox(height: 18),

            _InfoTile(
              icon: Icons.person_outline,
              label: 'Имя',
              value: name,
            ),
            _InfoTile(
              icon: Icons.email_outlined,
              label: 'Email',
              value: email,
            ),
            const _InfoTile(
              icon: Icons.phone_outlined,
              label: 'Телефон',
              value: '+7 999 123-45-67',
            ),
            const _InfoTile(
              icon: Icons.calendar_month_outlined,
              label: 'Дата рождения',
              value: '15 марта 1995',
            ),

            Container(
              margin: const EdgeInsets.only(top: 4, bottom: 12),
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.track_changes, color: AppColors.accent),
                      SizedBox(width: 10),
                      Text(
                        'Цели тренировок',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Набор мышечной массы',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: const [
                      _GoalValue(value: '156', label: 'Тренировок'),
                      _GoalValue(value: '78', label: 'кг вес'),
                      _GoalValue(value: '12%', label: 'жир'),
                    ],
                  ),
                ],
              ),
            ),

            Center(
              child: SizedBox(
                width: 150,
                height: 56,
                child: OutlinedButton.icon(
                  onPressed: logout,
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.danger,
                    size: 18,
                  ),
                  label: const Text(
                    'Выйти из аккаунта',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.danger, width: 2),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(11),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 58,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 22),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GoalValue extends StatelessWidget {
  const _GoalValue({
    required this.value,
    required this.label,
  });

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppColors.accent,
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white, fontSize: 11),
        ),
      ],
    );
  }
}