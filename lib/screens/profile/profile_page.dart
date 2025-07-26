// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/core/use_store.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/profile/store_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  dynamic _user = {};
  dynamic _package;

  Future<dynamic> getUser() async {
    dynamic data = await Store.getUser();
    dynamic package = await Store.getPackageSubscribe();

    print(package);
    setState(() {
      _user = data;
      _package = package;
    });
  }

  @override
  void initState() {
    getUser();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavDrawer(),
      appBar: AppBar(
        // title: const Text('Tambah produk'),
        backgroundColor: Colors.white,
        title: const Text(
          "Profile",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: const MenuBuilder(),
        centerTitle: true,
      ),
      body: ListView(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            color: Colors.white,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(
                  height: 70,
                  width: 70,
                  child: CircleAvatar(
                    backgroundColor: AppColor.primary,
                    child: Text(
                      'AH',
                      style: TextStyle(color: Colors.white, fontSize: 32),
                    ),
                  ),
                ),
                SizedBox(width: 20),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "${_user['name'] ?? '-'}",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text("${_user['email'] ?? '-'}"),
                  ],
                )
              ],
            ),
          ),
          _package != null
              ? Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  color: Colors.blue,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Paket anda saat ini",
                        style: TextStyle(fontSize: 10.sp, color: Colors.white),
                      ),
                      Text(
                        "${_package['name']}",
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              : SizedBox(),
          const SizedBox(height: 10),
          // InkWell(
          //   onTap: () {},
          //   child: Container(
          //     padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
          //     color: Colors.white,
          //     child: const Row(
          //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
          //         children: [
          //           Text(
          //             'Paket anda',
          //             style: TextStyle(fontSize: 16),
          //           ),
          //           Icon(Icons.chevron_right)
          //         ]),
          //   ),
          // ),
          // const SizedBox(height: 3),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfileStorePage()),
              );
            },
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 30, vertical: 30),
              color: Colors.white,
              child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Profil usaha',
                      style: TextStyle(fontSize: 16),
                    ),
                    Icon(Icons.chevron_right)
                  ]),
            ),
          ),
          const SizedBox(height: 3),

          const SizedBox(height: 10),
        ],
      ),
    );
  }
}
