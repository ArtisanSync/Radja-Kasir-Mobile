import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/helpers/currency_format.dart';
import 'package:kasir/models/product_model.dart';
import 'package:kasir/providers/product_providers.dart';
import 'package:kasir/screens/product/form_product.dart';
import 'package:confirm_dialog/confirm_dialog.dart';

class ProductDetail extends ConsumerWidget {
  final Product product;

  const ProductDetail({Key? key, required this.product}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        title: Text(
          product.name,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () async {
              final result = await ref.read(productProvider.notifier).toggleFavorite(product.id!);
              if (result) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      product.isFavorite 
                          ? 'Dihapus dari favorit' 
                          : 'Ditambah ke favorit'
                    ),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            icon: Icon(
              product.isFavorite ? Icons.favorite : Icons.favorite_border,
              color: product.isFavorite ? Colors.red : theme.colorScheme.onSurface,
            ),
            tooltip: product.isFavorite ? 'Hapus dari favorit' : 'Tambah ke favorit',
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              switch (value) {
                case 'edit':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FormProduct(product: product),
                    ),
                  );
                  break;
                case 'delete':
                  final confirmed = await confirm(
                    context,
                    title: const Text('Hapus Produk'),
                    content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
                    textOK: const Text('Hapus'),
                    textCancel: const Text('Batal'),
                  );
                  
                  if (confirmed) {
                    final success = await ref.read(productProvider.notifier).deleteProduct(product.id!);
                    if (success) {
                      Navigator.of(context).pop();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Produk berhasil dihapus'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    } else {
                      final error = ref.read(productProvider).error;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error ?? 'Gagal menghapus produk'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                  break;
              }
            },
            itemBuilder: (BuildContext context) => [
              const PopupMenuItem<String>(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    Gap(8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem<String>(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    Gap(8),
                    Text('Hapus', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image
            ModernCard(
              child: Container(
                height: 300,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: product.image != null
                      ? CachedNetworkImage(
                          imageUrl: product.image!,
                          fit: BoxFit.cover,
                          width: double.infinity,
                          placeholder: (context, url) => Container(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            child: Icon(
                              Icons.image,
                              size: 80,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                            child: Icon(
                              Icons.broken_image,
                              size: 80,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        )
                      : Icon(
                          Icons.image,
                          size: 80,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                ),
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
                  
                  _buildInfoRow(
                    context,
                    'Nama Produk',
                    product.name,
                  ),
                  
                  if (product.code != null) ...[
                    const Gap(12),
                    _buildInfoRow(
                      context,
                      'Kode Produk',
                      product.code!,
                    ),
                  ],
                  
                  if (product.brand != null) ...[
                    const Gap(12),
                    _buildInfoRow(
                      context,
                      'Brand/Merek',
                      product.brand!,
                    ),
                  ],
                  
                  if (product.category != null) ...[
                    const Gap(12),
                    _buildInfoRow(
                      context,
                      'Kategori',
                      product.category!.name,
                    ),
                  ],
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
                  
                  _buildInfoRow(
                    context,
                    'Jumlah Stok',
                    '${product.totalQuantity} ${product.displayUnit}',
                  ),
                  
                  const Gap(12),
                  
                  _buildInfoRow(
                    context,
                    'Status Stok',
                    product.hasStock 
                        ? (product.isLowStock ? 'Menipis' : 'Tersedia') 
                        : 'Habis',
                    valueColor: product.hasStock 
                        ? (product.isLowStock ? Colors.orange : Colors.green)
                        : Colors.red,
                  ),
                  
                  if (product.variants.isNotEmpty) ...[
                    const Gap(12),
                    _buildInfoRow(
                      context,
                      'Harga Modal',
                      CurrencyFormat.formatPrice(product.variants.first.capitalPrice),
                    ),
                    
                    const Gap(12),
                    _buildInfoRow(
                      context,
                      'Harga Jual',
                      CurrencyFormat.formatPrice(product.variants.first.price),
                      valueColor: theme.colorScheme.primary,
                    ),
                    
                    if (product.variants.first.tax > 0) ...[
                      const Gap(12),
                      _buildInfoRow(
                        context,
                        'Pajak',
                        '${product.variants.first.tax}%',
                      ),
                    ],
                    
                    if (double.tryParse(product.variants.first.discountRp) != null &&
                        double.parse(product.variants.first.discountRp) > 0) ...[
                      const Gap(12),
                      _buildInfoRow(
                        context,
                        'Diskon (Rp)',
                        CurrencyFormat.formatPrice(product.variants.first.discountRp),
                      ),
                    ],
                    
                    if (product.variants.first.discountPercent > 0) ...[
                      const Gap(12),
                      _buildInfoRow(
                        context,
                        'Diskon (%)',
                        '${product.variants.first.discountPercent}%',
                      ),
                    ],
                    
                    const Gap(12),
                    _buildInfoRow(
                      context,
                      'Harga Final',
                      CurrencyFormat.formatPrice(product.variants.first.finalPrice),
                      valueColor: Colors.green,
                    ),
                  ],
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
                  
                  _buildInfoRow(
                    context,
                    'Status',
                    product.active ? 'Aktif' : 'Nonaktif',
                    valueColor: product.active ? Colors.green : Colors.red,
                  ),
                  
                  const Gap(12),
                  
                  _buildInfoRow(
                    context,
                    'Favorit',
                    product.isFavorite ? 'Ya' : 'Tidak',
                    valueColor: product.isFavorite ? Colors.red : null,
                  ),
                  
                  const Gap(12),
                  
                  _buildInfoRow(
                    context,
                    'Dibuat',
                    _formatDateTime(product.createdAt),
                  ),
                  
                  const Gap(12),
                  
                  _buildInfoRow(
                    context,
                    'Diubah',
                    _formatDateTime(product.updatedAt),
                  ),
                ],
              ),
            ),

            const Gap(32),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ModernOutlinedButton(
                    text: 'Edit Produk',
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => FormProduct(product: product),
                        ),
                      );
                    },
                    icon: const Icon(Icons.edit),
                  ),
                ),
                const Gap(12),
                Expanded(
                  child: ModernButton(
                    text: 'Hapus',
                    onPressed: () async {
                      final confirmed = await confirm(
                        context,
                        title: const Text('Hapus Produk'),
                        content: Text('Apakah Anda yakin ingin menghapus "${product.name}"?'),
                        textOK: const Text('Hapus'),
                        textCancel: const Text('Batal'),
                      );
                      
                      if (confirmed) {
                        final success = await ref.read(productProvider.notifier).deleteProduct(product.id!);
                        if (success) {
                          Navigator.of(context).pop();
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Produk berhasil dihapus'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        } else {
                          final error = ref.read(productProvider).error;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(error ?? 'Gagal menghapus produk'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      foregroundColor: Colors.white,
                    ),
                  ),
                ),
              ],
            ),

            const Gap(16),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value, {
    Color? valueColor,
  }) {
    final theme = Theme.of(context);
    
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const Text(' : '),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              color: valueColor ?? theme.colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.day}/${dateTime.month}/${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }
}
