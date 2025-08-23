// lib/screens/profile/business_profile_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/services/profile_services.dart';

class BusinessProfilePage extends ConsumerStatefulWidget {
  const BusinessProfilePage({Key? key}) : super(key: key);

  @override
  ConsumerState<BusinessProfilePage> createState() => _BusinessProfilePageState();
}

class _BusinessProfilePageState extends ConsumerState<BusinessProfilePage> {
  final ProfileServices _profileServices = ProfileServices();
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _typeController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  
  bool _isLoading = true;
  bool _isSaving = false;
  
  @override
  void initState() {
    super.initState();
    _loadBusinessProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _typeController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _loadBusinessProfile() async {
    setState(() => _isLoading = true);
    try {
      final response = await _profileServices.profile();
      if (response.statusCode == 200) {
        final data = response.data['data'];
        setState(() {
          _nameController.text = data['store'] ?? '';
          _typeController.text = data['store_type'] ?? '';
          _addressController.text = data['address'] ?? '';
          _phoneController.text = data['whatsapp'] ?? '';
        });
      }
    } catch (e) {
      // Handle error
    } finally {
      setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveBusinessProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    try {
      final response = await _profileServices.update({
        "name": _nameController.text,
        "store_type": _typeController.text,
        "address": _addressController.text,
        "whatsapp": _phoneController.text
      });
      
      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil usaha berhasil diperbarui'), backgroundColor: Colors.green)
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal memperbarui profil usaha'), backgroundColor: Colors.red)
      );
    } finally {
      setState(() => _isSaving = false);
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
                            prefixIcon: const Icon(CupertinoIcons.building_2_fill),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Jenis Usaha',
                            controller: _typeController,
                            prefixIcon: const Icon(CupertinoIcons.tag),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'Alamat',
                            controller: _addressController,
                            maxLines: 3,
                            prefixIcon: const Icon(CupertinoIcons.location),
                          ),
                          const SizedBox(height: 16),
                          ModernTextField(
                            label: 'WhatsApp',
                            controller: _phoneController,
                            keyboardType: TextInputType.phone,
                            prefixIcon: const Icon(CupertinoIcons.phone),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    ModernButton(
                      text: 'Simpan Perubahan',
                      onPressed: _saveBusinessProfile,
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