import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:kasir/screens/home_page.dart';
import 'package:kasir/screens/product/product.dart';
import 'package:kasir/screens/report/report_page.dart';
import 'package:kasir/screens/profile/profile_page.dart';

final navigationIndexProvider = StateProvider<int>((ref) => 0);

class MainNavigation extends ConsumerWidget {
  const MainNavigation({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);
    final theme = Theme.of(context);

    final List<Widget> pages = [
      const MyHomePage(),
      const ProductPage(),
      const ReportPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: currentIndex,
        children: pages,
      ),
      bottomNavigationBar: CurvedNavigationBar(
        index: currentIndex,
        height: 60,
        color: theme.colorScheme.primary,
        backgroundColor: theme.colorScheme.background,
        buttonBackgroundColor: theme.colorScheme.primary,
        animationCurve: Curves.easeInOut,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
        items: [
          Icon(
            Icons.home_rounded,
            size: 28,
            color: theme.colorScheme.onPrimary,
          ),
          Icon(
            Icons.inventory_2_rounded,
            size: 28,
            color: theme.colorScheme.onPrimary,
          ),
          Icon(
            Icons.people_rounded,
            size: 28,
            color: theme.colorScheme.onPrimary,
          ),
          Icon(
            Icons.bar_chart_rounded,
            size: 28,
            color: theme.colorScheme.onPrimary,
          ),
          Icon(
            Icons.person_rounded,
            size: 28,
            color: theme.colorScheme.onPrimary,
          ),
        ],
      ),
    );
  }
}