import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({
    super.key,
    required this.appState,
    required this.onChanged,
  });

  final WorkoutAppState appState;
  final VoidCallback onChanged;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool editMode = false;

  late final TextEditingController nameController;
  late final TextEditingController phoneController;
  late final TextEditingController birthDateController;
  late final TextEditingController goalController;
  late final TextEditingController currentWeightController;
  late final TextEditingController targetWeightController;
  late final TextEditingController bodyFatController;
  late final TextEditingController weeklyGoalController;

  @override
  void initState() {
    super.initState();

    final profile = widget.appState.profile;

    nameController = TextEditingController(text: profile.name);
    phoneController = TextEditingController(text: profile.phone);
    birthDateController = TextEditingController(text: profile.birthDate);
    goalController = TextEditingController(text: profile.goal);
    currentWeightController = TextEditingController(
      text: formatWeight(profile.currentWeight),
    );
    targetWeightController = TextEditingController(
      text: formatWeight(profile.targetWeight),
    );
    bodyFatController = TextEditingController(
      text: formatWeight(profile.bodyFat),
    );
    weeklyGoalController = TextEditingController(
      text: profile.weeklyWorkoutsGoal.toString(),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    birthDateController.dispose();
    goalController.dispose();
    currentWeightController.dispose();
    targetWeightController.dispose();
    bodyFatController.dispose();
    weeklyGoalController.dispose();
    super.dispose();
  }

  Future<void> saveProfile() async {
    final currentWeight = double.tryParse(
          currentWeightController.text.trim().replaceAll(',', '.'),
        ) ??
        widget.appState.profile.currentWeight;

    final targetWeight = double.tryParse(
          targetWeightController.text.trim().replaceAll(',', '.'),
        ) ??
        widget.appState.profile.targetWeight;

    final bodyFat = double.tryParse(
          bodyFatController.text.trim().replaceAll(',', '.'),
        ) ??
        widget.appState.profile.bodyFat;

    final weeklyGoal = int.tryParse(weeklyGoalController.text.trim()) ??
        widget.appState.profile.weeklyWorkoutsGoal;

    final updated = widget.appState.profile.copyWith(
      name: nameController.text.trim().isEmpty
          ? widget.appState.profile.name
          : nameController.text.trim(),
      phone: phoneController.text.trim(),
      birthDate: birthDateController.text.trim(),
      goal: goalController.text.trim().isEmpty
          ? 'Набор мышечной массы'
          : goalController.text.trim(),
      currentWeight: currentWeight,
      targetWeight: targetWeight,
      bodyFat: bodyFat,
      weeklyWorkoutsGoal: weeklyGoal,
    );

    await widget.appState.saveProfile(updated);

    setState(() {
      editMode = false;
    });

    widget.onChanged();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        backgroundColor: AppColors.card,
        content: Text('Профиль сохранён'),
      ),
    );
  }

  Future<void> logout() async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    final profile = widget.appState.profile;

    return DecoratedBox(
      decoration: AppGradients.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 28, 22, 34),
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    editMode ? 'Редактирование' : 'Профиль',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 31,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () {
                    setState(() {
                      editMode = !editMode;
                    });
                  },
                  icon: Icon(
                    editMode ? Icons.close : Icons.edit,
                    color: AppColors.accent,
                    size: 30,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            const CircleAvatar(
              radius: 50,
              backgroundColor: AppColors.accent,
              child: Icon(
                Icons.person,
                color: AppColors.card,
                size: 70,
              ),
            ),

            const SizedBox(height: 11),

            Center(
              child: Text(
                editMode ? nameController.text : profile.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
            Center(
              child: Text(
                workoutsText(profile.workoutsDone),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(height: 22),

            if (editMode) ...[
              _EditTile(
                icon: Icons.person_outline,
                label: 'Имя',
                controller: nameController,
              ),
              _EditTile(
                icon: Icons.phone_outlined,
                label: 'Телефон',
                controller: phoneController,
              ),
              _EditTile(
                icon: Icons.calendar_month_outlined,
                label: 'Дата рождения',
                controller: birthDateController,
              ),
              _EditTile(
                icon: Icons.track_changes,
                label: 'Цель тренировок',
                controller: goalController,
              ),
              _EditTile(
                icon: Icons.monitor_weight_outlined,
                label: 'Текущий вес',
                controller: currentWeightController,
                suffix: 'кг',
                keyboardType: TextInputType.number,
              ),
              _EditTile(
                icon: Icons.flag_outlined,
                label: 'Целевой вес',
                controller: targetWeightController,
                suffix: 'кг',
                keyboardType: TextInputType.number,
              ),
              _EditTile(
                icon: Icons.percent,
                label: 'Процент жира',
                controller: bodyFatController,
                suffix: '%',
                keyboardType: TextInputType.number,
              ),
              _EditTile(
                icon: Icons.calendar_view_week,
                label: 'Тренировок в неделю',
                controller: weeklyGoalController,
                suffix: 'раз(-а)',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 12),

              PrimaryGreenButton(
                text: 'Сохранить изменения',
                height: 60,
                onPressed: saveProfile,
              ),

              const SizedBox(height: 20),
            ] else ...[
              _InfoTile(
                icon: Icons.person_outline,
                label: 'Имя',
                value: profile.name,
              ),
              _InfoTile(
                icon: Icons.email_outlined,
                label: 'Email',
                value: profile.email,
              ),
              _InfoTile(
                icon: Icons.phone_outlined,
                label: 'Телефон',
                value: profile.phone,
              ),
              _InfoTile(
                icon: Icons.calendar_month_outlined,
                label: 'Дата рождения',
                value: profile.birthDate,
              ),
            ],

            Container(
              margin: const EdgeInsets.only(top: 8, bottom: 24),
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.25),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(
                        Icons.track_changes,
                        color: AppColors.accent,
                        size: 28,
                      ),
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
                  const SizedBox(height: 6),
                  Text(
                    editMode ? goalController.text : profile.goal,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 11),
                  Text(
                    'На этой неделе: ${widget.appState.completedThisWeek()} из ${profile.weeklyWorkoutsGoal} тренировок',
                    style: const TextStyle(
                      color: AppColors.accent,
                      fontSize: 14,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _GoalValue(
                        value: '${profile.workoutsDone}',
                        label: 'Тренировок',
                      ),
                      _GoalValue(
                        value: '${formatWeight(profile.currentWeight)}кг',
                        label: 'сейчас',
                      ),
                      _GoalValue(
                        value: '${formatWeight(profile.targetWeight)}кг',
                        label: 'цель',
                      ),
                      _GoalValue(
                        value: '${formatWeight(profile.bodyFat)}%',
                        label: 'жир',
                      ),
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

class _EditTile extends StatelessWidget {
  const _EditTile({
    required this.icon,
    required this.label,
    required this.controller,
    this.suffix,
    this.keyboardType = TextInputType.text,
  });

  final IconData icon;
  final String label;
  final TextEditingController controller;
  final String? suffix;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      margin: const EdgeInsets.only(bottom: 13),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.accent,
            size: 27,
          ),
          const SizedBox(width: 17),
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
                  cursorColor: AppColors.accent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: const InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
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
        ],
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
            fontSize: 20,
            fontWeight: FontWeight.w900,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 11,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

String workoutsText(int count) {
  final mod10 = count % 10;
  final mod100 = count % 100;

  if (mod10 == 1 && mod100 != 11) {
    return '$count тренировка сохранена';
  }

  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return '$count тренировки сохранены';
  }

  return '$count тренировок сохранено';
}