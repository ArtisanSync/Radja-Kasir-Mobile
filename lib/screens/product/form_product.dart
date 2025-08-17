// screens/product/form_product.dart
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/product_providers.dart';
import 'package:kasir/providers/category_providers.dart';
import 'package:loader_overlay/loader_overlay.dart';

class FormProduct extends ConsumerStatefulWidget {
  final Product? product;

  const FormProduct({Key? key, this.product}) : super(key: key);

  @override
  ConsumerState<FormProduct> createState() => _FormProductState();
}

class _FormProductState extends ConsumerState<FormProduct> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _brandController = TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  final TextEditingController _capitalPriceController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _taxController = TextEditingController();
  final TextEditingController _discountRpController = TextEditingController();
  final TextEditingController _discountPercentController = TextEditingController();

  String? selectedCategoryId;
  String? selectedUnitId;
  XFile? selectedImage;
  bool isEditing = false;

  @override
  void initState() {
    super.initState();
    isEditing = widget.product != null;
    
    if (isEditing) {
      _populateFields();
    } else {
      // Set default values for new product
      _quantityController.text = '0';
      _capitalPriceController.text = '0';
      _priceController.text = '0';
      _taxController.text = '0';
      _discountRpController.text = '0';
      _discountPercentController.text = '0';
    }

    // Load initial data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(categoryProvider.notifier).loadCategories();
    });
  }

  void _populateFields() {
    final product = widget.product!;
    _nameController.text = product.name;
    _codeController.text = product.code ?? '';
    _brandController.text = product.brand ?? '';
    selectedCategoryId = product.categoryId;
    
    if (product.variants.isNotEmpty) {
      final variant = product.variants.first;
      _quantityController.text = variant.quantity.toString();
      _capitalPriceController.text = variant.capitalPrice;
      _priceController.text = variant.price;
      _taxController.text = variant.tax.toString();
      _discountRpController.text = variant.discountRp;
      _discountPercentController.text = variant.discountPercent.toString();
      selectedUnitId = variant.unitId;
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
    final theme = Theme.of(context);
    
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            
            Text(
              'Pilih Gambar',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            
            Row(
              children: [
                Expanded(
                  child: ModernButton(
                    text: 'Kamera',
                    onPressed: () async {
                      Navigator.pop(context);
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.camera,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                        });
                      }
                    },
                    icon: const Icon(CupertinoIcons.camera),
                    isExpanded: false,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ModernOutlinedButton(
                    text: 'Galeri',
                    onPressed: () async {
                      Navigator.pop(context);
                      final ImagePicker picker = ImagePicker();
                      final XFile? image = await picker.pickImage(
                        source: ImageSource.gallery,
                        imageQuality: 80,
                      );
                      if (image != null) {
                        setState(() {
                          selectedImage = image;
                        });
                      }
                    },
                    icon: const Icon(CupertinoIcons.photo),
                    isExpanded: false,
                  ),
                ),
              ],
            ),
            
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 20),
          ],
        ),
      ),
    );
  }

  Future<void> _saveProduct() async {
    // No client-side validation - let backend handle it
    bool success;
    
    if (isEditing) {
      success = await ref.read(productProvider.notifier).updateProduct(
        widget.product!.id!,
        name: _nameController.text.trim(),
        code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        categoryId: selectedCategoryId,
        image: selectedImage?.path,
        unitId: selectedUnitId,
        quantity: int.tryParse(_quantityController.text),
        capitalPrice: _capitalPriceController.text.trim(),
        price: _priceController.text.trim(),
        tax: int.tryParse(_taxController.text),
        discountRp: _discountRpController.text.trim(),
        discountPercent: int.tryParse(_discountPercentController.text),
      );
    } else {
      success = await ref.read(productProvider.notifier).createProduct(
        name: _nameController.text.trim(),
        code: _codeController.text.trim().isEmpty ? null : _codeController.text.trim(),
        brand: _brandController.text.trim().isEmpty ? null : _brandController.text.trim(),
        categoryId: selectedCategoryId,
        image: selectedImage?.path,
        unitId: selectedUnitId ?? '',
        quantity: int.tryParse(_quantityController.text) ?? 0,
        capitalPrice: _capitalPriceController.text.trim(),
        price: _priceController.text.trim(),
        tax: int.tryParse(_taxController.text) ?? 0,
        discountRp: _discountRpController.text.trim(),
        discountPercent: int.tryParse(_discountPercentController.text) ?? 0,
      );
    }

    final productState = ref.read(productProvider);
    
    if (success) {
      _showSnackBar(
        message: isEditing ? 'Produk berhasil diperbarui' : 'Produk berhasil ditambahkan',
        isError: false,
      );
      Navigator.pop(context);
    } else {
      _showSnackBar(
        message: productState.error ?? 'Terjadi kesalahan',
        isError: true,
      );
    }
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
    final categoryState = ref.watch(categoryProvider);
    final unitsAsyncValue = ref.watch(unitsProvider);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Icon(
            CupertinoIcons.back,
            color: theme.colorScheme.onSurface,
          ),
        ),
        title: Text(
          isEditing ? 'Edit Produk' : 'Tambah Produk',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Image Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.photo,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Foto Produk',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            width: double.infinity,
                            height: 200,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: theme.colorScheme.outline.withOpacity(0.3),
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: selectedImage != null
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.file(
                                      File(selectedImage!.path),
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                : widget.product?.image != null && selectedImage == null
                                    ? ClipRRect(
                                        borderRadius: BorderRadius.circular(12),
                                        child: Image.network(
                                          widget.product!.image!,
                                          fit: BoxFit.cover,
                                          errorBuilder: (context, error, stackTrace) => 
                                              _buildImagePlaceholder(theme),
                                        ),
                                      )
                                    : _buildImagePlaceholder(theme),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Basic Info Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.info_circle,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Informasi Dasar',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        
                        ModernTextField(
                          label: "Nama Produk *",
                          controller: _nameController,
                          prefixIcon: const Icon(CupertinoIcons.cube_box),
                        ),
                        const SizedBox(height: 16),
                        
                        ModernTextField(
                          label: "Kode Produk",
                          controller: _codeController,
                          prefixIcon: const Icon(CupertinoIcons.barcode),
                        ),
                        const SizedBox(height: 16),
                        
                        ModernTextField(
                          label: "Merek/Brand",
                          controller: _brandController,
                          prefixIcon: const Icon(CupertinoIcons.tag),
                        ),
                        const SizedBox(height: 16),

                        // Category Dropdown
                        DropdownButtonFormField<String>(
                          value: selectedCategoryId,
                          decoration: InputDecoration(
                            labelText: "Kategori",
                            prefixIcon: const Icon(CupertinoIcons.folder),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
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
                              selectedCategoryId = value;
                            });
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Stock & Price Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.money_dollar_circle,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Stok & Harga',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: ModernTextField(
                                label: "Stok *",
                                controller: _quantityController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(CupertinoIcons.number),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: unitsAsyncValue.when(
                                data: (units) => DropdownButtonFormField<String>(
                                  value: selectedUnitId,
                                  decoration: InputDecoration(
                                    labelText: "Satuan *",
                                    prefixIcon: const Icon(CupertinoIcons.textformat_size),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(12),
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
                                      selectedUnitId = value;
                                    });
                                  },
                                ),
                                loading: () => const CircularProgressIndicator(),
                                error: (error, stack) => const Text('Error loading units'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        ModernTextField(
                          label: "Harga Modal *",
                          controller: _capitalPriceController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(CupertinoIcons.money_dollar),
                        ),
                        const SizedBox(height: 16),
                        
                        ModernTextField(
                          label: "Harga Jual *",
                          controller: _priceController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(CupertinoIcons.money_dollar_circle_fill),
                        ),
                        const SizedBox(height: 16),
                        
                        ModernTextField(
                          label: "Pajak (%)",
                          controller: _taxController,
                          keyboardType: TextInputType.number,
                          prefixIcon: const Icon(CupertinoIcons.percent),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Discount Section
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              CupertinoIcons.tag_fill,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              'Diskon (Opsional)',
                              style: theme.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),

                        Row(
                          children: [
                            Expanded(
                              child: ModernTextField(
                                label: "Diskon (Rp)",
                                controller: _discountRpController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(CupertinoIcons.minus_circle),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: ModernTextField(
                                label: "Diskon (%)",
                                controller: _discountPercentController,
                                keyboardType: TextInputType.number,
                                prefixIcon: const Icon(CupertinoIcons.percent),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: ModernOutlinedButton(
                        text: 'Batal',
                        onPressed: () => Navigator.pop(context),
                        icon: const Icon(CupertinoIcons.xmark),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ModernButton(
                        text: isEditing ? 'Perbarui' : 'Simpan',
                        onPressed: _saveProduct,
                        icon: Icon(
                          isEditing ? CupertinoIcons.checkmark_circle : CupertinoIcons.plus_circle,
                        ),
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildImagePlaceholder(ThemeData theme) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          CupertinoIcons.camera,
          size: 48,
          color: theme.colorScheme.onSurfaceVariant,
        ),
        const SizedBox(height: 8),
        Text(
          'Tap untuk menambah foto',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}