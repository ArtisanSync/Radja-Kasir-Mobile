import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/providers/store_providers.dart';
import 'package:loader_overlay/loader_overlay.dart';

class BusinessProfilePage extends ConsumerStatefulWidget {
  final String storeId;

  const BusinessProfilePage({Key? key, required this.storeId}) : super(key: key);

  @override
  ConsumerState<BusinessProfilePage> createState() =>
      _BusinessProfilePageState();
}

class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  XFile? _logoImageFile;
  String? _currentLogoUrl;
  final ImagePicker _picker = ImagePicker();

  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _loadStoreProfile());
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _whatsappController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _loadStoreProfile() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      await ref.read(storeProvider.notifier).loadStoreDetail(widget.storeId);
      final storeState = ref.read(storeProvider);

      if (!mounted) return;

      if (storeState.currentStore != null) {
        final store = storeState.currentStore!;
        setState(() {
          _nameController.text = store.name;
          _descriptionController.text = store.description;
          _addressController.text = store.address;
          _phoneController.text = store.phone ?? '';
          _whatsappController.text = store.whatsapp ?? '';
          _emailController.text = store.email ?? '';
          _currentLogoUrl = store.logo;
        });
      } else if (storeState.error != null) {
        _showSnackBar(storeState.error!, isError: true);
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar('Terjadi kesalahan: ${e.toString()}', isError: true);
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _pickImage() async {
    final XFile? pickedFile =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _logoImageFile = pickedFile;
      });
    }
  }

  Future<void> _saveStoreProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    context.loaderOverlay.show();

    try {
      final updateData = {
        "name": _nameController.text,
        "description": _descriptionController.text,
        "address": _addressController.text,
        "phone": _phoneController.text,
        "whatsapp": _whatsappController.text,
        "email": _emailController.text,
      };
      final response = await ref
          .read(storeProvider.notifier)
          .updateStore(widget.storeId, updateData, _logoImageFile);

      if (!mounted) return;

      if (response['success'] == true) {
        _showSnackBar('Profil usaha berhasil diperbarui', isError: false);
        Navigator.pop(context, true); 
      } else {
        _showSnackBar(response['message'] ?? 'Gagal memperbarui profil usaha', isError: true);
      }
    } catch (e) {
      _showSnackBar('Terjadi kesalahan: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
        context.loaderOverlay.hide();
      }
    }
  }
  
  void _showSnackBar(String message, {required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(message),
      backgroundColor: isError ? Colors.red : Colors.green,
    ));
  }
  
  Widget _buildImagePreview(ThemeData theme) {
    if (_logoImageFile != null) {
      if (kIsWeb) {
        return Image.network(_logoImageFile!.path, fit: BoxFit.cover);
      } else {
        return Image.file(File(_logoImageFile!.path), fit: BoxFit.cover);
      }
    }

    if (_currentLogoUrl != null && _currentLogoUrl!.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: _currentLogoUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => const Center(child: CupertinoActivityIndicator()),
        errorWidget: (context, url, error) => _buildImagePlaceholder(theme),
      );
    }

    return _buildImagePlaceholder(theme);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Usaha'),
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Logo Toko', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                          const SizedBox(height: 16),
                          GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              width: double.infinity,
                              height: 150,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.3)),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: _buildImagePreview(theme),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Informasi Bisnis',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Nama Usaha',
                            controller: _nameController,
                            validator: (value) => (value == null || value.isEmpty) ? 'Nama usaha tidak boleh kosong' : null,
                            prefixIcon: const Icon(Icons.business),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Deskripsi',
                            controller: _descriptionController,
                            validator: (value) => (value == null || value.isEmpty) ? 'Deskripsi tidak boleh kosong' : null,
                            maxLines: 2,
                            prefixIcon: const Icon(Icons.description),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Alamat',
                            controller: _addressController,
                            validator: (value) => (value == null || value.isEmpty) ? 'Alamat tidak boleh kosong' : null,
                            maxLines: 3,
                            prefixIcon: const Icon(Icons.location_on),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    ModernCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                           Text(
                            'Kontak (Opsional)',
                            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Telepon',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.phone),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'WhatsApp',
                            controller: _whatsappController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(Icons.chat),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Email',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            prefixIcon: const Icon(Icons.email),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ModernButton(
                      text: 'Simpan Perubahan',
                      onPressed: _saveStoreProfile,
                      isLoading: _isSaving,
                      icon: const Icon(Icons.check_circle),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.photo_on_rectangle, size: 40, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(height: 8),
          Text('Ganti Logo', style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}