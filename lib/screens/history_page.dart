import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gap/gap.dart';
import 'package:lottie/lottie.dart';
import 'package:kasir/components/builder_menu.dart';
import 'package:kasir/components/nav_drawer.dart';
import 'package:kasir/components/modern_card.dart';
import 'package:kasir/components/modern_text_field.dart';
import 'package:kasir/helpers/currency_format.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final List<TransactionHistory> _history = [
    // Dummy data untuk testing
    TransactionHistory(
      id: '1',
      transactionNumber: 'TRX-20241216-001',
      date: DateTime.now().subtract(const Duration(hours: 2)),
      totalAmount: 150000,
      status: 'Berhasil',
      items: ['Produk A', 'Produk B'],
    ),
    TransactionHistory(
      id: '2',
      transactionNumber: 'TRX-20241216-002',
      date: DateTime.now().subtract(const Duration(hours: 5)),
      totalAmount: 250000,
      status: 'Berhasil',
      items: ['Produk C'],
    ),
  ];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadHistory() async {
    setState(() {
      _isLoading = true;
    });

    // TODO: Implement actual API call
    await Future.delayed(const Duration(seconds: 1));

    setState(() {
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.background,
      drawer: const NavDrawer(currentRoute: 'history'),
      appBar: AppBar(
        backgroundColor: theme.colorScheme.surface,
        elevation: 0,
        leading: const MenuBuilder(),
        title: Text(
          'History Transaksi',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w600,
            color: theme.colorScheme.onSurface,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _isLoading ? null : _loadHistory,
            icon: _isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        theme.colorScheme.onSurface,
                      ),
                    ),
                  )
                : Icon(
                    CupertinoIcons.refresh,
                    color: theme.colorScheme.onSurface,
                  ),
            tooltip: 'Refresh',
          ),
          const Gap(8),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: theme.colorScheme.surface,
            padding: const EdgeInsets.all(16),
            child: ModernSearchField(
              controller: _searchController,
              hint: 'Cari history transaksi...',
              onChanged: (value) {
                // TODO: Implement search
              },
              onClear: () {
                _searchController.clear();
                // TODO: Clear search and reload
              },
            ),
          ),
          
          Expanded(
            child: _buildHistoryList(context, theme),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, ThemeData theme) {
    if (_isLoading) {
      return _buildLoadingList();
    }

    if (_history.isEmpty) {
      return _buildEmptyState(context, theme);
    }

    return RefreshIndicator(
      onRefresh: _loadHistory,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _history.length,
        itemBuilder: (context, index) {
          return HistoryCard(
            history: _history[index],
            onTap: () {
              _showHistoryDetail(_history[index]);
            },
          );
        },
      ),
    );
  }

  Widget _buildLoadingList() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Lottie.asset(
            'assets/animations/Loading.json',
            width: 120,
            height: 120,
            fit: BoxFit.contain,
          ),
          const Gap(16),
          Text(
            'Memuat history...',
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
            Lottie.asset(
              'assets/animations/no data.json',
              width: 120,
              height: 120,
              fit: BoxFit.contain,
            ),
            const Gap(16),
            Text(
              'Belum Ada History',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              'History transaksi akan muncul disini setelah Anda melakukan transaksi',
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

  void _showHistoryDetail(TransactionHistory history) {
    showDialog(
      context: context,
      builder: (context) => HistoryDetailDialog(history: history),
    );
  }
}

// Transaction History Model - sama seperti sebelumnya
class TransactionHistory {
  final String? id;
  final String transactionNumber;
  final DateTime date;
  final double totalAmount;
  final String status;
  final List<String> items;

  const TransactionHistory({
    this.id,
    required this.transactionNumber,
    required this.date,
    required this.totalAmount,
    required this.status,
    required this.items,
  });
}

// History Card Component - sama seperti sebelumnya
class HistoryCard extends StatelessWidget {
  final TransactionHistory history;
  final VoidCallback onTap;

  const HistoryCard({
    Key? key,
    required this.history,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ModernCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: _getStatusColor(history.status, theme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: Icon(
                  CupertinoIcons.clock,
                  color: _getStatusColor(history.status, theme),
                  size: 24,
                ),
              ),
              const Gap(16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      history.transactionNumber,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      '${history.date.day}/${history.date.month}/${history.date.year} - ${history.date.hour}:${history.date.minute.toString().padLeft(2, '0')}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const Gap(4),
                    Text(
                      CurrencyFormat.formatCurrency(history.totalAmount),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const Gap(16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _getStatusColor(history.status, theme).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  history.status,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: _getStatusColor(history.status, theme),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getStatusColor(String status, ThemeData theme) {
    switch (status.toLowerCase()) {
      case 'success':
      case 'berhasil':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'failed':
      case 'gagal':
        return Colors.red;
      default:
        return theme.colorScheme.primary;
    }
  }
}

// History Detail Dialog - sama seperti sebelumnya
class HistoryDetailDialog extends StatelessWidget {
  final TransactionHistory history;

  const HistoryDetailDialog({
    Key? key,
    required this.history,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Detail Transaksi',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(CupertinoIcons.xmark),
                ),
              ],
            ),
            const Gap(16),
            
            _buildInfoRow(
              context,
              CupertinoIcons.number,
              'No. Transaksi',
              history.transactionNumber,
            ),
            
            _buildInfoRow(
              context,
              CupertinoIcons.calendar,
              'Tanggal',
              '${history.date.day}/${history.date.month}/${history.date.year}',
            ),
            
            _buildInfoRow(
              context,
              CupertinoIcons.clock,
              'Waktu',
              '${history.date.hour}:${history.date.minute.toString().padLeft(2, '0')}',
            ),
            
            _buildInfoRow(
              context,
              CupertinoIcons.money_dollar_circle,
              'Total',
              CurrencyFormat.formatCurrency(history.totalAmount),
            ),
            
            _buildInfoRow(
              context,
              CupertinoIcons.checkmark_seal,
              'Status',
              history.status,
            ),
            
            const Gap(24),
            
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Tutup'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String label, String value) {
    final theme = Theme.of(context);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const Gap(12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}