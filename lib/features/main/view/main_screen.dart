import 'package:flutter/material.dart';
import '../../home/view/home_page.dart';
import '../../report/view/report_page.dart';
import '../../all_medicines/view/all_medicines_page.dart';
import '../../../core/theme/app_theme.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  final GlobalKey<HomePageState> _homePageKey = GlobalKey<HomePageState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex == 4 ? 2 : (_currentIndex == 1 ? 1 : 0),
        children: [
          HomePage(key: _homePageKey),
          const AllMedicinesPage(),
          const ReportPage(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Theme.of(context).colorScheme.secondaryContainer,
          indicatorShape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w800, fontSize: 13);
            }
            return TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w600, fontSize: 12);
          }),
        ),
        child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          selectedIndex: _currentIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 28),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.list_alt),
              selectedIcon: Icon(Icons.list_alt_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 28),
              label: 'All',
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 28),
              label: 'Add',
            ),
            NavigationDestination(
              icon: const Icon(Icons.delete_outline),
              selectedIcon: Icon(Icons.delete, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 28),
              label: 'Delete',
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: Theme.of(context).colorScheme.onSecondaryContainer, size: 28),
              label: 'Report',
            ),
          ],
          onDestinationSelected: (index) {
            if (index == 2) {
              // Add Medicine action
              _homePageKey.currentState?.navigateToAddMedicine();
            } else if (index == 3) {
              // Delete Action
              _homePageKey.currentState?.showAdvancedDeleteOptions();
            } else {
              // Switch tab
              setState(() {
                _currentIndex = index;
              });
            }
          },
        ),
      ),
    );
  }
}
