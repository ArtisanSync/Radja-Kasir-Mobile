import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:kasir/providers/product_provider.dart';
import 'package:kasir/providers/category_provider.dart';
import 'package:kasir/models/modern_product_model.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:kasir/screens/product/modern_form_product.dart';
import 'package:kasir/services/store_services.dart';
import 'package:kasir/core/use_store.dart';

class ModernProductDetail extends StatefulWidget {
  final String productId;

  const ModernProductDetail({
    super.key,
    required this.productId,
  });

  @override
  State<ModernProductDetail> createState() => _ModernProductDetailState();
}

class _ModernProductDetailState extends State<ModernProductDetail> {
  final StoreServices _storeServices = StoreServices();

  ProductModel? _product;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadProduct();
  }

  Future<void> _loadProduct() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    // Check if store data exists, if not initialize it
    final store = await Store.getStore();
    if (store == null || store['id'] == null) {
      await _storeServices.initializeStore();
    }

    if (mounted) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      final product = await provider.getProductById(widget.productId);

      setState(() {
        _product = product;
        _error = provider.error;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Detail Produk',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_product != null) ...[
            Consumer<ProductProvider>(
              builder: (context, provider, child) {
                return IconButton(
                  onPressed: () {
                    provider.toggleFavorite(_product!.id);
                    setState(() {
                      _product = _product!.copyWith(
                        isFavorite: !_product!.isFavorite,
                      );
                    });
                  },
                  icon: Icon(
                    _product!.isFavorite
                        ? Icons.favorite_rounded
                        : Icons.favorite_border_rounded,
                    color: _product!.isFavorite ? Colors.red : Colors.grey,
                  ),
                );
              },
            ),
            IconButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MultiProvider(
                      providers: [
                        ChangeNotifierProvider(
                            create: (context) => ProductProvider()),
                        ChangeNotifierProvider(
                            create: (context) => CategoryProvider()),
                      ],
                      child: ModernFormProduct(product: _product),
                    ),
                  ),
                ).then((value) {
                  if (value == true) {
                    _loadProduct(); // Refresh data
                  }
                });
              },
              icon: const Icon(Icons.edit_rounded, color: AppColor.primary),
            ),
          ],
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColor.primary),
      );
    }

    if (_error != null) {
      return _buildErrorWidget();
    }

    if (_product == null) {
      return _buildNotFoundWidget();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildImageSection(),
          const SizedBox(height: 16),
          _buildBasicInfoSection(),
          const SizedBox(height: 16),
          _buildPricingSection(),
          const SizedBox(height: 16),
          _buildStockSection(),
          const SizedBox(height: 16),
          _buildVariantsSection(),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadProduct,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotFoundWidget() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2_outlined,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'Produk Tidak Ditemukan',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey[700],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Produk yang Anda cari tidak ditemukan atau telah dihapus',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back_rounded),
              label: const Text('Kembali'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColor.primary,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageSection() {
    return Container(
      width: double.infinity,
      height: 250,
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
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: _product!.image != null
            ? Image.network(
                _product!.image!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return _buildImagePlaceholder();
                },
              )
            : _buildImagePlaceholder(),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: Colors.grey[100],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.inventory_2_rounded,
            size: 64,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 8),
          Text(
            'Tidak ada gambar',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection() {
    return _buildSectionCard(
      title: 'Informasi Produk',
      children: [
        _buildInfoRow(
          icon: Icons.inventory_2_rounded,
          label: 'Nama Produk',
          value: _product!.name,
        ),
        if (_product!.code != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.qr_code_rounded,
            label: 'Kode Produk',
            value: _product!.code!,
          ),
        ],
        if (_product!.brand != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.branding_watermark_rounded,
            label: 'Brand/Merk',
            value: _product!.brand!,
          ),
        ],
        if (_product!.category != null) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.category_rounded,
            label: 'Kategori',
            value: _product!.category!.name,
          ),
        ],
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.toggle_on_rounded,
          label: 'Status',
          value: _product!.active ? 'Aktif' : 'Tidak Aktif',
          valueColor: _product!.active ? Colors.green : Colors.red,
        ),
        const SizedBox(height: 12),
        _buildInfoRow(
          icon: Icons.access_time_rounded,
          label: 'Dibuat',
          value: _formatDateTime(_product!.createdAt),
        ),
      ],
    );
  }

  Widget _buildPricingSection() {
    final variant =
        _product!.variants.isNotEmpty ? _product!.variants.first : null;

    if (variant == null) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'Informasi Harga',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildPriceCard(
                title: 'Harga Modal',
                value: 'Rp ${_formatCurrency(variant.capitalPrice)}',
                color: Colors.blue,
                icon: Icons.attach_money_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceCard(
                title: 'Harga Jual',
                value: 'Rp ${_formatCurrency(variant.price)}',
                color: Colors.green,
                icon: Icons.sell_rounded,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildPriceCard(
                title: 'Diskon (%)',
                value: '${variant.discountPercent}%',
                color: Colors.orange,
                icon: Icons.percent_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildPriceCard(
                title: 'Diskon (Rp)',
                value: 'Rp ${_formatCurrency(variant.discountRp)}',
                color: Colors.purple,
                icon: Icons.discount_rounded,
              ),
            ),
          ],
        ),
        if (variant.tax > 0) ...[
          const SizedBox(height: 12),
          _buildInfoRow(
            icon: Icons.receipt_rounded,
            label: 'Pajak',
            value: '${variant.tax}%',
          ),
        ],
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.calculate_rounded,
                color: Colors.green[700],
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Harga Final: Rp ${_formatCurrency(variant.finalPrice.toString())}',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[700],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStockSection() {
    return _buildSectionCard(
      title: 'Informasi Stok',
      children: [
        Row(
          children: [
            Expanded(
              child: _buildStockCard(
                title: 'Total Stok',
                value: _product!.totalQuantity.toString(),
                unit: _product!.displayUnit,
                color: _product!.isLowStock ? Colors.red : Colors.blue,
                icon: Icons.inventory_rounded,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStockCard(
                title: 'Status Stok',
                value: _product!.hasStock ? 'Tersedia' : 'Habis',
                unit: '',
                color: _product!.hasStock ? Colors.green : Colors.red,
                icon: _product!.hasStock
                    ? Icons.check_circle_rounded
                    : Icons.error_rounded,
              ),
            ),
          ],
        ),
        if (_product!.isLowStock) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange[50],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_rounded,
                  color: Colors.orange[700],
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Stok rendah! Segera lakukan restock.',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.orange[700],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildVariantsSection() {
    if (_product!.variants.isEmpty) return const SizedBox.shrink();

    return _buildSectionCard(
      title: 'Varian Produk (${_product!.variants.length})',
      children: [
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: _product!.variants.length,
          separatorBuilder: (context, index) => const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final variant = _product!.variants[index];
            return _buildVariantCard(variant);
          },
        ),
      ],
    );
  }

  Widget _buildVariantCard(ProductVariant variant) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.label_rounded,
                color: AppColor.primary,
                size: 16,
              ),
              const SizedBox(width: 8),
              Text(
                variant.name,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (variant.unit != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    variant.unit!.name,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Qty: ${variant.quantity}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Modal: Rp ${_formatCurrency(variant.capitalPrice)}',
                style: const TextStyle(fontSize: 12),
              ),
              Text(
                'Jual: Rp ${_formatCurrency(variant.price)}',
                style:
                    const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
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

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          icon,
          color: AppColor.primary,
          size: 20,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: valueColor ?? Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPriceCard({
    required String title,
    required String value,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildStockCard({
    required String title,
    required String value,
    required String unit,
    required Color color,
    required IconData icon,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 4),
                Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                  ),
                ),
              ],
            ],
          ),
          Text(
            title,
            style: TextStyle(
              fontSize: 10,
              color: color.withOpacity(0.8),
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  String _formatCurrency(String value) {
    final number = double.tryParse(value) ?? 0;
    return number.toStringAsFixed(0).replaceAllMapped(
          RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
          (Match match) => '${match[1]}.',
        );
  }

  String _formatDateTime(DateTime dateTime) {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des'
    ];

    return '${dateTime.day} ${months[dateTime.month - 1]} ${dateTime.year}';
  }
}
