import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/providers/store_providers.dart';
import 'package:kasir/screens/subscription/subscription_page.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AddStorePage extends ConsumerStatefulWidget {
  final bool isFirstStore;
  const AddStorePage({
    Key? key,
    this.isFirstStore = false,
  }) : super(key: key);

  @override
  ConsumerState<AddStorePage> createState() => _AddStorePageState();
}

class _AddStorePageState extends ConsumerState<AddStorePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();

  XFile? _logoImageFile;
  final ImagePicker _picker = ImagePicker();

  String _storeType = 'RETAIL';
  bool _isSaving = false;
  final List<Map<String, String>> _storeTypes = [
    {'value': 'RETAIL', 'label': 'Retail'},
    {'value': 'FOOD', 'label': 'Makanan & Minuman'},
    {'value': 'CLOTHES', 'label': 'Pakaian'},
    {'value': 'SERVICE', 'label': 'Elektronik'},
    {'value': 'OTHER', 'label': 'Lainnya'},
  ];

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

  Future<void> _pickImage() async {
    final XFile? pickedFile = await _picker.pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (pickedFile != null) {
      setState(() {
        _logoImageFile = pickedFile;
      });
    }
  }

  Future<void> _saveStore() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    context.loaderOverlay.show();

    try {
      final storeData = {
        "name": _nameController.text,
        "description": _descriptionController.text,
        "storeType": _storeType,
        "address": _addressController.text,
        "phone": _phoneController.text,
        "whatsapp": _whatsappController.text,
        "email": _emailController.text
      };
      final result = widget.isFirstStore
          ? await ref.read(storeProvider.notifier).createFirstStore(storeData, _logoImageFile)
          : await ref.read(storeProvider.notifier).createStore(storeData, _logoImageFile);

      if (!mounted) return;

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Toko berhasil dibuat'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else {
        if (result['data'] != null && result['data']['subscriptionRequired'] == true) {
          _showSubscriptionRequiredDialog(result['message'] ??
              'Anda memerlukan langganan untuk membuat toko');
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              content: Text(result['message'] ?? 'Gagal membuat toko'),
              backgroundColor: Colors.red));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red));
    } finally {
      if(mounted) {
        setState(() => _isSaving = false);
        context.loaderOverlay.hide();
      }
    }
  }

  void _showSubscriptionRequiredDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Langganan Diperlukan'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kembali'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SubscriptionPage(),
                ),
              );
            },
            child: const Text('Lihat Paket Langganan'),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview(ThemeData theme) {
    if (_logoImageFile == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.photo_on_rectangle, size: 40, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(height: 8),
            Text('Pilih Logo', style: theme.textTheme.bodyMedium),
          ],
        ),
      );
    }

    if (kIsWeb) {
      return Image.network(_logoImageFile!.path, fit: BoxFit.cover);
    } else {
      return Image.file(File(_logoImageFile!.path), fit: BoxFit.cover);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isFirstStore ? 'Buat Toko Pertama' : 'Tambah Toko'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                    Text(
                      'Logo Toko (Opsional)',
                      style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        width: double.infinity,
                        height: 150,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.3),
                          ),
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
                      'Informasi Toko',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Nama Toko',
                      controller: _nameController,
                      validator: (value) => (value == null || value.isEmpty) ? 'Nama toko tidak boleh kosong' : null,
                      prefixIcon: const Icon(CupertinoIcons.building_2_fill),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Deskripsi Toko',
                      controller: _descriptionController,
                      validator: (value) => (value == null || value.isEmpty) ? 'Deskripsi toko tidak boleh kosong' : null,
                      maxLines: 2,
                      prefixIcon: const Icon(CupertinoIcons.doc_text),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Alamat',
                      controller: _addressController,
                      validator: (value) => (value == null || value.isEmpty) ? 'Alamat tidak boleh kosong' : null,
                      maxLines: 3,
                      prefixIcon: const Icon(CupertinoIcons.location),
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
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
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
                text: widget.isFirstStore
                    ? 'Buat Toko Pertama'
                    : 'Simpan Toko Baru',
                onPressed: _saveStore,
                isLoading: _isSaving,
                icon: const Icon(CupertinoIcons.checkmark_circle),
              ),
            ],
          ),
        ),
      ),
    );
  }
}