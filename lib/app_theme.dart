import 'package:flutter/material.dart';

class AppColors {
  static const Color bgTop = Color(0xFF2E2E2E);
  static const Color bgBottom = Color(0xFFA8A8A8);

  static const Color card = Color(0xFF202020);
  static const Color cardSoft = Color(0xFF2B2B2B);
  static const Color darkButton = Color(0xFF242424);

  static const Color accent = Color(0xFF55F58A);
  static const Color yellow = Color(0xFFFFD83D);
  static const Color inactive = Color(0xFF5B5B5B);
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
  const WorkoutLogo({
    super.key,
    this.width = 58,
    this.height = 58,
    this.compact = true,
  });

  final double width;
  final double height;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: compact ? 59 : width,
      height: compact ? 56 : height,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(
        child: Text(
          'W',
          style: TextStyle(
            color: Colors.black,
            fontSize: compact ? 31 : 34,
            fontWeight: FontWeight.w900,
            height: 1,
          ),
        ),
      ),
    );
  }
}

class TopWideLogo extends StatelessWidget {
  const TopWideLogo({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 57,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.accent,
        borderRadius: BorderRadius.circular(15),
      ),
      child: const Center(
        child: Text(
          'W',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w900,
            height: 1,
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
      hintStyle: const TextStyle(
        color: Color(0xFFBEBEBE),
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      prefixIcon: icon == null
          ? null
          : Icon(
              icon,
              color: AppColors.accent,
              size: 24,
            ),
      filled: true,
      fillColor: AppColors.card,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 18,
        vertical: 19,
      ),
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
    this.height = 56,
  });

  final String text;
  final VoidCallback? onPressed;
  final IconData? icon;
  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
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
                fontSize: 17,
                fontWeight: FontWeight.w700,
              ),
            ),
            if (icon != null) ...[
              const SizedBox(width: 10),
              Icon(icon, color: Colors.black, size: 24),
            ],
          ],
        ),
      ),
    );
  }
}

class DarkActionButton extends StatelessWidget {
  const DarkActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.height = 56,
    this.fontSize = 16,
  });

  final String text;
  final VoidCallback? onPressed;
  final double height;
  final double fontSize;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: AppColors.darkButton,
          side: const BorderSide(
            color: AppColors.accent,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 10),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.white,
            fontSize: fontSize,
            height: 1.15,
            fontWeight: FontWeight.w900,
          ),
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
    this.height = 56,
  });

  final String text;
  final VoidCallback? onPressed;
  final double height;

  @override
  Widget build(BuildContext context) {
    return DarkActionButton(
      text: text,
      onPressed: onPressed,
      height: height,
    );
  }
}