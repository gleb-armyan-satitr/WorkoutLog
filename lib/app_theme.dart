import 'package:flutter/material.dart';

class AppColors {
  static const Color bgTop = Color(0xFF2E2E2E);
  static const Color bgBottom = Color(0xFFA5A5A5);
  static const Color card = Color(0xFF202020);
  static const Color cardSoft = Color(0xFF2A2A2A);
  static const Color accent = Color(0xFF55F58A);
  static const Color yellow = Color(0xFFFFD83D);
  static const Color inactive = Color(0xFF4D4D4D);
  static const Color danger = Color(0xFFFF3045);
  static const Color textMuted = Color(0xFFCFCFCF);
}

class AppGradients {
  static const BoxDecoration background = BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.bgTop,
        AppColors.bgBottom,
      ],
    ),
  );
}

class WorkoutLogo extends StatelessWidget {
  const WorkoutLogo({super.key, this.size = 58});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Text(
          'W',
          style: TextStyle(
            color: Colors.black,
            fontSize: size * 0.48,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}

class AppInputDecoration {
  static InputDecoration build({
    required String hint,
    IconData? icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF777777)),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: AppColors.accent,
              size: 20,
            ),
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(13),
        borderSide: BorderSide.none,
      ),
    );
  }
}

class PrimaryGreenButton extends StatelessWidget {
  const PrimaryGreenButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.icon,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.accent,
          disabledBackgroundColor: AppColors.accent.withOpacity(0.35),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(11),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              text,
              style: const TextStyle(
                color: Colors.black,
                fontSize: 16,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, color: Colors.black),
            ],
          ],
        ),
      ),
    );
  }
}

class OutlineGreenButton extends StatelessWidget {
  const OutlineGreenButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  final String text;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: AppColors.accent, width: 2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}