import 'package:flutter/material.dart';

import '../utils/constants.dart';

enum AppTab { home, stories }

class BottomNavigationBarWidget extends StatelessWidget {
  final AppTab currentTab;
  final ValueChanged<AppTab> onTabSelected;

  const BottomNavigationBarWidget({
    super.key,
    required this.currentTab,
    required this.onTabSelected,
  });

  int _index(AppTab tab) => tab == AppTab.home ? 0 : 1;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: _index(currentTab),
      onTap: (i) {
        onTabSelected(i == 0 ? AppTab.home : AppTab.stories);
      },
      type: BottomNavigationBarType.fixed,
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.primary,
      unselectedItemColor: AppColors.textLight,
      showUnselectedLabels: true,
      elevation: 8,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          activeIcon: Icon(Icons.home),
          label: 'Home',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.book_outlined),
          activeIcon: Icon(Icons.book),
          label: 'Stories',
        ),
      ],
    );
  }
}

