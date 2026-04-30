import 'package:flutter/material.dart';
import '../../models/product_model.dart';
import '../../screens/product_detail_screen.dart';
import '../../services/api_service.dart'; // ✅ add this

class ChatBubble extends StatelessWidget {
  final ChatMessage message;

  const ChatBubble({super.key, required this.message});

  bool get isUser => message.role == 'user';

  // ✅ Fetch full product by slug then navigate
  Future<void> _navigateToProduct(
    BuildContext context,
    RagProduct ragProduct,
  ) async {
    if (ragProduct.productUrlSlug == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(
        child: CircularProgressIndicator(color: Color(0xFFBB4E2C)),
      ),
    );

    try {
      // Fetch full product using slug from your existing API service
      final Product? product = await ApiService().fetchProductBySlug(
        ragProduct.productUrlSlug!,
      );

      if (context.mounted) Navigator.pop(context); // dismiss loading

      if (product != null && context.mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ProductDetailScreen(product: product),
          ),
        );
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Product not found'),
              backgroundColor: Color(0xFFBB4E2C),
            ),
          );
        }
      }
    } catch (e) {
      if (context.mounted) Navigator.pop(context); // dismiss loading
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to load product'),
            backgroundColor: Color(0xFFBB4E2C),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: isUser
          ? CrossAxisAlignment.end
          : CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 4, left: 4, right: 4),
          child: Text(
            isUser ? 'You' : 'Genie',
            style: TextStyle(
              fontSize: 10,
              letterSpacing: 1.5,
              fontWeight: FontWeight.bold,
              color: isUser
                  ? const Color(0xFF1a3126).withOpacity(0.5)
                  : const Color(0xFFBB4E2C),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: isUser ? const Color(0xFF1a3126) : Colors.white,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isUser ? 16 : 4),
              bottomRight: Radius.circular(isUser ? 4 : 16),
            ),
            border: isUser ? null : Border.all(color: const Color(0xFFF2F0E5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                message.content,
                style: TextStyle(
                  fontSize: 14,
                  color: isUser
                      ? const Color(0xFFF2F0E5)
                      : const Color(0xFF1a3126),
                ),
              ),
              if (!isUser && message.products.isNotEmpty) ...[
                const SizedBox(height: 12),
                const Divider(color: Color(0xFFF2F0E5)),
                const SizedBox(height: 8),
                Text(
                  'CURATED SELECTION (${message.products.length})',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                    color: Color(0xFFBB4E2C),
                  ),
                ),
                const SizedBox(height: 8),
                ...message.products
                    .map(
                      (p) => _ProductCard(
                        product: p,
                        onTap: () => _navigateToProduct(context, p),
                      ),
                    )
                    .toList(),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ProductCard extends StatelessWidget {
  final RagProduct product;
  final VoidCallback onTap;

  const _ProductCard({required this.product, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, // ✅ uses the callback
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: const Color(0xFFF9F8F6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFFE4E0D0)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    product.productName,
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 15,
                      color: Color(0xFF1a3126),
                    ),
                  ),
                ),
                if (product.score != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1a3126),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${(product.score! * 100).toStringAsFixed(0)}% MATCH',
                      style: const TextStyle(
                        fontSize: 9,
                        color: Color(0xFFF2F0E5),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            if (product.shortDescription != null) ...[
              const SizedBox(height: 4),
              Text(
                product.shortDescription!,
                style: TextStyle(
                  fontSize: 12,
                  color: const Color(0xFF1a3126).withOpacity(0.6),
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                if (product.price != null)
                  _tag(
                    'Rs ${product.price!.toStringAsFixed(0)}',
                    color: const Color(0xFFBB4E2C),
                  ),
                if (product.colors.isNotEmpty)
                  _tag('Colors: ${product.colors.join(', ')}'),
                if (product.category != null)
                  _tag(product.category!, italic: true),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  'View product →',
                  style: TextStyle(
                    fontSize: 11,
                    color: const Color(0xFFBB4E2C).withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _tag(String text, {Color? color, bool italic = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: const Color(0xFF1a3126).withOpacity(0.1)),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          color: color ?? const Color(0xFF1a3126).withOpacity(0.6),
          fontStyle: italic ? FontStyle.italic : FontStyle.normal,
          fontWeight: color != null ? FontWeight.w600 : FontWeight.normal,
        ),
      ),
    );
  }
}
