import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:kasir/providers/product_provider.dart';
import 'package:kasir/providers/category_provider.dart';
import 'package:kasir/models/modern_product_model.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/components/button_primary.dart';
import 'package:kasir/components/button_light.dart';
import 'package:kasir/services/store_services.dart';
import 'package:kasir/core/use_store.dart';

class ModernFormProduct extends StatefulWidget {
  final ProductModel? product;

  const ModernFormProduct({
    super.key,
    this.product,
  });

  @override
  State<ModernFormProduct> createState() => _ModernFormProductState();
}

class _ModernFormProductState extends State<ModernFormProduct> {
  final _formKey = GlobalKey<FormState>();
  final ImagePicker _picker = ImagePicker();
  final StoreServices _storeServices = StoreServices();

  // Controllers
  late final TextEditingController _nameController;
  late final TextEditingController _codeController;
  late final TextEditingController _brandController;
  late final TextEditingController _capitalPriceController;
  late final TextEditingController _priceController;
  late final TextEditingController _discountRpController;
  late final TextEditingController _discountPercentController;
  late final TextEditingController _quantityController;
  late final TextEditingController _taxController;

  // Form state
  XFile? _imageFile;
  String? _selectedCategoryId;
  String? _selectedUnitId;
  bool _isLoading = false;

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadInitialData();
  }

  void _initializeControllers() {
    final product = widget.product;
    final variant =
        product?.variants.isNotEmpty == true ? product!.variants.first : null;

    _nameController = TextEditingController(text: product?.name ?? '');
    _codeController = TextEditingController(text: product?.code ?? '');
    _brandController = TextEditingController(text: product?.brand ?? '');
    _capitalPriceController =
        TextEditingController(text: variant?.capitalPrice ?? '0');
    _priceController = TextEditingController(text: variant?.price ?? '0');
    _discountRpController =
        TextEditingController(text: variant?.discountRp ?? '0');
    _discountPercentController =
        TextEditingController(text: variant?.discountPercent.toString() ?? '0');
    _quantityController =
        TextEditingController(text: variant?.quantity.toString() ?? '1');
    _taxController =
        TextEditingController(text: variant?.tax.toString() ?? '0');

    _selectedCategoryId = product?.categoryId;
    _selectedUnitId = variant?.unitId;
  }

  void _loadInitialData() async {
    // Check if store data exists, if not initialize it
    final store = await Store.getStore();
    if (store == null || store['id'] == null) {
      await _storeServices.initializeStore();
    }

    // Load data
    if (mounted) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final productProvider =
            Provider.of<ProductProvider>(context, listen: false);
        final categoryProvider =
            Provider.of<CategoryProvider>(context, listen: false);

        productProvider.loadUnits();
        categoryProvider.loadCategories();
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _codeController.dispose();
    _brandController.dispose();
    _capitalPriceController.dispose();
    _priceController.dispose();
    _discountRpController.dispose();
    _discountPercentController.dispose();
    _quantityController.dispose();
    _taxController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1000,
        maxHeight: 1000,
        imageQuality: 80,
      );

      if (image != null) {
        setState(() {
          _imageFile = image;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error picking image: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedUnitId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Silakan pilih satuan produk'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final productProvider =
          Provider.of<ProductProvider>(context, listen: false);

      // Prepare image data
      String? imageData;
      if (_imageFile != null) {
        if (kIsWeb) {
          // For web, convert to base64 data URL
          try {
            final bytes = await _imageFile!.readAsBytes();
            final extension = _imageFile!.name.split('.').last.toLowerCase();
            String mimeType = 'image/png';

            if (extension == 'jpg' || extension == 'jpeg') {
              mimeType = 'image/jpeg';
            } else if (extension == 'png') {
              mimeType = 'image/png';
            }

            final base64String = base64Encode(bytes);
            imageData = 'data:$mimeType;base64,$base64String';
          } catch (e) {
            debugPrint('Error processing image for web: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Error processing image. Please try again.'),
                backgroundColor: Colors.red,
              ),
            );
            setState(() {
              _isLoading = false;
            });
            return;
          }
        } else {
          // For mobile, use file path
          imageData = _imageFile!.path;
        }
      }

      bool success = false;

      if (isEditing) {
        // Update existing product
        success = await productProvider.updateProduct(
          widget.product!.id,
          name: _nameController.text.trim(),
          code: _codeController.text.trim().isEmpty
              ? null
              : _codeController.text.trim(),
          brand: _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
          categoryId: _selectedCategoryId,
          image: imageData,
        );

        // TODO: Update variant data separately if needed
        // The current API might not support variant updates directly
      } else {
        // Create new product
        success = await productProvider.createProduct(
          name: _nameController.text.trim(),
          code: _codeController.text.trim().isEmpty
              ? null
              : _codeController.text.trim(),
          brand: _brandController.text.trim().isEmpty
              ? null
              : _brandController.text.trim(),
          categoryId: _selectedCategoryId,
          image: imageData,
          unitId: _selectedUnitId!,
          quantity: int.parse(_quantityController.text),
          capitalPrice: _capitalPriceController.text,
          price: _priceController.text,
          tax: int.tryParse(_taxController.text) ?? 0,
          discountRp: _discountRpController.text,
          discountPercent: int.tryParse(_discountPercentController.text) ?? 0,
        );
      }

      if (success) {
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Produk berhasil ${isEditing ? 'diupdate' : 'ditambahkan'}'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(productProvider.error ?? 'Terjadi kesalahan'),
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
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          isEditing ? 'Edit Produk' : 'Tambah Produk',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image Section
              _buildImageSection(),
              const SizedBox(height: 24),

              // Basic Info Section
              _buildSectionCard(
                title: 'Informasi Dasar',
                children: [
                  _buildTextField(
                    controller: _nameController,
                    label: 'Nama Produk',
                    hint: 'Masukkan nama produk',
                    required: true,
                    prefixIcon: Icons.inventory_2_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _codeController,
                    label: 'Kode Produk',
                    hint: 'Masukkan kode produk (opsional)',
                    prefixIcon: Icons.qr_code_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _brandController,
                    label: 'Brand/Merk',
                    hint: 'Masukkan brand/merk (opsional)',
                    prefixIcon: Icons.branding_watermark_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildCategoryDropdown(),
                ],
              ),
              const SizedBox(height: 16),

              // Pricing Section
              _buildSectionCard(
                title: 'Pengaturan Harga',
                children: [
                  _buildTextField(
                    controller: _capitalPriceController,
                    label: 'Harga Modal',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.attach_money_rounded,
                    prefixText: 'Rp ',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _priceController,
                    label: 'Harga Jual',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.sell_rounded,
                    prefixText: 'Rp ',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _discountPercentController,
                    label: 'Diskon (%)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.percent_rounded,
                    suffixText: '%',
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(
                    controller: _discountRpController,
                    label: 'Diskon (Rp)',
                    hint: '0',
                    keyboardType: TextInputType.number,
                    prefixIcon: Icons.discount_rounded,
                    prefixText: 'Rp ',
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Stock Section
              _buildSectionCard(
                title: 'Pengaturan Stok',
                children: [
                  _buildTextField(
                    controller: _quantityController,
                    label: 'Jumlah Stok',
                    hint: '1',
                    keyboardType: TextInputType.number,
                    required: true,
                    prefixIcon: Icons.inventory_rounded,
                  ),
                  const SizedBox(height: 16),
                  _buildUnitDropdown(),
                ],
              ),
              const SizedBox(height: 32),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ButtonLight(
                      label: 'Batal',
                      onTap: () => Navigator.pop(context),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ButtonPrimary(
                      label: isEditing ? 'Update' : 'Simpan',
                      onTap: _isLoading ? null : _submit,
                      loading: _isLoading,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                const Icon(
                  Icons.camera_alt_rounded,
                  color: AppColor.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Foto Produk',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 200,
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: Colors.grey[300]!,
                style: BorderStyle.solid,
                width: 1,
              ),
            ),
            child: InkWell(
              onTap: _pickImage,
              borderRadius: BorderRadius.circular(8),
              child: _buildImagePreview(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    if (_imageFile != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: kIsWeb
                ? FutureBuilder<Uint8List>(
                    future: _imageFile!.readAsBytes(),
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return Image.memory(
                          snapshot.data!,
                          fit: BoxFit.cover,
                        );
                      }
                      return const Center(child: CircularProgressIndicator());
                    },
                  )
                : Image.file(
                    File(_imageFile!.path),
                    fit: BoxFit.cover,
                  ),
          ),
          Positioned(
            top: 8,
            right: 8,
            child: CircleAvatar(
              radius: 16,
              backgroundColor: Colors.black.withOpacity(0.6),
              child: IconButton(
                onPressed: () {
                  setState(() {
                    _imageFile = null;
                  });
                },
                icon: const Icon(
                  Icons.close_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                padding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      );
    }

    if (isEditing && widget.product?.image != null) {
      return Stack(
        fit: StackFit.expand,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(7),
            child: Image.network(
              widget.product!.image!,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                return _buildImagePlaceholder();
              },
            ),
          ),
          Positioned(
            bottom: 8,
            right: 8,
            child: FloatingActionButton.small(
              onPressed: _pickImage,
              backgroundColor: AppColor.primary,
              child: const Icon(Icons.edit_rounded, size: 16),
            ),
          ),
        ],
      );
    }

    return _buildImagePlaceholder();
  }

  Widget _buildImagePlaceholder() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.add_photo_alternate_rounded,
          size: 48,
          color: Colors.grey[400],
        ),
        const SizedBox(height: 8),
        Text(
          'Tap untuk menambah foto',
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Foto akan membantu pelanggan mengenali produk',
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildSectionCard(
      {required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    TextInputType? keyboardType,
    IconData? prefixIcon,
    String? prefixText,
    String? suffixText,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppColor.primary)
            : null,
        prefixText: prefixText,
        suffixText: suffixText,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColor.primary),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.grey[50],
      ),
      validator: required
          ? (value) {
              if (value == null || value.trim().isEmpty) {
                return '$label tidak boleh kosong';
              }
              return null;
            }
          : null,
    );
  }

  Widget _buildCategoryDropdown() {
    return Consumer<CategoryProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        return DropdownButtonFormField<String>(
          value: _selectedCategoryId,
          isExpanded: true, // Fix overflow issue
          decoration: InputDecoration(
            labelText: 'Kategori',
            hintText: 'Pilih kategori (opsional)',
            prefixIcon:
                const Icon(Icons.category_rounded, color: AppColor.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColor.primary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: [
            const DropdownMenuItem<String>(
              value: null,
              child: Text(
                'Tanpa kategori',
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
            ...provider.categories.map((category) {
              return DropdownMenuItem<String>(
                value: category.id,
                child: Text(
                  category.name,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              );
            }),
          ],
          onChanged: (value) {
            setState(() {
              _selectedCategoryId = value;
            });
          },
        );
      },
    );
  }

  Widget _buildUnitDropdown() {
    return Consumer<ProductProvider>(
      builder: (context, provider, child) {
        // Load units if not loaded yet
        if (provider.units.isEmpty && !provider.isLoading) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            provider.loadUnits();
          });
        }

        return DropdownButtonFormField<String>(
          value: _selectedUnitId,
          isExpanded: true, // Fix overflow issue
          decoration: InputDecoration(
            labelText: 'Satuan',
            hintText: provider.units.isEmpty && provider.isLoading
                ? 'Loading...'
                : 'Pilih satuan',
            prefixIcon: provider.units.isEmpty && provider.isLoading
                ? const Padding(
                    padding: EdgeInsets.all(12),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                : const Icon(Icons.straighten_rounded, color: AppColor.primary),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColor.primary),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
          ),
          items: provider.units.isEmpty
              ? null
              : provider.units.map((unit) {
                  return DropdownMenuItem<String>(
                    value: unit.id,
                    child: Text(
                      unit.name,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  );
                }).toList(),
          onChanged: provider.units.isEmpty
              ? null
              : (value) {
                  setState(() {
                    _selectedUnitId = value;
                  });
                },
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Satuan harus dipilih';
            }
            return null;
          },
        );
      },
    );
  }
}
