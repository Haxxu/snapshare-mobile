import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:snapshare_mobile/utils/colors.dart';

import 'package:snapshare_mobile/utils/global_variables.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});

  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _page = 0;
  late PageController pageController;

  @override
  void initState() {
    super.initState();
    pageController = PageController();
  }

  @override
  void dispose() {
    super.dispose();
    pageController.dispose();
  }

  void navigationTapped(int page) {
    pageController.jumpToPage(page);
  }

  void onPageChanged(int page) {
    setState(() {
      _page = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        physics: const NeverScrollableScrollPhysics(),
        controller: pageController,
        onPageChanged: onPageChanged,
        children: mainScreenItems,
      ),
      bottomNavigationBar: CupertinoTabBar(
        backgroundColor: mobileBackgroundColor,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home,
                color: _page == 0 ? primaryColor : secondaryColor),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search,
                color: _page == 1 ? primaryColor : secondaryColor),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.add_circle_outline,
                color: _page == 2 ? primaryColor : secondaryColor),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person,
                color: _page == 3 ? primaryColor : secondaryColor),
          ),
        ],
        onTap: navigationTapped,
      ),
    );
  }
}
