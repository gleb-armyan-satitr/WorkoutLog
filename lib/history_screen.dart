import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({
    super.key,
    required this.appState,
  });

  final WorkoutAppState appState;

  @override
  Widget build(BuildContext context) {
    final exercise = appState.selectedExercise;

    return DecoratedBox(
      decoration: AppGradients.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 27, 22, 32),
          children: [
            Text(
              'Прогресс ${exercise.name.toLowerCase()}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 2),
            const Text(
              'За последние 8 недель',
              style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 42),

            Container(
              padding: const EdgeInsets.fromLTRB(18, 16, 18, 22),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(26),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Эта неделя',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: List.generate(7, (index) {
                      final completed = _hasTrainingOnWeekday(index + 1);

                      return Column(
                        children: [
                          Text(
                            _weekdayShort(index),
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 5),
                          CircleAvatar(
                            radius: 11,
                            backgroundColor:
                                completed ? AppColors.accent : Colors.white70,
                          ),
                        ],
                      );
                    }),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            const Text(
              'Последние тренировки',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 12),

            if (appState.logs.isEmpty)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'История пока пустая. Завершите все подходы на главном экране.',
                  style: TextStyle(color: Colors.white70, height: 1.35),
                ),
              )
            else
              for (final log in appState.logs)
                Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.fitness_center,
                        color: AppColors.accent,
                      ),
                      const SizedBox(width: 13),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.exercise.name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${log.exercise.weight}кг × ${log.exercise.reps} • ${log.setsCompleted} подхода',
                              style: const TextStyle(color: Colors.white60),
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _formatDate(log.date),
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
          ],
        ),
      ),
    );
  }

  bool _hasTrainingOnWeekday(int weekday) {
    final now = DateTime.now();
    final startOfWeek = DateTime(
      now.year,
      now.month,
      now.day,
    ).subtract(Duration(days: now.weekday - 1));

    final targetDay = startOfWeek.add(Duration(days: weekday - 1));

    return appState.logs.any((log) {
      return log.date.year == targetDay.year &&
          log.date.month == targetDay.month &&
          log.date.day == targetDay.day;
    });
  }

  String _weekdayShort(int index) {
    const days = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return days[index];
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month.${date.year}';
  }
}