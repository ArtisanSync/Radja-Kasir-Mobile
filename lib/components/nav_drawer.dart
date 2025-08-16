// ignore_for_file: prefer_const_constructors

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/screens/history_page.dart';
import 'package:kasir/screens/home_page.dart';
import 'package:kasir/screens/product/product.dart';
import 'package:kasir/screens/profile/profile_page.dart';
import 'package:kasir/screens/setting/setting_page.dart';
import 'package:kasir/screens/transaction_dept/dept_page.dart';
import 'package:kasir/screens/report/report_page.dart';
import 'package:gap/gap.dart';

class NavDrawer extends StatefulWidget {
  final String? currentRoute; // Tambahkan parameter untuk route aktif
  
  const NavDrawer({super.key, this.currentRoute});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String _userName = 'Loading...';
  String _storeName = 'Loading...';

  Future setUser() async {
    try {
      final user = await Store.getUser();
      final store = await Store.getStore();

      if (mounted) {
        setState(() {
          _userName = user?['name'] ?? 'User';
          _storeName = store?['name'] ?? 'Store';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'User';
          _storeName = 'Store';
        });
      }
    }
  }

  @override
  void initState() {
    setUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Drawer(
      backgroundColor: theme.colorScheme.surface,
      child: Column(
        children: [
          // Modern Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  theme.colorScheme.primary,
                  theme.colorScheme.primary.withOpacity(0.8),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Center(
                    child: Text(
                      _getInitials(_userName),
                      style: TextStyle(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const Gap(16),
                Text(
                  _userName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const Gap(4),
                Text(
                  _storeName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: [
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.house_fill,
                  title: 'Transaksi',
                  route: 'home',
                  onTap: () => _navigateToPage(context, const MyHomePage()),
                ),
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.cube_box_fill,
                  title: 'Produk dan Stok',
                  route: 'product',
                  onTap: () => _navigateToPage(context, const ProductPage()),
                ),
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.money_dollar_circle_fill,
                  title: 'Kasbon',
                  route: 'dept',
                  onTap: () => _navigateToPage(context, const DeptPage()),
                ),
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.chart_bar_fill,
                  title: 'Laporan',
                  route: 'report',
                  onTap: () => _navigateToPage(context, const ReportPage()),
                ),
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.time_solid,
                  title: 'History',
                  route: 'history',
                  onTap: () => _navigateToPage(context, const HistoryPage()),
                ),
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.person_circle_fill,
                  title: 'Profil',
                  route: 'profile',
                  onTap: () => _navigateToPage(context, const ProfilePage()),
                ),
                
                const Divider(height: 32),
                
                _buildMenuItem(
                  context,
                  icon: CupertinoIcons.settings_solid,
                  title: 'Pengaturan',
                  route: 'setting',
                  onTap: () => _navigateToPage(context, const SettingPage()),
                ),
              ],
            ),
          ),

          // App Version
          Container(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Radja Kasir v1.0.0',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final isActive = widget.currentRoute == route; // Cek apakah menu ini aktif
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              // Tambahkan background untuk item aktif
              color: isActive 
                ? theme.colorScheme.primaryContainer.withOpacity(0.3)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    // Ubah warna berdasarkan status aktif
                    color: isActive
                      ? theme.colorScheme.primary.withOpacity(0.2)
                      : theme.colorScheme.primaryContainer.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: isActive 
                      ? theme.colorScheme.primary 
                      : theme.colorScheme.primary,
                    size: 22,
                  ),
                ),
                const Gap(16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive 
                        ? theme.colorScheme.primary 
                        : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: isActive 
                    ? theme.colorScheme.primary 
                    : theme.colorScheme.onSurfaceVariant,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _navigateToPage(BuildContext context, Widget page) {
    Navigator.pop(context);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => page),
      (route) => false,
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty || name == 'Loading...' || name == 'User') return 'U';
    
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0].toUpperCase()}${words.last[0].toUpperCase()}';
    } else {
      return words.first.length >= 2 
          ? words.first.substring(0, 2).toUpperCase()
          : words.first[0].toUpperCase();
    }
  }
}