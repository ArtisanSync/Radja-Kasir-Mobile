// screens/admin/admin_subscribers_page.dart
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/providers/admin_providers.dart';
import 'package:kasir/models/admin_models.dart';
import 'package:kasir/screens/admin/subscriber_detail_page.dart';

class AdminSubscribersPage extends ConsumerStatefulWidget {
  const AdminSubscribersPage({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminSubscribersPage> createState() => _AdminSubscribersPageState();
}

class _AdminSubscribersPageState extends ConsumerState<AdminSubscribersPage> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(subscribersProvider.notifier).loadSubscribers();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final subscribersState = ref.watch(subscribersProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const NavDrawer(currentRoute: 'admin_subscribers'),
      appBar: AppBar(
        backgroundColor: Colors.red.shade600,
        foregroundColor: Colors.white,
        elevation: 0,
        leading: const MenuBuilder(),
        title: Text(
          'Kelola Pengguna',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: subscribersState.isLoading 
                ? null 
                : () => ref.read(subscribersProvider.notifier).loadSubscribers(),
            icon: subscribersState.isLoading
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(CupertinoIcons.refresh, color: Colors.white),
            tooltip: 'Refresh',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          _buildSearchAndFilters(context, theme, subscribersState),
          Expanded(
            child: _buildSubscribersList(context, theme, subscribersState),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilters(BuildContext context, ThemeData theme, SubscribersState state) {
    return ModernCard(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari pengguna berdasarkan nama atau email...',
              prefixIcon: const Icon(CupertinoIcons.search),
              suffixIcon: _searchController.text.isNotEmpty 
                ? IconButton(
                    icon: const Icon(CupertinoIcons.clear),
                    onPressed: () {
                      _searchController.clear();
                      ref.read(subscribersProvider.notifier).updateSearch('');
                      setState(() {});
                    },
                  )
                : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              filled: true,
              fillColor: Colors.grey.shade100,
            ),
            onChanged: (value) {
              ref.read(subscribersProvider.notifier).updateSearch(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: FilterChip(
                  label: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.alarm,
                        size: 16,
                        color: state.expiringOnlyFilter ? Colors.white : Colors.red.shade600,
                      ),
                      const SizedBox(width: 6),
                      const Text('Akan Berakhir'),
                    ],
                  ),
                  selected: state.expiringOnlyFilter,
                  onSelected: (selected) {
                    ref.read(subscribersProvider.notifier).updateExpiringFilter(selected);
                  },
                  backgroundColor: Colors.red.shade50,
                  selectedColor: Colors.red.shade600,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: state.expiringOnlyFilter ? Colors.white : Colors.red.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.shade200),
                ),
                child: Text(
                  '${state.filteredSubscribers.length} pengguna',
                  style: TextStyle(
                    color: Colors.blue.shade700,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubscribersList(BuildContext context, ThemeData theme, SubscribersState state) {
    if (state.isLoading && state.subscribers.isEmpty) {
      return _buildLoadingState();
    }

    if (state.error != null && state.subscribers.isEmpty) {
      return _buildErrorState(context, theme, state.error!);
    }

    final filteredSubscribers = state.filteredSubscribers;

    if (filteredSubscribers.isEmpty) {
      return _buildEmptyState(context, theme, state.searchQuery.isNotEmpty);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(subscribersProvider.notifier).loadSubscribers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        itemCount: filteredSubscribers.length,
        itemBuilder: (context, index) {
          return SubscriberCard(
            subscriber: filteredSubscribers[index],
            onTap: () => _navigateToDetail(filteredSubscribers[index]),
            onExtend: (userId) => _showExtendDialog(context, userId),
            onDelete: (userId) => _showDeleteDialog(context, userId),
          );
        },
      ),
    );
  }

  void _navigateToDetail(AdminSubscriber subscriber) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubscriberDetailPage(subscriber: subscriber),
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Memuat pengguna...',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, ThemeData theme, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                CupertinoIcons.exclamationmark_triangle,
                size: 64,
                color: Colors.red.shade600,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Terjadi Kesalahan',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: Colors.red.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(subscribersProvider.notifier).loadSubscribers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              icon: const Icon(CupertinoIcons.refresh),
              label: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme, bool isSearching) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(
                isSearching ? CupertinoIcons.search : CupertinoIcons.person_3,
                size: 64,
                color: Colors.grey.shade400,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              isSearching ? 'Pencarian Tidak Ditemukan' : 'Tidak Ada Pengguna',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSearching 
                ? 'Coba kata kunci lain atau hapus filter'
                : 'Belum ada pengguna yang terdaftar di sistem',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (isSearching) ...[
              const SizedBox(height: 16),
              TextButton.icon(
                onPressed: () {
                  _searchController.clear();
                  ref.read(subscribersProvider.notifier).updateSearch('');
                  ref.read(subscribersProvider.notifier).updateExpiringFilter(false);
                  setState(() {});
                },
                icon: const Icon(CupertinoIcons.clear),
                label: const Text('Hapus Pencarian'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _showExtendDialog(BuildContext context, String userId) async {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              CupertinoIcons.time,
              color: Colors.blue.shade600,
            ),
            const SizedBox(width: 8),
            const Text('Perpanjang Subscription'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Masukkan jumlah hari untuk memperpanjang subscription pengguna ini:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Hari',
                hintText: 'Contoh: 30',
                prefixIcon: const Icon(CupertinoIcons.calendar),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Colors.blue.shade600, width: 2),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Subscription akan diperpanjang dari tanggal berakhir saat ini',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              final daysText = controller.text.trim();
              if (daysText.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Jumlah hari tidak boleh kosong'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              final days = int.tryParse(daysText);
              if (days == null || days <= 0) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Masukkan jumlah hari yang valid (lebih dari 0)'),
                    backgroundColor: Colors.orange,
                  ),
                );
                return;
              }

              Navigator.pop(context);
              
              final success = await ref.read(subscribersProvider.notifier)
                  .extendUserSubscription(userId, days);
              
              if (success) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Subscription berhasil diperpanjang $days hari'),
                    backgroundColor: Colors.green,
                  ),
                );
              } else {
                final error = ref.read(subscribersProvider).error;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(error ?? 'Gagal memperpanjang subscription'),
                    backgroundColor: Colors.red,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Perpanjang'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(BuildContext context, String userId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              color: Colors.red.shade600,
            ),
            const SizedBox(width: 8),
            const Text('Hapus Pengguna'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Apakah Anda yakin ingin menghapus pengguna ini?'),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(CupertinoIcons.info, color: Colors.red.shade600, size: 16),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Tindakan ini tidak dapat dibatalkan dan akan menghapus semua data pengguna',
                      style: TextStyle(fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Batal',
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
            ),
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
    
    if (confirmed == true) {
      final success = await ref.read(subscribersProvider.notifier).deleteUser(userId);
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pengguna berhasil dihapus'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        final error = ref.read(subscribersProvider).error;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error ?? 'Gagal menghapus pengguna'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}

class SubscriberCard extends StatelessWidget {
  final AdminSubscriber subscriber;
  final VoidCallback onTap;
  final Function(String) onExtend;
  final Function(String) onDelete;

  const SubscriberCard({
    Key? key,
    required this.subscriber,
    required this.onTap,
    required this.onExtend,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: Colors.red.shade100,
                        child: Text(
                          _getInitials(subscriber.name),
                          style: TextStyle(
                            color: Colors.red.shade600,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      if (subscriber.isExpiringSoon)
                        Positioned(
                          right: 0,
                          top: 0,
                          child: Container(
                            width: 14,
                            height: 14,
                            decoration: BoxDecoration(
                              color: Colors.orange.shade600,
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              CupertinoIcons.alarm,
                              size: 8,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          subscriber.name,
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subscriber.email,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (subscriber.businessName != null) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              subscriber.businessName!,
                              style: TextStyle(
                                color: Colors.blue.shade700,
                                fontSize: 11,
                                fontWeight: FontWeight.w500,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.chevron_right,
                        color: Colors.grey.shade400,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      PopupMenuButton<String>(
                        onSelected: (value) {
                          switch (value) {
                            case 'extend':
                              onExtend(subscriber.id);
                              break;
                            case 'delete':
                              onDelete(subscriber.id);
                              break;
                          }
                        },
                        itemBuilder: (context) => [
                          PopupMenuItem(
                            value: 'extend',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.time, size: 16, color: Colors.blue.shade600),
                                const SizedBox(width: 8),
                                const Text('Perpanjang'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(CupertinoIcons.trash, size: 16, color: Colors.red.shade600),
                                const SizedBox(width: 8),
                                const Text('Hapus'),
                              ],
                            ),
                          ),
                        ],
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          child: Icon(
                            CupertinoIcons.ellipsis_vertical,
                            color: Colors.grey.shade600,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              
              if (subscriber.currentSubscription != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primaryContainer.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.1),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: _getPackageColor(subscriber.currentSubscription!.package.name).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Icon(
                          CupertinoIcons.cube_box,
                          color: _getPackageColor(subscriber.currentSubscription!.package.name),
                          size: 16,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              subscriber.currentSubscription!.package.displayName,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Sisa ${subscriber.daysLeft} hari',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: subscriber.daysLeft <= 7 ? Colors.red : Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(subscriber.currentSubscription!.status),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          subscriber.currentSubscription!.status.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const SizedBox(height: 12),
              
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    _buildStatItem(
                      CupertinoIcons.building_2_fill,
                      subscriber.totalStores.toString(),
                      'Toko',
                      Colors.blue,
                    ),
                    const SizedBox(width: 12),
                    _buildStatItem(
                      CupertinoIcons.person_3_fill,
                      subscriber.totalMembers.toString(),
                      'Member',
                      Colors.green,
                    ),
                    const SizedBox(width: 12),
                    _buildStatItem(
                      CupertinoIcons.cube_box_fill,
                      subscriber.totalProducts.toString(),
                      'Produk',
                      Colors.orange,
                    ),
                    const Spacer(),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        'Tap untuk detail',
                        style: TextStyle(
                          fontSize: 10,
                          color: Colors.blue.shade700,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 14),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 11,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 9,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getInitials(String name) {
    if (name.isEmpty) return 'U';
    
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words.first[0].toUpperCase()}${words.last[0].toUpperCase()}';
    } else {
      return words.first.length >= 2 
          ? words.first.substring(0, 2).toUpperCase()
          : words.first[0].toUpperCase();
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'active':
        return Colors.green;
      case 'trial':
        return Colors.blue;
      case 'expired':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _getPackageColor(String packageName) {
    switch (packageName.toUpperCase()) {
      case 'STANDARD':
        return Colors.blue;
      case 'PRO':
        return Colors.orange;
      case 'BUSINESS':
        return Colors.purple;
      default:
        return Colors.grey;
    }
  }
}