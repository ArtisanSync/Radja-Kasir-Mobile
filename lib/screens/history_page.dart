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
import 'package:kasir/models/transaction_model.dart';
import 'package:kasir/services/transaction_services.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({Key? key}) : super(key: key);

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

// Transaction History Provider
final transactionHistoryProvider =
    StateNotifierProvider<TransactionHistoryNotifier, TransactionHistoryState>(
        (ref) {
  return TransactionHistoryNotifier();
});

class TransactionHistoryState {
  final List<TransactionModel> transactions;
  final TransactionPagination? pagination;
  final bool isLoading;
  final bool isLoadingMore;
  final String? error;
  final String searchQuery;
  final String? paymentMethodFilter;
  final DateTime? startDateFilter;
  final DateTime? endDateFilter;

  const TransactionHistoryState({
    this.transactions = const [],
    this.pagination,
    this.isLoading = false,
    this.isLoadingMore = false,
    this.error,
    this.searchQuery = '',
    this.paymentMethodFilter,
    this.startDateFilter,
    this.endDateFilter,
  });

  TransactionHistoryState copyWith({
    List<TransactionModel>? transactions,
    TransactionPagination? pagination,
    bool? isLoading,
    bool? isLoadingMore,
    String? error,
    String? searchQuery,
    String? paymentMethodFilter,
    DateTime? startDateFilter,
    DateTime? endDateFilter,
  }) {
    return TransactionHistoryState(
      transactions: transactions ?? this.transactions,
      pagination: pagination ?? this.pagination,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      error: error,
      searchQuery: searchQuery ?? this.searchQuery,
      paymentMethodFilter: paymentMethodFilter ?? this.paymentMethodFilter,
      startDateFilter: startDateFilter ?? this.startDateFilter,
      endDateFilter: endDateFilter ?? this.endDateFilter,
    );
  }
}

