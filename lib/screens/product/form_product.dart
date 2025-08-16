import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/product_providers.dart';
import 'package:kasir/providers/category_providers.dart';
import 'dart:convert';
import 'dart:typed_data';

class FormProduct extends ConsumerStatefulWidget {
  final Product? product;
  
  const FormProduct({Key? key, this.product}) : super(key: key);

  @override
  ConsumerState<FormProduct> createState() => _FormProductState();
}

class _FormProductState extends ConsumerState<FormProduct> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _codeController = TextEditingController();
  final _brandController = TextEditingController();
  final _quantityController = TextEditingController();
  final _capitalPriceController = TextEditingController();
  final _priceController = TextEditingController();
  final _taxController = TextEditingController();
  final _discountRpController = TextEditingController();
  final _discountPercentController = TextEditingController();

  String? _selectedCategoryId;
  String? _selectedUnitId;
  dynamic _selectedImage;
  bool _isSubmitting = false;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadInitialData();
    if (widget.product != null) {
      _populateFields();
    }
  }

  void _loadInitialData() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _codeController.text = product.code ?? '';
    _brandController.text = product.brand ?? '';
    _selectedCategoryId = product.categoryId;
    
    if (product.variants.isNotEmpty) {
      final variant = product.variants.first;
      _quantityController.text = variant.quantity.toString();
      _capitalPriceController.text = CurrencyFormat.formatCurrencyInput(variant.capitalPrice);
      _priceController.text = CurrencyFormat.formatCurrencyInput(variant.price);
      _taxController.text = variant.tax.toString();
      _discountRpController.text = CurrencyFormat.formatCurrencyInput(variant.discountRp);
      _discountPercentController.text = variant.discountPercent.toString();
      _selectedUnitId = variant.unitId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _brandController.dispose();
    _quantityController.dispose();
    _capitalPriceController.dispose();
    _priceController.dispose();
    _taxController.dispose();
    _discountRpController.dispose();
    _discountPercentController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 85,
      );
      
      if (image != null) {
        if (kIsWeb) {
          final bytes = await image.readAsBytes();
          final base64String = base64Encode(bytes);
          setState(() {
            _selectedImage = 'data:image/png;base64,$base64String';
          });
        } else {
          setState(() {
            _selectedImage = image.path;
          });
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error picking image: $e')),
      );
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a unit')),
      );
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      bool success;
      
      if (widget.product == null) {
        // Create new product
        success = await ref.read(productProvider.notifier).createProduct(
          name: _nameController.text.trim(),
          code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
          brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
          categoryId: _selectedCategoryId,
          image: _selectedImage,
          unitId: _selectedUnitId!,
          quantity: int.tryParse(_quantityController.text) ?? 0,
          capitalPrice: CurrencyFormat.parseCurrency(_capitalPriceController.text).toString(),
          price: CurrencyFormat.parseCurrency(_priceController.text).toString(),
          tax: int.tryParse(_taxController.text) ?? 0,
          discountRp: CurrencyFormat.parseCurrency(_discountRpController.text).toString(),
          discountPercent: int.tryParse(_discountPercentController.text) ?? 0,
        );
      } else {
        // Update existing product
        success = await ref.read(productProvider.notifier).updateProduct(
          widget.product!.id!,
          name: _nameController.text.trim(),
          code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
          brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
          categoryId: _selectedCategoryId,
          image: _selectedImage,
          unitId: _selectedUnitId,
          quantity: int.tryParse(_quantityController.text),
          capitalPrice: CurrencyFormat.parseCurrency(_capitalPriceController.text).toString(),
          price: CurrencyFormat.parseCurrency(_priceController.text).toString(),
          tax: int.tryParse(_taxController.text),
          discountRp: CurrencyFormat.parseCurrency(_discountRpController.text).toString(),
          discountPercent: int.tryParse(_discountPercentController.text),
        );
      }

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.product == null 
                ? 'Product created successfully' 
                : 'Product updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        final error = ref.read(productProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Failed to save product'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryState = ref.watch(categoryProvider);
    final unitsAsync = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          widget.product == null ? 'Tambah Produk' : 'Edit Produk',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Product Image
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Foto Produk',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(12),
                    GestureDetector(
                      onTap: _pickImage,
                      child: Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: theme.colorScheme.outline.withOpacity(0.5),
                            style: BorderStyle.solid,
                          ),
                        ),
                        child: _selectedImage != null
                            ? ClipRRect(
                                borderRadius: BorderRadius.circular(12),
                                child: kIsWeb
                                    ? Image.memory(
                                        base64Decode(_selectedImage.split(',')[1]),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      )
                                    : Image.file(
                                        File(_selectedImage),
                                        fit: BoxFit.cover,
                                        width: double.infinity,
                                        height: double.infinity,
                                      ),
                              )
                            : Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.add_photo_alternate_outlined,
                                    size: 48,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const Gap(8),
                                  Text(
                                    'Tap untuk menambah foto',
                                    style: theme.textTheme.bodyMedium?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                      ),
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // Basic Information
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Dasar',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(16),
                    ModernTextField(
                      label: 'Nama Produk *',
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Nama produk tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    const Gap(12),
                    ModernTextField(
                      label: 'Kode Produk',
                      controller: _codeController,
                    ),
                    const Gap(12),
                    ModernTextField(
                      label: 'Brand/Merek',
                      controller: _brandController,
                    ),
                    const Gap(12),
                    
                    // Category Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedCategoryId,
                      decoration: InputDecoration(
                        labelText: 'Kategori',
                        filled: true,
                        fillColor: theme.colorScheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                        ),
                      ),
                      items: [
                        const DropdownMenuItem<String>(
                          value: null,
                          child: Text('Pilih Kategori'),
                        ),
                        ...categoryState.categories.map(
                          (category) => DropdownMenuItem<String>(
                            value: category.id,
                            child: Text(category.name),
                          ),
                        ),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCategoryId = value;
                        });
                      },
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // Stock and Price Information
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Stok & Harga',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(16),
                    
                    Row(
                      children: [
                        Expanded(
                          child: ModernTextField(
                            label: 'Jumlah Stok *',
                            controller: _quantityController,
                            keyboardType: TextInputType.number,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Stok tidak boleh kosong';
                              }
                              if (int.tryParse(value) == null) {
                                return 'Stok harus berupa angka';
                              }
                              return null;
                            },
                          ),
                        ),
                        const Gap(12),
                        Expanded(
                          child: unitsAsync.when(
                            data: (units) => DropdownButtonFormField<String>(
                              value: _selectedUnitId,
                              decoration: InputDecoration(
                                labelText: 'Satuan *',
                                filled: true,
                                fillColor: theme.colorScheme.surface,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.colorScheme.outline),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.colorScheme.outline.withOpacity(0.5)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: theme.colorScheme.primary, width: 2),
                                ),
                              ),
                              items: units.map(
                                (unit) => DropdownMenuItem<String>(
                                  value: unit.id,
                                  child: Text(unit.name),
                                ),
                              ).toList(),
                              onChanged: (value) {
                                setState(() {
                                  _selectedUnitId = value;
                                });
                              },
                              validator: (value) {
                                if (value == null) {
                                  return 'Pilih satuan';
                                }
                                return null;
                              },
                            ),
                            loading: () => const ModernTextField(
                              label: 'Loading...',
                              enabled: false,
                            ),
                            error: (error, stack) => const ModernTextField(
                              label: 'Error loading units',
                              enabled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                    
                    const Gap(12),
                    
                    ModernTextField(
                      label: 'Harga Modal *',
                      controller: _capitalPriceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [PriceInputFormatter()],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harga modal tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                    
                    const Gap(12),
                    
                    ModernTextField(
                      label: 'Harga Jual *',
                      controller: _priceController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [PriceInputFormatter()],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Harga jual tidak boleh kosong';
                        }
                        return null;
                      },
                    ),
                  ],
                ),
              ),

              const Gap(16),

              // Additional Information
              ModernCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Tambahan',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(16),
                    
                    ModernTextField(
                      label: 'Pajak (%)',
                      controller: _taxController,
                      keyboardType: TextInputType.number,
                    ),
                    
                    const Gap(12),
                    
                    ModernTextField(
                      label: 'Diskon (Rp)',
                      controller: _discountRpController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [PriceInputFormatter()],
                    ),
                    
                    const Gap(12),
                    
                    ModernTextField(
                      label: 'Diskon (%)',
                      controller: _discountPercentController,
                      keyboardType: TextInputType.number,
                    ),
                  ],
                ),
              ),

              const Gap(32),

              // Submit Button
              ModernButton(
                text: widget.product == null ? 'Simpan Produk' : 'Update Produk',
                onPressed: _isSubmitting ? null : _submitForm,
                isLoading: _isSubmitting,
                icon: Icon(widget.product == null ? Icons.add : Icons.save),
              ),

              const Gap(16),
            ],
          ),
        ),
      ),
    );
  }
}
