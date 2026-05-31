import 'dart:math';

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
    final progressLogs = appState.progressLogsForSelectedExercise();
    final lastLog = appState.lastLogForExercise(exercise);
    final recommended = appState.recommendedWeightFor(exercise);

    return DecoratedBox(
      decoration: AppGradients.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 25, 22, 34),
          children: [
            Text(
              'Прогресс',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 31,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              exercise.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),

            const SizedBox(height: 18),

            Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(
                  color: AppColors.accent.withOpacity(0.22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'График рабочего веса',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    progressLogs.isEmpty
                        ? 'Завершите тренировку, чтобы появился график'
                        : 'Вес по завершённым тренировкам',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    height: 220,
                    width: double.infinity,
                    child: CustomPaint(
                      painter: _ProgressChartPainter(progressLogs),
                      child: progressLogs.isEmpty
                          ? const Center(
                              child: Text(
                                'Нет данных',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            )
                          : null,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 17),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Сейчас',
                    value: '${formatWeight(exercise.weight)}кг',
                    icon: Icons.fitness_center,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'Следующий',
                    value: '${formatWeight(recommended)}кг',
                    icon: Icons.trending_up,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _StatCard(
                    title: 'Тренировок',
                    value: '${progressLogs.length}',
                    icon: Icons.history,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _StatCard(
                    title: 'За неделю',
                    value:
                        '${appState.completedThisWeek()}/${appState.profile.weeklyWorkoutsGoal}',
                    icon: Icons.calendar_month,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            const Text(
              'Последние тренировки',
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w900,
              ),
            ),

            const SizedBox(height: 12),

            if (progressLogs.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                ),
                child: const Text(
                  'История пока пустая. Завершите все подходы на главном экране, и приложение начнёт строить прогресс.',
                  style: TextStyle(
                    color: Colors.white70,
                    height: 1.35,
                    fontSize: 15,
                  ),
                ),
              )
            else
              for (final log in progressLogs.reversed)
                Container(
                  margin: const EdgeInsets.only(bottom: 11),
                  padding: const EdgeInsets.all(17),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Row(
                    children: [
                      const CircleAvatar(
                        radius: 20,
                        backgroundColor: AppColors.accent,
                        child: Icon(
                          Icons.check,
                          color: Colors.black,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              log.exerciseName,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            Text(
                              '${formatWeight(log.weight)}кг × ${log.reps} • ${log.setsCompleted}/${log.sets} подхода',
                              style: const TextStyle(
                                color: Colors.white60,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Следующая цель: ${formatWeight(log.recommendedNextWeight)}кг',
                              style: const TextStyle(
                                color: AppColors.accent,
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                              ),
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

            if (lastLog != null) ...[
              const SizedBox(height: 10),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: AppColors.accent.withOpacity(0.25),
                  ),
                ),
                child: Text(
                  'Вы уже сделали ${formatWeight(lastLog.weight)}кг × ${lastLog.reps}. Следующая рекомендация: ${formatWeight(recommended)}кг × ${exercise.reps}.',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month';
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
  });

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 92,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.accent, size: 27),
          const SizedBox(width: 11),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                  ),
                ),
                Text(
                  value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
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

class _ProgressChartPainter extends CustomPainter {
  _ProgressChartPainter(this.logs);

  final List<WorkoutLog> logs;

  @override
  void paint(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..strokeWidth = 1;

    final linePaint = Paint()
      ..color = AppColors.accent
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pointPaint = Paint()
      ..color = AppColors.accent
      ..style = PaintingStyle.fill;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
    );

    const leftPadding = 34.0;
    const bottomPadding = 28.0;
    const topPadding = 12.0;
    const rightPadding = 12.0;

    final chartWidth = size.width - leftPadding - rightPadding;
    final chartHeight = size.height - topPadding - bottomPadding;

    for (int i = 0; i < 4; i++) {
      final y = topPadding + chartHeight * i / 3;
      canvas.drawLine(
        Offset(leftPadding, y),
        Offset(size.width - rightPadding, y),
        gridPaint,
      );
    }

    if (logs.isEmpty) {
      return;
    }

    final weights = logs.map((log) => log.weight).toList();
    final minWeight = weights.reduce(min);
    final maxWeight = weights.reduce(max);
    final range = max(1.0, maxWeight - minWeight);

    final points = <Offset>[];

    for (int i = 0; i < logs.length; i++) {
      final x = logs.length == 1
          ? leftPadding + chartWidth / 2
          : leftPadding + chartWidth * i / (logs.length - 1);

      final normalized = (logs[i].weight - minWeight) / range;
      final y = topPadding + chartHeight - normalized * chartHeight;

      points.add(Offset(x, y));
    }

    if (points.length == 1) {
      canvas.drawCircle(points.first, 6, pointPaint);
    } else {
      final path = Path()..moveTo(points.first.dx, points.first.dy);

      for (final point in points.skip(1)) {
        path.lineTo(point.dx, point.dy);
      }

      canvas.drawPath(path, linePaint);

      for (final point in points) {
        canvas.drawCircle(point, 6, pointPaint);
      }
    }

    final minLabel = '${formatWeight(minWeight)}кг';
    final maxLabel = '${formatWeight(maxWeight)}кг';

    textPainter.text = TextSpan(
      text: maxLabel,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, const Offset(0, topPadding - 5));

    textPainter.text = TextSpan(
      text: minLabel,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 11,
        fontWeight: FontWeight.w700,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(0, topPadding + chartHeight - 8));

    if (logs.isNotEmpty) {
      textPainter.text = TextSpan(
        text: _shortDate(logs.first.date),
        style: const TextStyle(color: Colors.white60, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(canvas, Offset(leftPadding, size.height - 20));

      textPainter.text = TextSpan(
        text: _shortDate(logs.last.date),
        style: const TextStyle(color: Colors.white60, fontSize: 10),
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(size.width - rightPadding - textPainter.width, size.height - 20),
      );
    }
  }

  static String _shortDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day.$month';
  }

  @override
  bool shouldRepaint(covariant _ProgressChartPainter oldDelegate) {
    return oldDelegate.logs != logs;
  }
}