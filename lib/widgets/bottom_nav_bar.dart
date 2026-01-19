import 'package:flutter/material.dart';

import '../core/theme.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isLawyer;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    required this.isLawyer,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.95),
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BottomNavigationBar(
          currentIndex: currentIndex,
          onTap: onTap,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          elevation: 0,
          selectedItemColor: AppTheme.primaryLightColor,
          unselectedItemColor: Colors.white.withOpacity(0.4),
          selectedFontSize: 8,
          unselectedFontSize: 8,
          items: [
            // Home
            BottomNavigationBarItem(
              icon: _buildNavIcon(
                Icons.home_outlined,
                Icons.home_rounded,
                0,
              ),
              label: 'HOME',
            ),

            // Second tab - different for lawyers vs clients
            BottomNavigationBarItem(
              icon: _buildNavIcon(
                isLawyer ? Icons.account_balance_wallet_outlined : Icons.add_circle_outline,
                isLawyer ? Icons.account_balance_wallet_rounded : Icons.add_circle_rounded,
                1,
              ),
              label: isLawyer ? 'EARNINGS' : 'POST',
            ),

            // Messages
            BottomNavigationBarItem(
              icon: _buildNavIcon(
                Icons.chat_bubble_outline_rounded,
                Icons.chat_bubble_rounded,
                2,
              ),
              label: 'CHAT',
            ),

            // Profile
            BottomNavigationBarItem(
              icon: _buildNavIcon(
                Icons.person_outline_rounded,
                Icons.person_rounded,
                3,
              ),
              label: 'ME',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavIcon(IconData outlinedIcon, IconData filledIcon, int index) {
    final isSelected = currentIndex == index;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isSelected ? filledIcon : outlinedIcon,
            size: 22,
          ),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}