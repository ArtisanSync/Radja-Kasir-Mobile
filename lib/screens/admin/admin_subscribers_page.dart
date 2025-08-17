import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/providers/admin_providers.dart';
import 'package:kasir/models/admin_models.dart';

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
    return Container(
      color: theme.colorScheme.surface,
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Cari pengguna...',
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
              ),
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
                  label: const Text('Akan Berakhir'),
                  selected: state.expiringOnlyFilter,
                  onSelected: (selected) {
                    ref.read(subscribersProvider.notifier).updateExpiringFilter(selected);
                  },
                  backgroundColor: Colors.red.shade50,
                  selectedColor: Colors.red.shade100,
                  checkmarkColor: Colors.red.shade600,
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
      return _buildEmptyState(context, theme);
    }

    return RefreshIndicator(
      onRefresh: () async {
        await ref.read(subscribersProvider.notifier).loadSubscribers();
      },
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredSubscribers.length,
        itemBuilder: (context, index) {
          return SubscriberCard(
            subscriber: filteredSubscribers[index],
            onExtend: (userId) => _showExtendDialog(context, userId),
            onDelete: (userId) => _showDeleteDialog(context, userId),
          );
        },
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
          Text('Memuat pengguna...'),
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
            Icon(
              CupertinoIcons.exclamationmark_triangle,
              size: 64,
              color: theme.colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Terjadi Kesalahan',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
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
            ElevatedButton(
              onPressed: () {
                ref.read(subscribersProvider.notifier).loadSubscribers();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red.shade600,
                foregroundColor: Colors.white,
              ),
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.person_3,
              size: 64,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Tidak Ada Pengguna',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Belum ada pengguna yang terdaftar',
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
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
        title: const Text('Perpanjang Subscription'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Masukkan jumlah hari untuk memperpanjang subscription:'),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Jumlah Hari',
                prefixIcon: const Icon(CupertinoIcons.calendar),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () async {
              final days = int.tryParse(controller.text);
              if (days != null && days > 0) {
                Navigator.pop(context);
                final success = await ref.read(subscribersProvider.notifier)
                    .extendUserSubscription(userId, days);
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Subscription berhasil diperpanjang'),
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
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
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
        title: const Text('Hapus Pengguna'),
        content: const Text('Apakah Anda yakin ingin menghapus pengguna ini? Tindakan ini tidak dapat dibatalkan.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Batal'),
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
  final Function(String) onExtend;
  final Function(String) onDelete;

  const SubscriberCard({
    Key? key,
    required this.subscriber,
    required this.onExtend,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.shade100,
                  child: Text(
                    _getInitials(subscriber.name),
                    style: TextStyle(
                      color: Colors.red.shade600,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
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
                      ),
                      Text(
                        subscriber.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (subscriber.businessName != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subscriber.businessName!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.blue.shade600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (subscriber.isExpiringSoon)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.shade100,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Akan Berakhir',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            if (subscriber.currentSubscription != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          CupertinoIcons.checkmark_seal,
                          color: Colors.green.shade600,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          subscriber.currentSubscription!.package.displayName,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _getStatusColor(subscriber.currentSubscription!.status),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: Text(
                            subscriber.currentSubscription!.status,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Berakhir: ${_formatDate(subscriber.currentSubscription!.endDate)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    Text(
                      'Sisa: ${subscriber.daysLeft} hari',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: subscriber.daysLeft <= 7 ? Colors.red : Colors.green,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
            
            Row(
              children: [
                Expanded(
                  child: Row(
                    children: [
                      _buildStatItem(
                        CupertinoIcons.building_2_fill,
                        subscriber.totalStores.toString(),
                        'Toko',
                        Colors.blue,
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        CupertinoIcons.person_3_fill,
                        subscriber.totalMembers.toString(),
                        'Member',
                        Colors.green,
                      ),
                      const SizedBox(width: 16),
                      _buildStatItem(
                        CupertinoIcons.cube_box_fill,
                        subscriber.totalProducts.toString(),
                        'Produk',
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Row(
                  children: [
                    IconButton(
                      onPressed: () => onExtend(subscriber.id),
                      icon: Icon(
                        CupertinoIcons.time,
                        color: Colors.blue.shade600,
                        size: 20,
                      ),
                      tooltip: 'Perpanjang Subscription',
                    ),
                    IconButton(
                      onPressed: () => onDelete(subscriber.id),
                      icon: Icon(
                        CupertinoIcons.trash,
                        color: Colors.red.shade600,
                        size: 20,
                      ),
                      tooltip: 'Hapus Pengguna',
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 16),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
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

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
