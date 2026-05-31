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
    final lastLog = _lastLogForCurrentExercise();

    final double recommendedWeight = lastLog == null
        ? exercise.weight.toDouble()
        : lastLog.exercise.weight + 2.5;

    return DecoratedBox(
      decoration: AppGradients.background,
      child: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.fromLTRB(22, 25, 22, 98),
              children: [
                Text(
                  exercise.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 31,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  appState.setProgressText,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  height: 157,
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
                        fontSize: 34,
                        height: 1.25,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 13),

                _RecommendationCard(
                  lastText: lastLog == null
                      ? 'Пока нет прошлой тренировки'
                      : '${lastLog.exercise.weight}кг × ${lastLog.exercise.reps}',
                  recommendationText:
                      'Попробуй ${_formatWeight(recommendedWeight)}кг × ${exercise.reps}',
                ),

                const SizedBox(height: 17),

                for (int i = 0; i < exercise.sets; i++)
                  _SetCard(
                    title: 'Подход ${i + 1}',
                    details: '${exercise.weight}кг × ${exercise.reps}',
                    status: appState.statusForSet(i),
                  ),

                const SizedBox(height: 18),

                Row(
                  children: [
                    Expanded(
                      child: DarkActionButton(
                        text: 'Отдых',
                        height: 60,
                        fontSize: 17,
                        onPressed: onStartRest,
                      ),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: DarkActionButton(
                        text: 'Завершить\nподход',
                        height: 60,
                        fontSize: 17,
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

                const SizedBox(height: 13),

                Center(
                  child: SizedBox(
                    width: 178,
                    child: DarkActionButton(
                      text: 'Выбрать\nупражнение',
                      height: 60,
                      fontSize: 17,
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
              right: 22,
              bottom: 22,
              child: SizedBox(
                width: 66,
                height: 66,
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
                  child: const Icon(Icons.add, color: Colors.black, size: 38),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  WorkoutLog? _lastLogForCurrentExercise() {
    for (final log in appState.logs) {
      if (log.exercise.name == appState.selectedExercise.name) {
        return log;
      }
    }

    return null;
  }

  String _formatWeight(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    }

    return value.toStringAsFixed(1);
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.lastText,
    required this.recommendationText,
  });

  final String lastText;
  final String recommendationText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 13, 16, 14),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: AppColors.accent.withOpacity(0.25),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.trending_up,
            color: AppColors.accent,
            size: 29,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Рекомендация',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'В прошлый раз: $lastText',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  recommendationText,
                  style: const TextStyle(
                    color: AppColors.accent,
                    fontSize: 15,
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
      height: 69,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 17),
      decoration: BoxDecoration(
        color: AppColors.card.withOpacity(0.95),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color,
            child: const Icon(
              Icons.check,
              color: Colors.black,
              size: 20,
            ),
          ),
          const SizedBox(width: 17),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                details,
                style: const TextStyle(
                  color: Color(0xFFB8B8B8),
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}