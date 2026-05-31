import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'profile_screen.dart';
import 'rest_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final WorkoutAppState appState = WorkoutAppState();

  int selectedIndex = 0;
  bool restMode = false;

  void refresh() {
    setState(() {});
  }

  Widget _currentPage() {
    if (selectedIndex == 0 && restMode) {
      return RestScreen(
        appState: appState,
        onFinishRest: () {
          setState(() {
            restMode = false;
          });
        },
      );
    }

    if (selectedIndex == 0) {
      return HomeScreen(
        appState: appState,
        onChanged: refresh,
        onStartRest: () {
          setState(() {
            restMode = true;
          });
        },
      );
    }

    if (selectedIndex == 1) {
      return HistoryScreen(appState: appState);
    }

    return const ProfileScreen();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _currentPage(),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(color: Color(0xFF313131), width: 1),
          ),
        ),
        child: BottomNavigationBar(
          currentIndex: selectedIndex,
          onTap: (index) {
            setState(() {
              selectedIndex = index;
              if (index != 0) restMode = false;
            });
          },
          backgroundColor: AppColors.card,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.white,
          selectedFontSize: 11,
          unselectedFontSize: 11,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home_outlined, color: AppColors.accent),
              label: 'Главная',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history),
              activeIcon: Icon(Icons.history, color: AppColors.accent),
              label: 'История',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person_outline, color: AppColors.accent),
              label: 'Профиль',
            ),
          ],
        ),
      ),
    );
  }
}