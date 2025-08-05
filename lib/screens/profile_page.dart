// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/login_page.dart';
import 'package:kasir/services/auth_services.dart';
import 'package:kasir/core/use_store.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final api = AuthServices();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();

  Map<String, dynamic>? userProfile;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  Future<void> loadProfile() async {
    final resp = await api.getProfile(context);

    if (resp['success'] == true) {
      setState(() {
        userProfile = resp['data'];
        _nameController.text = userProfile!['name'] ?? '';
        _emailController.text = userProfile!['email'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['message'] ?? 'Gagal memuat profil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> updateProfile() async {
    Map<String, dynamic> updateData = {
      "name": _nameController.text.trim(),
    };

    // Only include password if it's provided
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password konfirmasi tidak cocok'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      if (_passwordController.text.length < 8) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Password minimal 8 karakter'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      updateData["password"] = _passwordController.text;
    }

    final resp = await api.updateProfile(updateData, context);

    if (resp['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['message'] ?? 'Profil berhasil diperbarui!'),
          backgroundColor: Colors.green,
        ),
      );

      setState(() {
        userProfile = resp['data'];
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(resp['message'] ?? 'Gagal memperbarui profil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Konfirmasi Logout'),
          content: Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              child: Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                await api.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Profil'),
        backgroundColor: AppColor.primary,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: logout,
          ),
        ],
      ),
      body: LoaderOverlay(
        overlayOpacity: 0.2,
        overlayColor: Colors.black12,
        useDefaultLoading: false,
        overlayWidget: Center(
          child: SpinKitDoubleBounce(
            color: Colors.black,
            size: 50.0,
          ),
        ),
        child: isLoading
            ? Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // User Info Card
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informasi Akun',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),

                            // Avatar placeholder
                            Center(
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: AppColor.primary,
                                backgroundImage: userProfile?['avatar'] != null
                                    ? NetworkImage(userProfile!['avatar'])
                                    : null,
                                child: userProfile?['avatar'] == null
                                    ? Icon(Icons.person,
                                        size: 50, color: Colors.white)
                                    : null,
                              ),
                            ),
                            SizedBox(height: 16),

                            // User details
                            _buildInfoRow('Email', userProfile?['email'] ?? ''),
                            _buildInfoRow('Role', userProfile?['role'] ?? ''),
                            _buildInfoRow(
                                'Member',
                                userProfile?['isMember'] == true
                                    ? 'Ya'
                                    : 'Tidak'),
                            _buildInfoRow(
                                'Subscribe',
                                userProfile?['isSubscribe'] == true
                                    ? 'Aktif'
                                    : 'Tidak Aktif'),
                            _buildInfoRow(
                                'Email Verified',
                                userProfile?['emailVerifiedAt'] != null
                                    ? 'Ya'
                                    : 'Belum'),
                            _buildInfoRow(
                                'Bergabung',
                                userProfile?['createdAt'] != null
                                    ? DateTime.parse(userProfile!['createdAt'])
                                        .toString()
                                        .substring(0, 10)
                                    : ''),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // Update Profile Form
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Update Profil',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 16),

                            // Name Input
                            TextField(
                              controller: _nameController,
                              decoration: InputDecoration(
                                labelText: "Nama",
                                labelStyle:
                                    TextStyle(color: AppColor.secondary),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColor.light),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColor.primary),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Email Input (read-only)
                            TextField(
                              controller: _emailController,
                              enabled: false,
                              decoration: InputDecoration(
                                labelText: "Email (tidak dapat diubah)",
                                labelStyle:
                                    TextStyle(color: AppColor.secondary),
                                filled: true,
                                fillColor: Colors.grey[100],
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColor.light),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColor.primary),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Password Input
                            TextField(
                              controller: _passwordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Password Baru (opsional)",
                                labelStyle:
                                    TextStyle(color: AppColor.secondary),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColor.light),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColor.primary),
                                ),
                              ),
                            ),
                            SizedBox(height: 16),

                            // Confirm Password Input
                            TextField(
                              controller: _confirmPasswordController,
                              obscureText: true,
                              decoration: InputDecoration(
                                labelText: "Konfirmasi Password",
                                labelStyle:
                                    TextStyle(color: AppColor.secondary),
                                filled: true,
                                fillColor: Colors.white,
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide: BorderSide(color: AppColor.light),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10),
                                  borderSide:
                                      BorderSide(color: AppColor.primary),
                                ),
                              ),
                            ),
                            SizedBox(height: 20),

                            // Update Button
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                onPressed: updateProfile,
                                style: ElevatedButton.styleFrom(
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  elevation: 0,
                                  backgroundColor: AppColor.primary,
                                  padding: EdgeInsets.symmetric(vertical: 15),
                                ),
                                child: Text(
                                  'Update Profil',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
