import 'dart:async';

import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';

class RestScreen extends StatefulWidget {
  const RestScreen({
    super.key,
    required this.appState,
    required this.onFinishRest,
  });

  final WorkoutAppState appState;
  final VoidCallback onFinishRest;

  @override
  State<RestScreen> createState() => _RestScreenState();
}

class _RestScreenState extends State<RestScreen> {
  int secondsLeft = 90;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (secondsLeft <= 1) {
        timer.cancel();
        widget.onFinishRest();
      } else {
        setState(() {
          secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String get timerText {
    return '${secondsLeft}s';
  }

  @override
  Widget build(BuildContext context) {
    final exercise = widget.appState.selectedExercise;

    return DecoratedBox(
      decoration: AppGradients.background,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 24, 22, 32),
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
              widget.appState.setProgressText,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerText,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 49,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Отдых',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            for (int i = 0; i < exercise.sets; i++)
              _RestSetCard(
                title: 'Подход ${i + 1}',
                details: '${exercise.weight}кг × ${exercise.reps}',
                status: widget.appState.statusForSet(i),
              ),

            const SizedBox(height: 18),

            OutlineGreenButton(
              text: 'Закончить отдых',
              onPressed: widget.onFinishRest,
            ),
          ],
        ),
      ),
    );
  }
}

class _RestSetCard extends StatelessWidget {
  const _RestSetCard({
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
      height: 61,
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
            backgroundColor: color.withOpacity(status == 0 ? 0.65 : 1),
            child: const Icon(Icons.check, color: Colors.black, size: 18),
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
              Text(
                details,
                style: const TextStyle(
                  color: Color(0xFF9C9C9C),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}