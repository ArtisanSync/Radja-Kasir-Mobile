// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/screens/login_page.dart';
import 'package:kasir/services/auth_services.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final api = AuthServices();
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final TextEditingController _businessTypeController = TextEditingController();
  final TextEditingController _businessAddressController = TextEditingController();
  final TextEditingController _whatsappController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  Map<String, dynamic>? userProfile;
  bool isLoading = true;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    loadProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _businessNameController.dispose();
    _businessTypeController.dispose();
    _businessAddressController.dispose();
    _whatsappController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> loadProfile() async {
    setState(() {
      isLoading = true;
    });

    final resp = await api.getProfile(context);

    if (resp['success'] == true) {
      setState(() {
        userProfile = resp['data'];
        _nameController.text = userProfile!['name'] ?? '';
        _phoneController.text = userProfile!['phone'] ?? '';
        _businessNameController.text = userProfile!['businessName'] ?? '';
        _businessTypeController.text = userProfile!['businessType'] ?? '';
        _businessAddressController.text = userProfile!['businessAddress'] ?? '';
        _whatsappController.text = userProfile!['whatsapp'] ?? '';
        isLoading = false;
      });
    } else {
      setState(() {
        isLoading = false;
      });

      _showSnackBar(
        message: resp['message'] ?? 'Gagal memuat profil',
        isError: true,
      );
    }
  }

  Future<void> updateProfile() async {
    Map<String, dynamic> updateData = {
      "name": _nameController.text.trim(),
      "phone": _phoneController.text.trim(),
      "businessName": _businessNameController.text.trim(),
      "businessType": _businessTypeController.text.trim(),
      "businessAddress": _businessAddressController.text.trim(),
      "whatsapp": _whatsappController.text.trim(),
    };

    // Only include password if it's provided
    if (_passwordController.text.isNotEmpty) {
      if (_passwordController.text != _confirmPasswordController.text) {
        _showSnackBar(
          message: 'Password konfirmasi tidak cocok',
          isError: true,
        );
        return;
      }
      updateData["password"] = _passwordController.text;
    }

    final resp = await api.updateProfile(updateData, context);

    if (resp['success'] == true) {
      _showSnackBar(
        message: resp['message'] ?? 'Profil berhasil diperbarui!',
        isError: false,
      );

      setState(() {
        userProfile = resp['data'];
        _passwordController.clear();
        _confirmPasswordController.clear();
      });
    } else {
      _showSnackBar(
        message: resp['message'] ?? 'Gagal memperbarui profil',
        isError: true,
      );
    }
  }

  Future<void> logout() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        final theme = Theme.of(context);
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(
                CupertinoIcons.question_circle,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 12),
              const Text('Konfirmasi Logout'),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin logout?'),
          actions: [
            TextButton(
              child: const Text('Batal'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
                foregroundColor: theme.colorScheme.onError,
              ),
              child: const Text('Logout'),
              onPressed: () async {
                Navigator.of(context).pop();
                await api.logout();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                  (route) => false,
                );
              },
            ),
          ],
        );
      },
    );
  }

  void _showSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Theme.of(context).colorScheme.error : Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const NavDrawer(currentRoute: 'profile'),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: const MenuBuilder(),
        title: Text(
          'Profil',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(
              CupertinoIcons.square_arrow_right,
              color: theme.colorScheme.error,
            ),
            onPressed: logout,
            tooltip: 'Logout',
          ),
        ],
      ),
      body: LoaderOverlay(
        overlayOpacity: 0.2,
        overlayColor: Colors.black12,
        useDefaultLoading: false,
        overlayWidget: Center(
          child: SpinKitDoubleBounce(
            color: theme.colorScheme.primary,
            size: 50.0,
          ),
        ),
        child: isLoading
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Memuat profil...',
                      style: theme.textTheme.bodyLarge?.copyWith(
                        color: theme.colorScheme.onBackground.withOpacity(0.7),
                      ),
                    ),
                  ],
                ),
              )
            : RefreshIndicator(
                onRefresh: loadProfile,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Header Card
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              children: [
                                // Avatar
                                CircleAvatar(
                                  radius: 50,
                                  backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
                                  backgroundImage: userProfile?['avatar'] != null
                                      ? CachedNetworkImageProvider(userProfile!['avatar'])
                                      : null,
                                  child: userProfile?['avatar'] == null
                                      ? Icon(
                                          CupertinoIcons.person_fill,
                                          size: 50,
                                          color: theme.colorScheme.primary,
                                        )
                                      : null,
                                ),
                                const SizedBox(height: 16),

                                // User Info
                                Text(
                                  userProfile?['name'] ?? 'User',
                                  style: theme.textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: theme.colorScheme.onSurface,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  userProfile?['email'] ?? '',
                                  style: theme.textTheme.bodyLarge?.copyWith(
                                    color: theme.colorScheme.onSurface.withOpacity(0.7),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                
                                // Status Badges
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    _buildStatusBadge(
                                      userProfile?['role'] ?? 'USER',
                                      theme.colorScheme.primary,
                                      theme,
                                    ),
                                    if (userProfile?['emailVerifiedAt'] != null)
                                      _buildStatusBadge(
                                        'Email Terverifikasi',
                                        Colors.green,
                                        theme,
                                      ),
                                    if (userProfile?['isSubscribed'] == true)
                                      _buildStatusBadge(
                                        'Berlangganan',
                                        Colors.purple,
                                        theme,
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Update Profile Form
                        Card(
                          elevation: 2,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      CupertinoIcons.person_circle,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      'Update Profil',
                                      style: theme.textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                        color: theme.colorScheme.onSurface,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),

                                // Personal Info Section
                                _buildSectionTitle('Informasi Personal', theme),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _nameController,
                                  decoration: InputDecoration(
                                    labelText: "Nama Lengkap",
                                    prefixIcon: const Icon(CupertinoIcons.person),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _phoneController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "Nomor Telepon",
                                    prefixIcon: const Icon(CupertinoIcons.phone),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _whatsappController,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: "WhatsApp",
                                    prefixIcon: const Icon(CupertinoIcons.chat_bubble),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Business Info Section
                                _buildSectionTitle('Informasi Bisnis', theme),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _businessNameController,
                                  decoration: InputDecoration(
                                    labelText: "Nama Bisnis",
                                    prefixIcon: const Icon(CupertinoIcons.building_2_fill),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _businessTypeController,
                                  decoration: InputDecoration(
                                    labelText: "Jenis Bisnis",
                                    prefixIcon: const Icon(CupertinoIcons.briefcase),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _businessAddressController,
                                  maxLines: 3,
                                  decoration: InputDecoration(
                                    labelText: "Alamat Bisnis",
                                    prefixIcon: const Icon(CupertinoIcons.location),
                                    alignLabelWithHint: true,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 24),

                                // Password Section
                                _buildSectionTitle('Ubah Password (Opsional)', theme),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  decoration: InputDecoration(
                                    labelText: "Password Baru",
                                    prefixIcon: const Icon(CupertinoIcons.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword 
                                          ? CupertinoIcons.eye_slash 
                                          : CupertinoIcons.eye,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    helperText: "Kosongkan jika tidak ingin mengubah password",
                                  ),
                                ),
                                const SizedBox(height: 16),
                                
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  decoration: InputDecoration(
                                    labelText: "Konfirmasi Password Baru",
                                    prefixIcon: const Icon(CupertinoIcons.lock_fill),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword 
                                          ? CupertinoIcons.eye_slash 
                                          : CupertinoIcons.eye,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                // Update Button
                                SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton(
                                    onPressed: updateProfile,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: theme.colorScheme.primary,
                                      foregroundColor: theme.colorScheme.onPrimary,
                                      padding: const EdgeInsets.symmetric(vertical: 16),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(CupertinoIcons.checkmark_circle),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Update Profil',
                                          style: theme.textTheme.titleMedium?.copyWith(
                                            color: theme.colorScheme.onPrimary,
                                            fontWeight: FontWeight.w600,
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

                        const SizedBox(height: 40),
                      ],
                    ),
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildStatusBadge(String text, Color color, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: theme.textTheme.labelSmall?.copyWith(
          color: color,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, ThemeData theme) {
    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.bold,
        color: theme.colorScheme.onSurface,
      ),
    );
  }
}