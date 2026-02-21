import 'package:flutter/material.dart';
import '../../home/view/home_page.dart';
import '../../report/view/report_page.dart';

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle),
            label: 'Add',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.delete),
            label: 'Delete',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Report',
          ),
        ],
        onTap: (index) {
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
    );
  }
}
