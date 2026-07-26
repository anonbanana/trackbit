import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../providers/sales_providers.dart';
import '../../../../core/constants/app_colors.dart';

class SalesPage extends ConsumerWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ordersAsync = ref.watch(ordersProvider);
    final today = DateTime.now();
    final dailyTotalAsync = ref.watch(dailySalesTotalProvider(today));

    return Scaffold(
      appBar: AppBar(title: const Text('Sales History')),
      body: Column(
        children: [
          dailyTotalAsync.when(
            data: (total) => Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Today\'s Sales',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.8),
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    NumberFormat.currency(
                      symbol: '\$',
                      decimalDigits: 2,
                    ).format(total),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    DateFormat('MMM dd, yyyy').format(today),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            loading: () => const SizedBox(height: 100),
            error: (_, __) => const SizedBox(height: 100),
          ),
          Expanded(
            child: ordersAsync.when(
              data: (orders) {
                if (orders.isEmpty) {
                  return const Center(child: Text('No sales yet'));
                }
                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: orders.length,
                  itemBuilder: (context, index) {
                    final order = orders[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _statusColor(
                            order.status,
                          ).withValues(alpha: 0.1),
                          child: Icon(
                            _statusIcon(order.status),
                            color: _statusColor(order.status),
                            size: 20,
                          ),
                        ),
                        title: Text(
                          order.orderNumber,
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                        subtitle: Text(
                          '${order.customerName ?? "Walk-in"} • ${order.itemCount} item(s)',
                          style: const TextStyle(fontSize: 12),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              NumberFormat.currency(
                                symbol: '\$',
                                decimalDigits: 2,
                              ).format(order.total),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            Text(
                              order.paymentMethod.toUpperCase(),
                              style: const TextStyle(fontSize: 10),
                            ),
                          ],
                        ),
                        onTap: () => _showOrderDetail(context, ref, order.id),
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }

  void _showOrderDetail(BuildContext context, WidgetRef ref, String orderId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => _OrderDetailSheet(orderId: orderId),
    );
  }

  Color _statusColor(String status) {
    switch (status) {
      case 'completed':
        return AppColors.success;
      case 'refunded':
        return AppColors.error;
      case 'cancelled':
        return const Color(0xFF94A3B8);
      default:
        return AppColors.info;
    }
  }

  IconData _statusIcon(String status) {
    switch (status) {
      case 'completed':
        return Icons.check_circle;
      case 'refunded':
        return Icons.replay;
      case 'cancelled':
        return Icons.cancel;
      default:
        return Icons.schedule;
    }
  }
}

class _OrderDetailSheet extends ConsumerWidget {
  final String orderId;
  const _OrderDetailSheet({required this.orderId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final detailAsync = ref.watch(orderDetailProvider(orderId));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return detailAsync.when(
          data: (detail) {
            if (detail == null)
              return const Center(child: Text('Order not found'));
            return Padding(
              padding: const EdgeInsets.all(16),
              child: ListView(
                controller: scrollController,
                children: [
                  Center(
                    child: Text(
                      detail.orderNumber,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      DateFormat('MMM dd, yyyy HH:mm').format(detail.createdAt),
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                  const Divider(height: 24),
                  if (detail.customerName != null) ...[
                    _InfoRow(label: 'Customer', value: detail.customerName!),
                    if (detail.customerPhone != null)
                      _InfoRow(label: 'Phone', value: detail.customerPhone!),
                  ],
                  _InfoRow(
                    label: 'Payment',
                    value: detail.paymentMethod.toUpperCase(),
                  ),
                  _InfoRow(label: 'Status', value: detail.status.toUpperCase()),
                  const Divider(height: 16),
                  Text('Items', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: 8),
                  ...detail.items.map(
                    (item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              item.productName,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ),
                          Text(
                            '${item.quantity.toStringAsFixed(0)} x ${NumberFormat.currency(symbol: '\$', decimalDigits: 2).format(item.unitPrice)}',
                            style: const TextStyle(fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            NumberFormat.currency(
                              symbol: '\$',
                              decimalDigits: 2,
                            ).format(item.subtotal),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const Divider(height: 16),
                  _InfoRow(
                    label: 'Subtotal',
                    value: NumberFormat.currency(
                      symbol: '\$',
                    ).format(detail.subtotal),
                  ),
                  if (detail.discount > 0)
                    _InfoRow(
                      label: 'Discount',
                      value:
                          '-${NumberFormat.currency(symbol: '\$').format(detail.discount)}',
                      color: AppColors.error,
                    ),
                  if (detail.tax > 0)
                    _InfoRow(
                      label: 'Tax',
                      value: NumberFormat.currency(
                        symbol: '\$',
                      ).format(detail.tax),
                    ),
                  const Divider(),
                  _InfoRow(
                    label: 'Total',
                    value: NumberFormat.currency(
                      symbol: '\$',
                    ).format(detail.total),
                    bold: true,
                    fontSize: 18,
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final bool bold;
  final double fontSize;
  final Color? color;

  const _InfoRow({
    required this.label,
    required this.value,
    this.bold = false,
    this.fontSize = 14,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              label,
              style: TextStyle(fontSize: fontSize, color: color),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            value,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
              fontSize: fontSize,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
