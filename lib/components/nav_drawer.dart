import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/screens/admin/admin_dashboard_page.dart';
import 'package:kasir/screens/admin/admin_subscribers_page.dart'; // Import halaman subscribers
import 'package:kasir/screens/history_page.dart';
import 'package:kasir/screens/home_page.dart';
import 'package:kasir/screens/product/product.dart';
import 'package:kasir/screens/profile/profile_page.dart';
import 'package:kasir/screens/transaction_dept/dept_page.dart';
import 'package:kasir/screens/report/report_page.dart';
import 'package:kasir/screens/login_page.dart';

class NavDrawer extends StatefulWidget {
  final String? currentRoute;
  
  const NavDrawer({super.key, this.currentRoute});

  @override
  State<NavDrawer> createState() => _NavDrawerState();
}

class _NavDrawerState extends State<NavDrawer> {
  String _userName = 'Loading...';
  String _storeName = 'Loading...';
  String _userRole = 'USER';
  bool _isAdmin = false;

  Future setUser() async {
    try {
      final user = await Store.getUser();
      final store = await Store.getStore();

      if (mounted) {
        setState(() {
          _userName = user?['name'] ?? 'User';
          _storeName = store?['name'] ?? 'Store';
          _userRole = user?['role'] ?? 'USER';
          _isAdmin = _userRole == 'ADMIN';
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _userName = 'User';
          _storeName = 'Store';
          _userRole = 'USER';
          _isAdmin = false;
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
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 60, 24, 24),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: _isAdmin 
                  ? [Colors.red.shade600, Colors.red.shade400]
                  : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)],
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
                        color: _isAdmin ? Colors.red.shade600 : theme.colorScheme.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
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
                const SizedBox(width: 4),
                Text(
                  _isAdmin ? 'Administrator' : _storeName,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (_isAdmin) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      'ADMIN',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Menu Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 8),
              children: _isAdmin ? _buildAdminMenuItems() : _buildUserMenuItems(),
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

  List<Widget> _buildAdminMenuItems() {
    return [
      _buildMenuItem(
        context,
        icon: CupertinoIcons.chart_bar_fill,
        title: 'Dashboard Admin',
        route: 'admin_dashboard',
        onTap: () => _navigateToPage(context, const AdminDashboardPage()),
      ),
      _buildMenuItem(
        context,
        icon: CupertinoIcons.person_3_fill,
        title: 'Kelola Pengguna',
        route: 'admin_subscribers',
        onTap: () => _navigateToPage(context, const AdminSubscribersPage()),
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
        icon: CupertinoIcons.square_arrow_right,
        title: 'Logout',
        route: 'logout',
        onTap: () => _handleLogout(context),
        isDestructive: true,
      ),
    ];
  }

  List<Widget> _buildUserMenuItems() {
    return [
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
        icon: CupertinoIcons.square_arrow_right,
        title: 'Logout',
        route: 'logout',
        onTap: () => _handleLogout(context),
        isDestructive: true,
      ),
    ];
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String route,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final theme = Theme.of(context);
    final isActive = widget.currentRoute == route;
    final isAdmin = _userRole == 'ADMIN';
    
    Color primaryColor = isDestructive 
        ? Colors.red.shade600 
        : (isAdmin ? Colors.red.shade600 : theme.colorScheme.primary);
    
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
              color: isActive 
                ? primaryColor.withOpacity(0.1)
                : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isActive
                      ? primaryColor.withOpacity(0.2)
                      : primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                      color: isActive 
                        ? primaryColor
                        : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: primaryColor.withOpacity(0.7),
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

  Future<void> _handleLogout(BuildContext context) async {
    Navigator.pop(context); // Close drawer first
    
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _performLogout(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _performLogout(BuildContext context) async {
    try {
      // Clear all stored data
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      
      // Navigate to login page
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          PageRouteBuilder(
            pageBuilder: (context, animation, secondaryAnimation) => const LoginPage(),
            transitionsBuilder: (context, animation, secondaryAnimation, child) {
              return FadeTransition(
                opacity: animation,
                child: child,
              );
            },
            transitionDuration: const Duration(milliseconds: 300),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      print('Error during logout: $e');
      // Still navigate to login even if clearing fails
      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
        );
      }
    }
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
