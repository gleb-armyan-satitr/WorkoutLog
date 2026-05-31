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
          padding: const EdgeInsets.fromLTRB(22, 30, 22, 34),
          children: [
            const Text(
              'Профиль',
              style: TextStyle(
                color: Colors.white,
                fontSize: 29,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 48,
              backgroundColor: AppColors.accent,
              child: Icon(
                Icons.person,
                color: AppColors.card,
                size: 66,
              ),
            ),

            const SizedBox(height: 10),

            Center(
              child: Text(
                name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            const Center(
              child: Text(
                'Активен 45 дней',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 22),

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
              margin: const EdgeInsets.only(top: 8, bottom: 24),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.track_changes, color: AppColors.accent, size: 28),
                      SizedBox(width: 12),
                      Text(
                        'Цели тренировок',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Набор мышечной массы',
                    style: TextStyle(color: Colors.white, fontSize: 15),
                  ),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
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
                width: 178,
                height: 64,
                child: OutlinedButton.icon(
                  onPressed: logout,
                  icon: const Icon(
                    Icons.logout,
                    color: AppColors.danger,
                    size: 22,
                  ),
                  label: const Text(
                    'Выйти из\nаккаунта',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 14,
                      height: 1.15,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    backgroundColor: AppColors.darkButton,
                    side: const BorderSide(
                      color: AppColors.danger,
                      width: 2,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(13),
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
      height: 69,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 27),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ],
            ),
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
            fontSize: 24,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}