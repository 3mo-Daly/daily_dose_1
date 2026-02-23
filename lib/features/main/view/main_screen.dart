import 'package:flutter/material.dart';
import '../../home/view/home_page.dart';
import '../../report/view/report_page.dart';
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
        index: _currentIndex == 3 ? 1 : 0,
        children: [
          HomePage(key: _homePageKey),
          const ReportPage(),
        ],
      ),
      bottomNavigationBar: NavigationBarTheme(
        data: NavigationBarThemeData(
          indicatorColor: Theme.of(context).colorScheme.primary.withOpacity(0.12),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return TextStyle(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.w700, fontSize: 13);
            }
            return TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500, fontSize: 12);
          }),
        ),
        child: NavigationBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          elevation: 0,
          selectedIndex: _currentIndex,
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: Theme.of(context).colorScheme.primary),
              label: 'Home',
            ),
            NavigationDestination(
              icon: const Icon(Icons.add_circle_outline),
              selectedIcon: Icon(Icons.add_circle, color: Theme.of(context).colorScheme.primary),
              label: 'Add',
            ),
            NavigationDestination(
              icon: const Icon(Icons.delete_outline),
              selectedIcon: Icon(Icons.delete, color: Theme.of(context).colorScheme.primary),
              label: 'Delete',
            ),
            NavigationDestination(
              icon: const Icon(Icons.bar_chart_outlined),
              selectedIcon: Icon(Icons.bar_chart_rounded, color: Theme.of(context).colorScheme.primary),
              label: 'Report',
            ),
          ],
          onDestinationSelected: (index) {
            if (index == 1) {
              // Add Medicine action
              _homePageKey.currentState?.navigateToAddMedicine();
            } else if (index == 2) {
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
