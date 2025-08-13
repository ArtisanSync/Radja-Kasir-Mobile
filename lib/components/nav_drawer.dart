// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/customer/customer.dart';
import 'package:kasir/screens/home_page.dart';
import 'package:kasir/screens/product/product.dart';
import 'package:kasir/screens/profile/profile_page.dart';
import 'package:kasir/screens/setting/setting_page.dart';
import 'package:kasir/screens/transaction_dept/dept_page.dart';
import 'package:kasir/screens/report/report_page.dart'; // Import halaman laporan native
import 'package:kasir/screens/debug_screen.dart';
import 'package:kasir/services/service_utils.dart';
import 'package:url_launcher/url_launcher.dart';

class NavDrawer extends StatefulWidget {
  const NavDrawer({super.key});

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
    return Drawer(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.white,
      child: ListView(
        children: [
          const SizedBox(height: 20),
          DrawerHeader(
            name: _userName,
            store: _storeName,
          ),
          const SizedBox(height: 20),
          
          // Transaksi
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Transaksi'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          
          // Produk dan Stok
          ListTile(
            leading: const Icon(Icons.inventory_2),
            title: const Text('Produk dan Stok'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProductPage()),
              );
            },
          ),
          
          // Kasbon
          ListTile(
            leading: const Icon(Icons.monetization_on_rounded),
            title: const Text('Kasbon'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DeptPage()),
              );
            },
          ),
          
          // Laporan - Updated to use native page
          ListTile(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ReportPage()),
              );
            },
            leading: const Icon(Icons.equalizer),
            title: const Text('Laporan'),
          ),
          
          // Alternative: Keep web version with better error handling
          // ListTile(
          //   onTap: () async {
          //     try {
          //       final store = await Store.getStore();
          //       
          //       if (store?['id'] == null) {
          //         ScaffoldMessenger.of(context).showSnackBar(
          //           const SnackBar(
          //             content: Text('Store information not found. Please login again.'),
          //             backgroundColor: Colors.red,
          //           ),
          //         );
          //         return;
          //       }
          //       
          //       final baseUrl = ServiceUtils().webUrl;
          //       final url = Uri.parse("$baseUrl/report?store=${store['id']}");
          //       
          //       if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
          //         throw Exception('Could not launch $url');
          //       }
          //     } catch (e) {
          //       ScaffoldMessenger.of(context).showSnackBar(
          //         SnackBar(
          //           content: Text('Failed to open report: $e'),
          //           backgroundColor: Colors.red,
          //         ),
          //       );
          //     }
          //   },
          //   leading: const Icon(Icons.web),
          //   title: const Text('Laporan Web'),
          // ),
          
          // Profil
          ListTile(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            leading: const Icon(Icons.account_circle),
            title: const Text('Profil'),
          ),
          
          // Pelanggan
          ListTile(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CustomerPage()),
              );
            },
            leading: const Icon(Icons.people),
            title: const Text('Pelanggan'),
          ),
          
          // Pengaturan
          ListTile(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
            leading: const Icon(Icons.settings),
            title: const Text('Pengaturan'),
          ),
          
          // Optional: Debug Screen (remove in production)
          // ListTile(
          //   onTap: () {
          //     Navigator.pushReplacement(
          //       context,
          //       MaterialPageRoute(builder: (context) => const DebugScreen()),
          //     );
          //   },
          //   leading: const Icon(Icons.bug_report),
          //   title: const Text('Debug'),
          // ),
        ],
      ),
    );
  }
}

class DrawerHeader extends StatelessWidget {
  const DrawerHeader({
    super.key, 
    this.name, 
    this.store,
  });

  final String? name;
  final String? store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColor.primary,
            child: Text(
              _getInitials(name ?? 'User'),
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name ?? "-",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  store ?? "-",
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
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