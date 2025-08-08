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
          ListTile(
            leading: Icon(Icons.home),
            title: Text('Transaksi'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const MyHomePage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.inventory_2),
            title: Text('Produk dan Stok'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProductPage()),
              );
            },
          ),
          ListTile(
            leading: Icon(Icons.monetization_on_rounded),
            title: Text('Kasbon'),
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const DeptPage()),
              );
            },
          ),
          ListTile(
            onTap: () async {
              final store = await Store.getStore();
              final baseUrl = ServiceUtils().webUrl;

              var url = Uri.parse("$baseUrl/report?store=${store['id']}");
              if (!await launchUrl(url)) {
                throw Exception('Could not launch $url');
              }
              // Navigator.pushReplacement(
              //   context,
              //   // MaterialPageRoute(builder: (context) => const ReportPage()),
              //   MaterialPageRoute(
              //       builder: (context) => ReportWebview(
              //             store: store['id'],
              //           )),
              // );
            },
            leading: Icon(Icons.equalizer),
            title: Text('Laporan'),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const ProfilePage()),
              );
            },
            leading: Icon(Icons.account_circle),
            title: Text('Profil'),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const CustomerPage()),
              );
            },
            leading: Icon(Icons.people),
            title: Text('Pelanggan'),
          ),
          ListTile(
            onTap: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const SettingPage()),
              );
            },
            leading: Icon(Icons.settings),
            title: Text('Pengaturan'),
          )
        ],
      ),
    );
  }
}

class DrawerHeader extends StatelessWidget {
  const DrawerHeader({super.key, this.name, this.store});

  final String? name;
  final String? store;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColor.primary,
            child: Text(
              'RK',
              style: TextStyle(color: Colors.white),
            ),
          ),
          SizedBox(width: 10),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name ?? "-",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                store ?? "-",
                style: TextStyle(fontSize: 10),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
