// ignore_for_file: use_build_context_synchronously, prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/login_page.dart';
import 'package:kasir/screens/setting/setting_print.dart';
import 'package:kasir/screens/setting_member/member_page.dart';
import 'package:kasir/screens/setting_store/store_setting.dart';

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});

  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  bool isMember = false;

  Future<void> getUserStore() async {
    var store = await Store.getUser();
    setState(() {
      isMember = store['is_member'];
    });
  }

  @override
  void initState() {
    getUserStore();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Pengaturan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: MenuBuilder(),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          const SizedBox(height: 13),
          InkWell(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PrintSettingScreen(),
                  ));
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              color: Colors.white,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Printer',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(
                      Icons.print,
                      color: AppColor.textPrimary,
                    )
                  ]),
            ),
          ),
          const SizedBox(height: 3),
          !isMember
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const MemberPage(),
                        ));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                    color: Colors.white,
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Member',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(
                            Icons.supervised_user_circle_outlined,
                            color: AppColor.textPrimary,
                          )
                        ]),
                  ),
                )
              : SizedBox(),
          const SizedBox(height: 3),
          !isMember
              ? InkWell(
                  onTap: () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const StoreSetting(),
                        ));
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
                    color: Colors.white,
                    child: const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Pengaturan Toko',
                            style: TextStyle(fontSize: 16),
                          ),
                          Icon(
                            Icons.manage_accounts,
                            color: AppColor.textPrimary,
                          )
                        ]),
                  ),
                )
              : SizedBox(),
          const SizedBox(height: 3),
          InkWell(
            onTap: () async {
              await Store.clear();
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LoginPage(),
                ),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              color: Colors.white,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.logout)
                  ]),
            ),
          )
        ],
      ),
    );
  }
}
