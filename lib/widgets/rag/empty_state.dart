import 'package:flutter/material.dart';

class RagEmptyState extends StatelessWidget {
  const RagEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF1a3126).withOpacity(0.05),
              shape: BoxShape.circle,
            ),
            child: const Center(
              child: Text('🛋️', style: TextStyle(fontSize: 28)),
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Start the conversation to get curated picks.',
            style: TextStyle(fontSize: 13, color: Color(0xFF1a3126)),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