class TransactionHistoryNotifier
    extends StateNotifier<TransactionHistoryState> {
  final TransactionServices _transactionServices = TransactionServices();

  TransactionHistoryNotifier() : super(const TransactionHistoryState());

  Future<void> loadTransactions({
    bool refresh = false,
    String? search,
    String? paymentMethod,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    if (refresh) {
      state = state.copyWith(
        transactions: [],
        pagination: null,
        searchQuery: search ?? '',
        paymentMethodFilter: paymentMethod,
        startDateFilter: startDate,
        endDateFilter: endDate,
      );
    }

    final currentPage = refresh ? 1 : (state.pagination?.currentPage ?? 0) + 1;

    state = state.copyWith(
      isLoading: refresh || currentPage == 1,
      isLoadingMore: !refresh && currentPage > 1,
      error: null,
    );

    try {
      final result = await _transactionServices.getTransactionHistory(
        page: currentPage,
        search: state.searchQuery.isEmpty ? null : state.searchQuery,
        paymentMethod: state.paymentMethodFilter,
        startDate: state.startDateFilter,
        endDate: state.endDateFilter,
      );

      if (result['success'] == true) {
        final transactionData = result['data'] as List? ?? [];

        final newTransactions = <TransactionModel>[];
        for (int i = 0; i < transactionData.length; i++) {
          try {
            final transaction = TransactionModel.fromJson(transactionData[i]);
            newTransactions.add(transaction);
          } catch (e) {}
        }

        final pagination = result['pagination'] != null
            ? TransactionPagination.fromJson(result['pagination'])
            : null;

        final updatedTransactions = refresh
            ? newTransactions
            : [...state.transactions, ...newTransactions];

        state = state.copyWith(
          transactions: updatedTransactions,
          pagination: pagination,
          isLoading: false,
          isLoadingMore: false,
        );
      } else {
        state = state.copyWith(
          error: result['message'] ?? 'Failed to load transactions',
          isLoading: false,
          isLoadingMore: false,
        );
      }
    } catch (e) {
      state = state.copyWith(
        error: 'Network error occurred',
        isLoading: false,
        isLoadingMore: false,
      );
    }
  }

  Future<void> searchTransactions(String query) async {
    await loadTransactions(refresh: true, search: query);
  }

  Future<void> filterByPaymentMethod(String? paymentMethod) async {
    await loadTransactions(refresh: true, paymentMethod: paymentMethod);
  }

  Future<void> filterByDateRange(DateTime? startDate, DateTime? endDate) async {
    await loadTransactions(
        refresh: true, startDate: startDate, endDate: endDate);
  }

  Future<void> loadMore() async {
    if (state.pagination?.hasNextPage == true && !state.isLoadingMore) {
      await loadTransactions();
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  Future<void> refresh() async {
    await loadTransactions(refresh: true);
  }
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref
          .read(transactionHistoryProvider.notifier)
          .loadTransactions(refresh: true);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent * 0.8) {
      ref.read(transactionHistoryProvider.notifier).loadMore();
    }
  }

  Future<void> _onSearch(String query) async {
    await ref
        .read(transactionHistoryProvider.notifier)
        .searchTransactions(query);
  }

  Future<void> _onRefresh() async {
    await ref.read(transactionHistoryProvider.notifier).refresh();
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
          Consumer(
            builder: (context, ref, child) {
              final historyState = ref.watch(transactionHistoryProvider);
              return IconButton(
                onPressed: historyState.isLoading ? null : _onRefresh,
                icon: historyState.isLoading
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
              );
            },
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
                if (value.isEmpty) {
                  _onSearch('');
                }
              },
              onSubmitted: _onSearch,
              onClear: () {
                _searchController.clear();
                _onSearch('');
              },
            ),
          ),
          Expanded(
            child: Consumer(
              builder: (context, ref, child) {
                final historyState = ref.watch(transactionHistoryProvider);
                return _buildHistoryList(context, theme, historyState);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryList(BuildContext context, ThemeData theme,
      TransactionHistoryState historyState) {
    if (historyState.error != null) {
      return _buildErrorState(context, theme, historyState.error!);
    }

    if (historyState.isLoading && historyState.transactions.isEmpty) {
      return _buildLoadingList();
    }

    if (historyState.transactions.isEmpty && !historyState.isLoading) {
      return _buildEmptyState(context, theme);
    }

    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        itemCount: historyState.transactions.length +
            (historyState.isLoadingMore ? 1 : 0),
        itemBuilder: (context, index) {
          if (index >= historyState.transactions.length) {
            return const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: CircularProgressIndicator(),
              ),
            );
          }

          final transaction = historyState.transactions[index];
          return TransactionHistoryCard(
            transaction: transaction,
            onTap: () {
              _showTransactionDetail(transaction);
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
            const Gap(16),
            Text(
              'Terjadi Kesalahan',
              style: theme.textTheme.headlineSmall?.copyWith(
                color: theme.colorScheme.error,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Gap(8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const Gap(24),
            ElevatedButton(
              onPressed: _onRefresh,
              child: const Text('Coba Lagi'),
            ),
          ],
        ),
      ),
    );
  }

  void _showTransactionDetail(TransactionModel transaction) {
    showDialog(
      context: context,
      builder: (context) => TransactionDetailDialog(transaction: transaction),
    );
  }
}

// Transaction History Card Widget
class TransactionHistoryCard extends StatelessWidget {
  final TransactionModel transaction;
  final VoidCallback onTap;

  const TransactionHistoryCard({
    super.key,
    required this.transaction,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ModernCard(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          transaction.transactionNumber ?? 'No Invoice',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Gap(4),
                        Text(
                          _formatDate(transaction.createdAt),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        CurrencyFormat.formatCurrency(transaction.totalAmount),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                      const Gap(4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: _getStatusColor(transaction.status)
                              .withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          _getStatusText(transaction.status),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: _getStatusColor(transaction.status),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const Gap(12),
              Row(
                children: [
                  Icon(
                    CupertinoIcons.creditcard,
                    size: 16,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const Gap(6),
                  Text(
                    transaction.paymentInfo?.method ?? 'Unknown',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    '${transaction.items.length} item${transaction.items.length > 1 ? 's' : ''}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Hari ini ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      return 'Kemarin ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} hari lalu';
    } else {
      return '${date.day}/${date.month}/${date.year}';
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
      case 'berhasil':
        return Colors.green;
      case 'pending':
      case 'menunggu':
        return Colors.orange;
      case 'failed':
      case 'gagal':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Berhasil';
      case 'pending':
        return 'Menunggu';
      case 'failed':
        return 'Gagal';
      default:
        return status;
    }
  }
}

// Dialog untuk detail transaksi
class TransactionDetailDialog extends StatelessWidget {
  final TransactionModel transaction;

  const TransactionDetailDialog({
    super.key,
    required this.transaction,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(CupertinoIcons.xmark),
                  ),
                ],
              ),
              const Gap(16),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildDetailRow(
                          'No. Invoice', transaction.transactionNumber, theme),
                      _buildDetailRow('Tanggal',
                          _formatFullDate(transaction.createdAt), theme),
                      _buildDetailRow(
                          'Status', _getStatusText(transaction.status), theme),
                      _buildDetailRow('Metode Bayar',
                          transaction.paymentInfo?.method ?? '-', theme),
                      if (transaction.customerInfo != null) ...[
                        _buildDetailRow(
                            'Customer', transaction.customerInfo!.name, theme),
                        if (transaction.customerInfo!.phone.isNotEmpty)
                          _buildDetailRow('Telepon',
                              transaction.customerInfo!.phone, theme),
                      ],
                      const Gap(16),
                      Text(
                        'Items:',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Gap(8),
                      ...transaction.items.map((item) => Container(
                            margin: const EdgeInsets.only(bottom: 8),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: theme.colorScheme.surfaceVariant
                                  .withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        item.productName,
                                        style: theme.textTheme.bodyMedium
                                            ?.copyWith(
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        '${item.quantity} x ${CurrencyFormat.formatCurrency(item.price)}',
                                        style:
                                            theme.textTheme.bodySmall?.copyWith(
                                          color: theme
                                              .colorScheme.onSurfaceVariant,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                Text(
                                  CurrencyFormat.formatCurrency(
                                      item.totalPrice),
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )),
                      const Gap(16),
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primaryContainer
                              .withOpacity(0.3),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow(
                                'Subtotal',
                                CurrencyFormat.formatCurrency(
                                    transaction.totalAmount),
                                theme),
                            const Divider(),
                            _buildSummaryRow(
                              'Total',
                              CurrencyFormat.formatCurrency(
                                  transaction.totalAmount),
                              theme,
                              isTotal: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const Gap(16),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Tutup'),
                    ),
                  ),
                  const Gap(12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // TODO: Implement print functionality
                        Navigator.of(context).pop();
                      },
                      child: const Text('Print'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          const Text(': '),
          Expanded(
            child: Text(
              value,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, ThemeData theme,
      {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal
                  ? theme.colorScheme.primary
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: isTotal ? theme.colorScheme.primary : null,
            ),
          ),
        ],
      ),
    );
  }

  String _formatFullDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  String _getStatusText(String status) {
    switch (status.toLowerCase()) {
      case 'completed':
        return 'Berhasil';
      case 'pending':
        return 'Menunggu';
      case 'failed':
        return 'Gagal';
      default:
        return status;
    }
  }
}
