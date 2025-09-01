import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/modern_buttons.dart';
import 'package:kasir/models/store_model.dart';
import 'package:kasir/providers/store_providers.dart';
import 'package:kasir/screens/profile/business_profile_page.dart';
import 'package:kasir/screens/store/add_store_page.dart';
import 'package:kasir/helpers/colors_theme.dart';
import 'package:cached_network_image/cached_network_image.dart';

class StoreListPage extends ConsumerStatefulWidget {
  const StoreListPage({Key? key}) : super(key: key);

  @override
  ConsumerState<StoreListPage> createState() => _StoreListPageState();
}

class _StoreListPageState extends ConsumerState<StoreListPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadStores();
    });
  }

  Future<void> _loadStores() async {
    await ref.read(storeProvider.notifier).loadMyStores();
  }

  @override
  Widget build(BuildContext context) {
    final storeState = ref.watch(storeProvider);
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Toko Saya'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddStorePage(),
            ),
          );
          if (result == true) {
            _loadStores();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Tambah Toko'),
        backgroundColor: AppColor.primary,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStores,
        color: AppColor.primary,
        child: storeState.isLoading
            ? Center(child: CircularProgressIndicator(color: AppColor.primary))
            : storeState.stores.isEmpty
                ? _buildEmptyState(theme)
                : _buildStoreList(storeState.stores, theme),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.store,
            size: 80,
            color: AppColor.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Belum Ada Toko',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tambahkan toko pertama Anda untuk mulai mengelola bisnis',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 24),
          ModernButton(
            text: 'Tambah Toko',
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AddStorePage(),
                ),
              );
              if (result == true) {
                _loadStores();
              }
            },
            isExpanded: false,
            icon: const Icon(Icons.add),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColor.primary,
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStoreList(List<StoreModel> stores, ThemeData theme) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: stores.length,
      itemBuilder: (context, index) {
        final store = stores[index];
        return _buildStoreCard(store, theme);
      },
    );
  }

  Widget _buildStoreCard(StoreModel store, ThemeData theme) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      elevation: 2,
      color: const Color(0xFFF5F5F5),
      child: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: Icon(
                Icons.business,
                size: 120,
                color: AppColor.primary.withOpacity(0.06),
              ),
            ),
          ),
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BusinessProfilePage(storeId: store.id),
                ),
              ).then((_) => _loadStores());
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300, width: 1),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          // --- [PERBAIKAN] Menambahkan pengecekan `isNotEmpty` ---
                          child: (store.logo != null && store.logo!.isNotEmpty)
                              ? CachedNetworkImage(
                                  imageUrl: store.logo!,
                                  fit: BoxFit.cover,
                                  width: 60,
                                  height: 60,
                                  errorWidget: (context, error, stackTrace) {
                                    return Icon(Icons.business, size: 30, color: Colors.grey[600]);
                                  },
                                )
                              : Icon(Icons.business, size: 30, color: Colors.grey[600]),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              store.name,
                              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              store.description,
                              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                _buildStatChip(
                                  Icons.shopping_bag_outlined,
                                  store.counts?['products'] ?? 0,
                                  'Produk',
                                  AppColor.badgeYellow,
                                  Colors.black87,
                                ),
                                const SizedBox(width: 8),
                                _buildStatChip(
                                  Icons.people_outline,
                                  store.counts?['members'] ?? 0,
                                  'Member',
                                  AppColor.badgeYellow,
                                  Colors.black87,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.location_on_outlined, size: 16, color: Colors.grey[600]),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          store.address,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if (store.phone != null && store.phone!.isNotEmpty) ...[
                        const SizedBox(width: 8),
                        Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Text(
                          store.phone!,
                          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AppColor.badgeYellow,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          store.storeType,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      IconButton(
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () => _showStoreOptions(store),
                        icon: Icon(Icons.more_vert, color: Colors.grey[700]),
                        tooltip: 'Opsi',
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatChip(IconData icon, int count, String label, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: textColor),
          const SizedBox(width: 4),
          Text(
            '$count $label',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }

  void _showStoreOptions(StoreModel store) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.edit, color: Colors.grey[700]),
              title: const Text('Edit Profil Usaha'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BusinessProfilePage(storeId: store.id),
                  ),
                ).then((_) => _loadStores());
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.delete, color: Colors.red),
              title: const Text(
                'Hapus Toko',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () {
                Navigator.pop(context);
                _confirmDeleteStore(store);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _confirmDeleteStore(StoreModel store) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Toko'),
        content: Text('Anda yakin ingin menghapus toko ${store.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final result = await ref.read(storeProvider.notifier).deleteStore(store.id);
              if (!mounted) return;
              if (result['success'] == true) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Toko berhasil dihapus'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(result['message'] ?? 'Gagal menghapus toko'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}