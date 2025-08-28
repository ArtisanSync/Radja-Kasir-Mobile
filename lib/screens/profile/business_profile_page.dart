import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/providers/store_providers.dart';
import 'package:loader_overlay/loader_overlay.dart';

class BusinessProfilePage extends ConsumerStatefulWidget {
  final String storeId;
  
  const BusinessProfilePage({
    Key? key, 
    required this.storeId
  }) : super(key: key);

  @override
  ConsumerState<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _typeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _whatsappController = TextEditingController();
  final _emailController = TextEditingController();
  
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
    _typeController.dispose();
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
        setState(() {
          final store = storeState.currentStore!;
          _nameController.text = store.name;
          _descriptionController.text = store.description;
          _typeController.text = store.storeType;
          _addressController.text = store.address;
          _phoneController.text = store.phone ?? '';
          _whatsappController.text = store.whatsapp ?? '';
          _emailController.text = store.email ?? '';
        });
      } else if (storeState.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(storeState.error!),
            backgroundColor: Colors.red,
          )
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          )
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }
  
  Future<void> _saveStoreProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    context.loaderOverlay.show();
    
    try {
      final response = await ref.read(storeProvider.notifier).updateStore(
        widget.storeId,
        {
          "name": _nameController.text,
          "description": _descriptionController.text,
          "storeType": _typeController.text,
          "address": _addressController.text,
          "phone": _phoneController.text,
          "whatsapp": _whatsappController.text,
          "email": _emailController.text
        }
      );
      
      if (response['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil usaha berhasil diperbarui'), 
            backgroundColor: Colors.green
          )
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response['message'] ?? 'Gagal memperbarui profil usaha'),
            backgroundColor: Colors.red
          )
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red
        )
      );
    } finally {
      setState(() => _isSaving = false);
      context.loaderOverlay.hide();
    }
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
                          Text(
                            'Informasi Bisnis',
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Nama Usaha',
                            controller: _nameController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama usaha tidak boleh kosong';
                              }
                              return null;
                            },
                            prefixIcon: const Icon(Icons.business),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Deskripsi',
                            controller: _descriptionController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Deskripsi tidak boleh kosong';
                              }
                              return null;
                            },
                            maxLines: 2,
                            prefixIcon: const Icon(Icons.description),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Jenis Usaha',
                            controller: _typeController,
                            prefixIcon: const Icon(Icons.category),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Alamat',
                            controller: _addressController,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Alamat tidak boleh kosong';
                              }
                              return null;
                            },
                            maxLines: 3,
                            prefixIcon: const Icon(Icons.location_on),
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
}
  