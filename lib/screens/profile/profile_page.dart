// lib/screens/profile/profile_page.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/helpers/store.dart';
import 'package:kasir/screens/profile/business_profile_page.dart';
import 'package:kasir/screens/profile/payment_history_page.dart';
import 'package:kasir/screens/store/store_list_page.dart';
import 'package:kasir/screens/subscription/subscription_page.dart';
import 'package:kasir/services/user_services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:loader_overlay/loader_overlay.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  dynamic _user = {};
  Map<String, dynamic>? _currentStore;
  bool _isLoading = true;
  bool _isMember = false;
  UserServices userServices = UserServices();
  final ImagePicker _picker = ImagePicker(); // Inisialisasi ImagePicker

  @override
  void initState() {
    super.initState();
    getUserProfile();
    _getCurrentStore();
  }

  Future<void> getUserProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);
    try {
      final resp = await userServices.getProfile();
      if (mounted && resp['success'] == true) {
        setState(() {
          _user = resp['data'];
          _isMember = _user['role'] == 'MEMBER';
          _isLoading = false;
        });
      } else {
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _getCurrentStore() async {
    try {
      final currentStore = await Store.getStore();
      if (mounted) {
        setState(() {
          _currentStore = currentStore;
        });
      }
    } catch (e) {
      // Handle error
    }
  }

  // [FUNGSI BARU] Untuk memilih gambar dari galeri dan mengunggahnya
  Future<void> _pickAndUploadImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Kompres gambar agar tidak terlalu besar
      );

      if (image != null) {
        context.loaderOverlay.show();
        final resp = await userServices.updateProfile(avatarFile: image);
        context.loaderOverlay.hide();

        if (mounted && resp['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Foto profil berhasil diperbarui'),
              backgroundColor: Colors.green,
            ),
          );
          await getUserProfile(); // Muat ulang profil untuk menampilkan gambar baru
        } else {
           ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(resp['message'] ?? 'Gagal mengunggah foto'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        context.loaderOverlay.hide();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const NavDrawer(currentRoute: 'profile'),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          "Profil",
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        leading: const MenuBuilder(),
        centerTitle: true,
      ),
      body: LoaderOverlay(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : ListView(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    color: theme.colorScheme.surface,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // [PERBAIKAN UTAMA] Avatar dibungkus dengan InkWell agar bisa diklik
                        InkWell(
                          onTap: _pickAndUploadImage,
                          borderRadius: BorderRadius.circular(35),
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 35,
                                backgroundColor: AppColor.primary.withOpacity(0.1),
                                backgroundImage: _user['avatar'] != null
                                    ? CachedNetworkImageProvider(_user['avatar'])
                                    : null,
                                child: _user['avatar'] == null
                                    ? Text(
                                        _getInitials(_user['name'] ?? ''),
                                        style: const TextStyle(
                                            color: AppColor.primary, fontSize: 32),
                                      )
                                    : null,
                              ),
                              Container(
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  boxShadow: [ BoxShadow( color: Colors.black.withOpacity(0.1), blurRadius: 4) ],
                                ),
                                child: const Icon(CupertinoIcons.pencil, size: 14, color: AppColor.primary),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "${_user['name'] ?? 'User'}",
                                style: theme.textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "${_user['email'] ?? ''}",
                                style: theme.textTheme.bodyMedium,
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),

                  const SizedBox(height: 10),

                  // Menu Profil Usaha
                  _currentStore != null && _currentStore!['id'] != null
                      ? _buildMenuItem(
                          context: context,
                          icon: CupertinoIcons.house_fill,
                          title: 'Profil usaha: ${_currentStore!['name'] ?? 'Toko saya'}',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => BusinessProfilePage(storeId: _currentStore!['id']),
                            ),
                          ),
                        )
                      : _buildMenuItem(
                          context: context,
                          icon: CupertinoIcons.house_fill,
                          title: 'Daftar Toko',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const StoreListPage()),
                          ).then((_) => _getCurrentStore()),
                        ),

                  const SizedBox(height: 3),

                  _buildMenuItem(
                    context: context,
                    icon: CupertinoIcons.creditcard,
                    title: 'Langganan',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SubscriptionPage()),
                    ),
                  ),

                  const SizedBox(height: 3),

                  _buildMenuItem(
                    context: context,
                    icon: CupertinoIcons.time,
                    title: 'Riwayat Pembayaran',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const PaymentHistoryPage()),
                    ),
                  ),

                  // [PENGHAPUSAN] Menu Undang Anggota telah dihapus dari sini.
                ],
              ),
      ),
    );
  }

  Widget _buildMenuItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    // ... (Fungsi ini tidak berubah, tapi warna sudah diperbaiki)
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.only(bottom: 3),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          color: theme.colorScheme.surface,
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColor.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: AppColor.primary, size: 24),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w500),
                ),
              ),
              Icon(CupertinoIcons.chevron_right, color: theme.colorScheme.onSurfaceVariant, size: 18),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    final nameParts = name.trim().split(' ');
    if (nameParts.length > 1 && nameParts.last.isNotEmpty) {
      return '${nameParts.first[0].toUpperCase()}${nameParts.last[0].toUpperCase()}';
    } else {
      return nameParts.first.isNotEmpty ? nameParts.first[0].toUpperCase() : 'U';
    }
  }
}