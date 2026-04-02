import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/order_provider.dart';
import '../constants.dart';
import '../providers/auth_provider.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final userId = auth.user?.id;
    // Fetch orders when screen opens
    if (userId != null) {
      // 🔥 We checked it's NOT null, so now it's safe to pass as a String
      Future.microtask(() =>
          Provider.of<OrderProvider>(context, listen: false).fetchUserOrders(
              userId)
      );
    }
  }

  void _showCancelDialog(BuildContext context, OrderProvider provider, String orderId) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        title: const Text("Cancel Order?"),
        content: const Text("Are you sure you want to cancel this order? This action cannot be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("No", style: TextStyle(color: Colors.grey))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              bool success = await provider.cancelOrder(orderId);
              if (success && mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Order cancelled successfully"), backgroundColor: Colors.green),
                );
              } else if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text("Failed to cancel order"), backgroundColor: Colors.red),
                );
              }
            },
            child: const Text("Yes, Cancel", style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orderProvider = Provider.of<OrderProvider>(context);

    return Scaffold(
      backgroundColor: AppColors.backgroundOffWhite,
      appBar: AppBar(
        title: const Text("My Orders", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: orderProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryGreen))
          : orderProvider.userOrders.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
        onRefresh: () async {
          final auth = Provider.of<AuthProvider>(context, listen: false);
          final String? userId = auth.user?.id;

          if (userId != null) {
            await orderProvider.fetchUserOrders(userId);
          } else {
            // Optional: Show a message if user session is lost
            debugPrint("Session lost: Cannot refresh orders.");
          }
        },
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: orderProvider.userOrders.length,
          itemBuilder: (context, index) {
            final order = orderProvider.userOrders[index];
            return _buildOrderCard(order);
          },
        ),
      ),
    );
  }

  Widget _buildOrderCard(Map<String, dynamic> order) {
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);
    final status = order['orderStatus'] ?? 'pending';
    final String orderId = order['id']; // Ensure you have the document ID

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Order #${order['id'].toString().substring(0, 8)}",
                // Using ID snippet
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16),
              ),
              _buildStatusChip(status),
            ],
          ),
          const Divider(height: 24),
          Row(
            children: [
              const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
              const SizedBox(width: 4),
              Text(
                order['createdAt'].toString().substring(0, 10),
                style: const TextStyle(color: Colors.grey, fontSize: 13),
              ),
              const Spacer(),
              const Text("Total: ", style: TextStyle(color: Colors.grey)),
              Text(
                "Rs. ${order['total']}",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: AppColors.accentOrange),
              ),
            ],
          ),

          // 🔥 ADD THIS SECTION BELOW 🔥
          if (status.toLowerCase() == 'pending' ||
              status.toLowerCase() == 'paid') ...[
            const SizedBox(height: 12),
            const Divider(),
            SizedBox(
              width: double.infinity,
              child: TextButton.icon(
                onPressed: () =>
                    _showCancelDialog(context, orderProvider, orderId),
                icon: const Icon(
                    Icons.cancel_outlined, color: Colors.red, size: 18),
                label: const Text(
                  "Cancel Order",
                  style: TextStyle(
                      color: Colors.red, fontWeight: FontWeight.w600),
                ),
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  backgroundColor: Colors.red.withOpacity(0.05),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
  Widget _buildStatusChip(String status) {
    Color color;
    // Convert to lowercase to avoid "Pending" vs "pending" issues
    switch (status.toLowerCase()) {
      case 'delivered':
        color = Colors.green;
        break;
      case 'shipped':
        color = Colors.blue;
        break;
      case 'processing':
      case 'pending': // Added pending to show orange/yellow
      case 'paid':
        color = Colors.orange;
        break;
      case 'canceled': // Backend version (one 'L')
      case 'cancelled': // Frontend version (two 'Ls')
        color = Colors.red;
        break;
      default:
        color = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.shopping_bag_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          const Text("No orders found", style: TextStyle(color: Colors.grey, fontSize: 18)),
        ],
      ),
    );
  }
}