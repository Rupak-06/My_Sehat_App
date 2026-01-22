import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/emergency/presentation/widgets/sos_bottom_sheet.dart';

class MainWrapperScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const MainWrapperScreen({
    Key? key,
    required this.navigationShell,
  }) : super(key: key ?? const ValueKey<String>('MainWrapperScreen'));

  @override
  State<MainWrapperScreen> createState() => _MainWrapperScreenState();
}

class _MainWrapperScreenState extends State<MainWrapperScreen> {
  void _goBranch(int index) {
    if (index == 2) {
      // SOS Index
      showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        backgroundColor: Colors.transparent,
        builder: (context) => const SOSBottomSheet(),
      );
      return;
    }

    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: widget.navigationShell.currentIndex,
        destinations: [
          const NavigationDestination(
              label: 'Home',
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home)),
          const NavigationDestination(
              label: 'Search', icon: Icon(Icons.search)),
          NavigationDestination(
            label: '',
            icon: Transform.translate(
              offset: const Offset(0, 8),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: const BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red,
                      blurRadius: 6,
                      spreadRadius: 2,
                    )
                  ],
                ),
                child: const Icon(
                  Icons.sos,
                  color: Colors.white,
                  size: 40,
                ),
              ),
            ),
          ),
          const NavigationDestination(
              label: 'Notifications',
              icon: Icon(Icons.notifications_outlined),
              selectedIcon: Icon(Icons.notifications)),
          const NavigationDestination(
              label: 'History', icon: Icon(Icons.history)),
        ],
        onDestinationSelected: _goBranch,
      ),
    );
  }
}
