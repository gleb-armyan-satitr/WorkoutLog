import 'package:flutter/material.dart';

import 'add_exercise_screen.dart';
import 'app_state.dart';
import 'app_theme.dart';
import 'library_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({
    super.key,
    required this.appState,
    required this.onChanged,
    required this.onStartRest,
  });

  final WorkoutAppState appState;
  final VoidCallback onChanged;
  final VoidCallback onStartRest;

  @override
  Widget build(BuildContext context) {
    final exercise = appState.selectedExercise;

    return DecoratedBox(
      decoration: AppGradients.background,
      child: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(22, 24, 22, 96),
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appState.setProgressText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 12),

                Container(
                  height: 143,
                  decoration: BoxDecoration(
                    color: AppColors.card.withOpacity(0.96),
                    borderRadius: BorderRadius.circular(32),
                    border: Border.all(
                      color: Colors.white.withOpacity(0.18),
                      width: 1,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      appState.workoutFinished
                          ? 'Тренировка\nзавершена!'
                          : 'Выполняется\nподход...',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 29,
                        height: 1.35,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                for (int i = 0; i < exercise.sets; i++)
                  _SetCard(
                    title: 'Подход ${i + 1}',
                    details: '${exercise.weight}кг × ${exercise.reps}',
                    status: appState.statusForSet(i),
                  ),

                const SizedBox(height: 14),

                Row(
                  children: [
                    Expanded(
                      child: OutlineGreenButton(
                        text: 'Отдых',
                        onPressed: onStartRest,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlineGreenButton(
                        text: 'Завершить\nподход',
                        onPressed: () {
                          final finished = appState.completeCurrentSet();
                          onChanged();

                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              backgroundColor: AppColors.card,
                              content: Text(
                                finished
                                    ? 'Тренировка сохранена в историю'
                                    : 'Подход завершён',
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                Center(
                  child: SizedBox(
                    width: 160,
                    child: OutlineGreenButton(
                      text: 'Выбрать\nупражнение',
                      onPressed: () async {
                        final result = await Navigator.push<Exercise>(
                          context,
                          MaterialPageRoute(
                            builder: (_) => LibraryScreen(
                              exercises: appState.exercises,
                            ),
                          ),
                        );

                        if (result != null) {
                          appState.selectExercise(result);
                          onChanged();
                        }
                      },
                    ),
                  ),
                ),
              ],
            ),

            Positioned(
              right: 19,
              bottom: 20,
              child: FloatingActionButton(
                backgroundColor: AppColors.accent,
                elevation: 0,
                onPressed: () async {
                  final result = await Navigator.push<Exercise>(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AddExerciseScreen(),
                    ),
                  );

                  if (result != null) {
                    appState.addExercise(result);
                    onChanged();
                  }
                },
                child: const Icon(Icons.add, color: Colors.black, size: 34),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SetCard extends StatelessWidget {
  const _SetCard({
    required this.title,
    required this.details,
    required this.status,
  });

  final String title;
  final String details;
  final int status;

  Color get color {
    if (status == 2) return AppColors.accent;
    if (status == 1) return AppColors.yellow;
    return AppColors.inactive;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 63,
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.95),
        borderRadius: BorderRadius.circular(17),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 15,
            backgroundColor: color,
            child: const Icon(
              Icons.check,
              color: Colors.black,
              size: 18,
            ),
          ),
          const SizedBox(width: 14),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                details,
                style: const TextStyle(
                  color: Color(0xFF9C9C9C),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}