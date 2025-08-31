// ignore_for_file: use_build_context_synchronously, prefer_const_constructors
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
          ? await ref.read(storeProvider.notifier).createFirstStore(storeData)
          : await ref.read(storeProvider.notifier).createStore(storeData);

      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Toko berhasil dibuat'),
            backgroundColor: Colors.green));
        Navigator.pop(context, true);
      } else {
        if (result['subscriptionRequired'] == true) {
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
      setState(() => _isSaving = false);
      context.loaderOverlay.hide();
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
                      'Informasi Toko',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Nama Toko',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Nama toko tidak boleh kosong';
                        }
                        return null;
                      },
                      prefixIcon: const Icon(CupertinoIcons.building_2_fill),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Deskripsi Toko',
                      controller: _descriptionController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Deskripsi toko tidak boleh kosong';
                        }
                        return null;
                      },
                      maxLines: 2,
                      prefixIcon: const Icon(CupertinoIcons.doc_text),
                    ),
                    const SizedBox(height: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Jenis Usaha',
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurface.withOpacity(0.7),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: theme.colorScheme.outline.withOpacity(0.5),
                            ),
                          ),
                          child: DropdownButton<String>(
                            value: _storeType,
                            isExpanded: true,
                            underline: Container(),
                            icon: const Icon(CupertinoIcons.chevron_down),
                            items: _storeTypes.map<DropdownMenuItem<String>>(
                                (Map<String, String> type) {
                              return DropdownMenuItem<String>(
                                value: type['value'],
                                child: Text(type['label'] ?? ''),
                              );
                            }).toList(),
                            onChanged: (value) {
                              setState(() => _storeType = value ?? 'RETAIL');
                            },
                          ),
                        ),
                      ],
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
                      'Kontak',
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Telepon',
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(CupertinoIcons.phone),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'WhatsApp',
                      controller: _whatsappController,
                      keyboardType: TextInputType.phone,
                      prefixIcon: const Icon(CupertinoIcons.chat_bubble_text),
                    ),
                    const SizedBox(height: 16),
                    ModernTextField(
                      label: 'Email',
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: const Icon(CupertinoIcons.mail),
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
