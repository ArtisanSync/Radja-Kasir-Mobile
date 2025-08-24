import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:kasir/models/subscription_model.dart';

class SubscriptionCard extends StatelessWidget {
  final UserSubscription? subscription;
  final VoidCallback onTap;

  const SubscriptionCard({
    Key? key,
    this.subscription,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasSubscription = subscription != null;
    final isExpiring = subscription?.isExpiring ?? false;
    final isExpired = subscription?.isExpired ?? false;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: hasSubscription
                ? (isExpired
                    ? [Colors.red.shade600, Colors.red.shade400]
                    : isExpiring
                        ? [Colors.orange.shade600, Colors.orange.shade400]
                        : [theme.colorScheme.primary, theme.colorScheme.primary.withOpacity(0.8)])
                : [Colors.grey.shade600, Colors.grey.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      hasSubscription ? 'Paket Aktif' : 'Belum Berlangganan',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.9),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      hasSubscription
                          ? subscription!.package.displayName
                          : 'Pilih Paket',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    hasSubscription
                        ? (isExpired
                            ? CupertinoIcons.exclamationmark_triangle
                            : CupertinoIcons.checkmark_seal_fill)
                        : CupertinoIcons.lock,
                    color: Colors.white,
                    size: 28,
                  ),
                ),
              ],
            ),
            
            if (hasSubscription) ...[
              const SizedBox(height: 20),
              
              // Status Badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isExpired
                          ? CupertinoIcons.xmark_circle
                          : isExpiring
                              ? CupertinoIcons.alarm
                              : CupertinoIcons.checkmark_circle,
                      color: Colors.white,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      isExpired
                          ? 'Kadaluarsa'
                          : isExpiring
                              ? 'Akan Berakhir'
                              : subscription!.status == 'TRIAL'
                                  ? 'Trial'
                                  : 'Aktif',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Subscription Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildDetailItem(
                    'Berakhir',
                    '${subscription!.endDate.day}/${subscription!.endDate.month}/${subscription!.endDate.year}',
                  ),
                  _buildDetailItem(
                    'Sisa Hari',
                    subscription!.daysLeft > 0 
                        ? '${subscription!.daysLeft} hari'
                        : 'Kadaluarsa',
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Features
              Row(
                children: [
                  _buildFeatureChip(
                    CupertinoIcons.building_2_fill,
                    '${subscription!.package.maxStores} Toko',
                  ),
                  const SizedBox(width: 8),
                  _buildFeatureChip(
                    CupertinoIcons.person_3_fill,
                    '${subscription!.package.maxMembers} Member',
                  ),
                ],
              ),
              
              // New User Promo Badge
              if (subscription!.isNewUserPromo) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.yellow.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.gift,
                        color: Colors.white,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Promo New User: ${subscription!.totalMonths} bulan akses',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ] else ...[
              const SizedBox(height: 40),
              const Center(
                child: Text(
                  'Tap untuk berlangganan',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            // Action Button
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  hasSubscription
                      ? (isExpired ? 'Perpanjang Sekarang' : 'Kelola Langganan')
                      : 'Mulai Berlangganan',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.9),
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Icon(
                  CupertinoIcons.chevron_right,
                  color: Colors.white.withOpacity(0.9),
                  size: 20,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: 12,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildFeatureChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
