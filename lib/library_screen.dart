import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({
    super.key,
    required this.exercises,
  });

  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: AppGradients.background,
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    'Выберите упражнение',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 23,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              for (final exercise in exercises)
                Container(
                  margin: const EdgeInsets.only(bottom: 11),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(17),
                    border: Border.all(
                      color: AppColors.accent.withOpacity(0.32),
                    ),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 6,
                    ),
                    title: Text(
                      exercise.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    subtitle: Text(
                      '${exercise.weight}кг × ${exercise.reps} • ${exercise.sets} подхода',
                      style: const TextStyle(color: Colors.white60),
                    ),
                    trailing: const Icon(
                      Icons.arrow_forward_ios,
                      color: AppColors.accent,
                      size: 17,
                    ),
                    onTap: () => Navigator.pop(context, exercise),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}