import 'package:flutter/material.dart';

class NoChatsWidget extends StatelessWidget {
  const NoChatsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Empty state icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FF),
              borderRadius: BorderRadius.circular(60),
            ),
            child: const Icon(
              Icons.chat_bubble_outline,
              size: 60,
              color: Color(0xFF4A8FFF),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'No chats yet',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1E),
            ),
          ),
          const SizedBox(height: 8),

          // Description
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 40.0),
            child: Text(
              'Start a conversation with your friends\nand colleagues',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Color(0xFF8E8E93),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 32),

          // Start Chat Button
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to new chat screen
            },
            icon: const Icon(Icons.add),
            label: const Text('Start a Chat'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A8FFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
