import 'package:flutter/material.dart';

class KasselBottomNav extends StatelessWidget {
  const KasselBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex.clamp(0, 3),
      onTap: onTap,
      type: BottomNavigationBarType.fixed,
      selectedItemColor: Colors.blue,
      unselectedItemColor: Colors.black54,
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Home",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.school),
          label: "IELTS Prep",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.sports_esports),
          label: "Learn & Play",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: "My Account",
        ),
      ],
    );
  }
}
