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
    final weight = int.tryParse(weightController.text.trim());
    final reps = int.tryParse(repsController.text.trim());
    final sets = int.tryParse(setsController.text.trim());

    if (name.isEmpty || weight == null || reps == null || sets == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Заполните все поля корректно')),
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
            padding: const EdgeInsets.fromLTRB(29, 34, 29, 32),
            children: [
              const Text(
                'Новое упражнение',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  decoration: TextDecoration.underline,
                  decorationColor: AppColors.accent,
                  decorationThickness: 2,
                  fontWeight: FontWeight.w900,
                ),
              ),

              const SizedBox(height: 36),

              _FieldBlock(
                label: 'Название упражнения',
                controller: nameController,
                keyboardType: TextInputType.text,
                suffix: Icons.keyboard_arrow_down,
              ),

              _FieldBlock(
                label: 'Вес',
                controller: weightController,
                keyboardType: TextInputType.number,
                suffixText: 'кг',
              ),

              _FieldBlock(
                label: 'Повторения',
                controller: repsController,
                keyboardType: TextInputType.number,
                suffixText: 'повторений',
              ),

              _FieldBlock(
                label: 'Подходы',
                controller: setsController,
                keyboardType: TextInputType.number,
                suffixText: 'подхода',
              ),

              const SizedBox(height: 18),

              PrimaryGreenButton(
                text: 'Сохранить упражнение',
                onPressed: save,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _FieldBlock extends StatelessWidget {
  const _FieldBlock({
    required this.label,
    required this.controller,
    required this.keyboardType,
    this.suffix,
    this.suffixText,
  });

  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final IconData? suffix;
  final String? suffixText;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 6),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              suffixIcon: suffix == null
                  ? null
                  : Icon(suffix, color: Colors.white70),
              suffixText: suffixText,
              suffixStyle: const TextStyle(
                color: Colors.white70,
                fontWeight: FontWeight.w700,
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 18,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(17),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}