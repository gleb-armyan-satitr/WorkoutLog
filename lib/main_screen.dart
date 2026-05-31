import 'package:flutter/material.dart';

import 'app_state.dart';
import 'app_theme.dart';
import 'history_screen.dart';
import 'home_screen.dart';
import 'notification_service.dart';
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
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadApp();
  }

  Future<void> loadApp() async {
    await appState.loadFromFirestore();

    await NotificationService.instance.initialize(
      onForegroundMessage: (title, body) {
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.card,
            content: Text('$title\n$body'),
            duration: const Duration(seconds: 4),
          ),
        );
      },
    );

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

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

    return ProfileScreen(
      appState: appState,
      onChanged: refresh,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: DecoratedBox(
          decoration: AppGradients.background,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.accent,
            ),
          ),
        ),
      );
    }

    return Scaffold(
      body: _currentPage(),
      bottomNavigationBar: Container(
        height: 82,
        decoration: const BoxDecoration(
          color: AppColors.card,
          border: Border(
            top: BorderSide(
              color: Color(0xFF313131),
              width: 1,
            ),
          ),
        ),
        child: SafeArea(
          top: false,
          child: BottomNavigationBar(
            currentIndex: selectedIndex,
            onTap: (index) {
              setState(() {
                selectedIndex = index;
                if (index != 0) restMode = false;
              });
            },
            backgroundColor: AppColors.card,
            selectedItemColor: AppColors.accent,
            unselectedItemColor: Colors.white,
            selectedFontSize: 13,
            unselectedFontSize: 13,
            selectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w900,
              height: 1.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              height: 1.2,
            ),
            iconSize: 29,
            type: BottomNavigationBarType.fixed,
            elevation: 0,
            items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.home_outlined),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.home_outlined,
                    color: AppColors.accent,
                    size: 31,
                  ),
                ),
                label: 'Главная',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.history),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.history,
                    color: AppColors.accent,
                    size: 31,
                  ),
                ),
                label: 'История',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(Icons.person_outline),
                ),
                activeIcon: Padding(
                  padding: EdgeInsets.only(bottom: 3),
                  child: Icon(
                    Icons.person_outline,
                    color: AppColors.accent,
                    size: 31,
                  ),
                ),
                label: 'Профиль',
              ),
            ],
          ),
        ),
      ),
    );
  }
}