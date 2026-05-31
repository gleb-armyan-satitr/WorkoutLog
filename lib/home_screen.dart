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
    final lastLog = appState.lastLogForExercise(exercise);
    final recommendedWeight = appState.recommendedWeightFor(exercise);

    return DecoratedBox(
      decoration: AppGradients.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 25, 22, 34),
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
                  appState.workoutStatusText,
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
                  : '${formatWeight(lastLog.weight)}кг × ${lastLog.reps}',
              recommendationText:
                  'Попробуй ${formatWeight(recommendedWeight)}кг × ${exercise.reps}',
              completedText: lastLog == null
                  ? 'Создай первую запись прогресса'
                  : lastLog.isFullyCompleted
                      ? 'Прошлая тренировка выполнена полностью'
                      : 'Лучше повторить прошлый вес',
            ),

            const SizedBox(height: 17),

            for (int i = 0; i < exercise.sets; i++)
              _SetCard(
                title: 'Подход ${i + 1}',
                details:
                    '${formatWeight(exercise.weight)}кг × ${exercise.reps}',
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
                    onPressed: appState.completedSets.isEmpty ||
                            appState.workoutFinished
                        ? null
                        : onStartRest,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: DarkActionButton(
                    text: appState.setInProgress
                        ? 'Завершить\nподход'
                        : appState.workoutFinished
                            ? 'Завершено'
                            : 'Начать\nподход',
                    height: 60,
                    fontSize: 17,
                    onPressed: appState.workoutFinished
                        ? null
                        : () async {
                            if (!appState.setInProgress) {
                              appState.startCurrentSet();
                              onChanged();
                              return;
                            }

                            final finished =
                                await appState.completeCurrentSet();

                            final nextRecommendedWeight =
                                appState.recommendedWeightFor(
                              appState.selectedExercise,
                            );

                            onChanged();

                            if (!context.mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                backgroundColor: AppColors.card,
                                content: Text(
                                  finished
                                      ? 'Тренировка сохранена. Следующий вес: ${formatWeight(nextRecommendedWeight)}кг'
                                      : 'Подход завершён',
                                ),
                              ),
                            );
                          },
                  ),
                ),
              ],
            ),

            if (appState.setInProgress && !appState.workoutFinished) ...[
              const SizedBox(height: 12),
              SizedBox(
                height: 58,
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await appState.failCurrentSet();

                    final nextRecommendedWeight =
                        appState.recommendedWeightFor(
                      appState.selectedExercise,
                    );

                    onChanged();

                    if (!context.mounted) return;

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        backgroundColor: AppColors.card,
                        content: Text(
                          'Тренировка сохранена как неполная. Следующий вес: ${formatWeight(nextRecommendedWeight)}кг',
                        ),
                      ),
                    );
                  },
                  icon: const Icon(
                    Icons.close,
                    color: AppColors.danger,
                    size: 23,
                  ),
                  label: const Text(
                    'Не получилось',
                    style: TextStyle(
                      color: AppColors.danger,
                      fontSize: 16,
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
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                ),
              ),
            ],

            if (appState.workoutFinished) ...[
              const SizedBox(height: 13),
              DarkActionButton(
                text:
                    'Начать новую тренировку с ${formatWeight(recommendedWeight)}кг',
                height: 60,
                fontSize: 16,
                onPressed: () async {
                  await appState.startNextWorkoutWithRecommendedWeight();
                  onChanged();
                },
              ),
            ],

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
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
                const SizedBox(width: 13),
                SizedBox(
                  width: 72,
                  height: 60,
                  child: ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.push<Exercise>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const AddExerciseScreen(),
                        ),
                      );

                      if (result != null) {
                        await appState.addExercise(result);
                        onChanged();
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.accent,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: const Icon(
                      Icons.add,
                      color: Colors.black,
                      size: 34,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RecommendationCard extends StatelessWidget {
  const _RecommendationCard({
    required this.lastText,
    required this.recommendationText,
    required this.completedText,
  });

  final String lastText;
  final String recommendationText;
  final String completedText;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 15),
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
            size: 31,
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Умная рекомендация',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 4),
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
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  completedText,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
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