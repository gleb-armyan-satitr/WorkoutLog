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
              widget.appState.setProgressText,
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      timerText,
                      style: const TextStyle(
                        color: AppColors.accent,
                        fontSize: 55,
                        fontWeight: FontWeight.w900,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Отдых',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 25),

            for (int i = 0; i < exercise.sets; i++)
              _RestSetCard(
                title: 'Подход ${i + 1}',
                details: '${exercise.weight}кг × ${exercise.reps}',
                status: widget.appState.statusForSet(i),
              ),

            const SizedBox(height: 22),

            DarkActionButton(
              text: 'Закончить отдых',
              height: 60,
              fontSize: 17,
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
            backgroundColor: color.withOpacity(status == 0 ? 0.75 : 1),
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