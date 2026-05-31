import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';

class AddExerciseScreen extends StatefulWidget {
  const AddExerciseScreen({super.key});

  @override
  State<AddExerciseScreen> createState() => _AddExerciseScreenState();
}

class _AddExerciseScreenState extends State<AddExerciseScreen> {
  final nameController = TextEditingController(text: 'Жим лежа');
  final weightController = TextEditingController(text: '80');
  final repsController = TextEditingController(text: '8');
  final setsController = TextEditingController(text: '3');

  void save() {
    final name = nameController.text.trim();
    final weight = double.tryParse(
      weightController.text.trim().replaceAll(',', '.'),
    );
    final reps = int.tryParse(repsController.text.trim());
    final sets = int.tryParse(setsController.text.trim());

    if (name.isEmpty || weight == null || reps == null || sets == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.card,
          content: Text('Заполните все поля корректно'),
        ),
      );
      return;
    }

    if (weight <= 0 || reps <= 0 || sets <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: AppColors.card,
          content: Text('Вес, повторения и подходы должны быть больше 0'),
        ),
      );
      return;
    }

    final exercise = Exercise(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      weight: weight,
      reps: reps,
      sets: sets,
    );

    Navigator.pop(context, exercise);
  }

  @override
  void dispose() {
    nameController.dispose();
    weightController.dispose();
    repsController.dispose();
    setsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: AppGradients.background,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(26, 32, 26, 32),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 29,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Expanded(
                    child: Text(
                      'Новое упражнение',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 29,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 22),

              Container(
                padding: const EdgeInsets.fromLTRB(18, 18, 18, 20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.25),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.fitness_center,
                      color: AppColors.accent,
                      size: 34,
                    ),
                    SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Добавьте упражнение, укажите рабочий вес, повторения и подходы.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          height: 1.3,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              _ExerciseField(
                label: 'Название упражнения',
                controller: nameController,
                icon: Icons.sports_gymnastics,
                hint: 'Жим лежа',
              ),
              _ExerciseField(
                label: 'Рабочий вес',
                controller: weightController,
                icon: Icons.monitor_weight_outlined,
                hint: '80',
                suffix: 'кг',
                keyboardType: TextInputType.number,
              ),
              _ExerciseField(
                label: 'Повторения',
                controller: repsController,
                icon: Icons.repeat,
                hint: '8',
                suffix: 'раз',
                keyboardType: TextInputType.number,
              ),
              _ExerciseField(
                label: 'Подходы',
                controller: setsController,
                icon: Icons.format_list_numbered,
                hint: '3',
                suffix: 'подхода',
                keyboardType: TextInputType.number,
              ),

              const SizedBox(height: 18),

              PrimaryGreenButton(
                text: 'Сохранить упражнение',
                height: 62,
                onPressed: save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ExerciseField extends StatelessWidget {
  const _ExerciseField({
    required this.label,
    required this.controller,
    required this.icon,
    required this.hint,
    this.suffix,
    this.keyboardType = TextInputType.text,
  });

  final String label;
  final TextEditingController controller;
  final IconData icon;
  final String hint;
  final String? suffix;
  final TextInputType keyboardType;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppColors.accent,
            size: 30,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                TextField(
                  controller: controller,
                  keyboardType: keyboardType,
                  cursorColor: AppColors.accent,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                  ),
                  decoration: InputDecoration(
                    isDense: true,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.zero,
                    hintText: hint,
                    hintStyle: const TextStyle(
                      color: Colors.white38,
                      fontSize: 17,
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
        ],
      ),
    );
  }
}