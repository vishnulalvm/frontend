import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Dummy chat data
  final List<ChatItem> _chats = [
    ChatItem(
      name: 'Alice Smith',
      message: 'Hey, are we still on for lunch?',
      time: '10:30 AM',
      avatar: 'AS',
      isOnline: true,
      unreadCount: 2,
    ),
    ChatItem(
      name: 'Bob Jones',
      message: 'Sent you the files for the review.',
      time: 'Yesterday',
      avatar: 'BJ',
      isOnline: false,
      hasCheckmark: true,
    ),
    ChatItem(
      name: 'Charlie Brown',
      message: 'Thanks! I\'ll take a look later.',
      time: 'Tuesday',
      avatar: 'CB',
      isOnline: false,
      hasCheckmark: true,
    ),
    ChatItem(
      name: 'Diana Prince',
      message: 'Can you send the meeting link?',
      time: 'Mon',
      avatar: 'DP',
      isOnline: true,
    ),
    ChatItem(
      name: 'Ethan Hunt',
      message: 'Mission accomplished.',
      time: 'Oct 24',
      avatar: 'EH',
      isOnline: false,
      hasCheckmark: true,
      isDoubleCheck: true,
    ),
    ChatItem(
      name: 'Fiona Gallagher',
      message: 'Did you see the new update?',
      time: 'Oct 21',
      avatar: 'FG',
      isOnline: false,
    ),
    ChatItem(
      name: 'George Miller',
      message: 'Sounds good to me!',
      time: 'Oct 19',
      avatar: 'GM',
      isOnline: false,
      hasCheckmark: true,
    ),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F7),
      body: SafeArea(
        child: Column(
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chats',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1C1C1E),
                    ),
                  ),
                  Stack(
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: BoxDecoration(
                          color: const Color(0xFFFF9068),
                          borderRadius: BorderRadius.circular(25),
                        ),
                        child: const Center(
                          child: Text(
                            'U',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        right: 2,
                        child: Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: const Color(0xFF34C759),
                            border: Border.all(
                              color: const Color(0xFFF5F5F7),
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(7),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search conversations...',
                  hintStyle: const TextStyle(
                    color: Color(0xFFC7C7CC),
                    fontSize: 16,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: Color(0xFFC7C7CC),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Chat List
            Expanded(
              child: ListView.builder(
                itemCount: _chats.length,
                itemBuilder: (context, index) {
                  final chat = _chats[index];
                  return InkWell(
                    onTap: () {
                      // TODO: Navigate to chat screen
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      child: Row(
                        children: [
                          // Avatar with online indicator
                          Stack(
                            children: [
                              Container(
                                width: 60,
                                height: 60,
                                decoration: BoxDecoration(
                                  color: _getAvatarColor(index),
                                  borderRadius: BorderRadius.circular(30),
                                ),
                                child: Center(
                                  child: Text(
                                    chat.avatar,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ),
                              if (chat.isOnline)
                                Positioned(
                                  bottom: 2,
                                  right: 2,
                                  child: Container(
                                    width: 14,
                                    height: 14,
                                    decoration: BoxDecoration(
                                      color: const Color(0xFF34C759),
                                      border: Border.all(
                                        color: const Color(0xFFF5F5F7),
                                        width: 2,
                                      ),
                                      borderRadius: BorderRadius.circular(7),
                                    ),
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(width: 12),

                          // Chat Info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      chat.name,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Color(0xFF1C1C1E),
                                      ),
                                    ),
                                    Text(
                                      chat.time,
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: chat.unreadCount > 0
                                            ? const Color(0xFF4A8FFF)
                                            : const Color(0xFF8E8E93),
                                        fontWeight: chat.unreadCount > 0
                                            ? FontWeight.w600
                                            : FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Text(
                                        chat.message,
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF8E8E93),
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    if (chat.unreadCount > 0)
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 8,
                                          vertical: 4,
                                        ),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFF4A8FFF),
                                          borderRadius:
                                              BorderRadius.circular(12),
                                        ),
                                        child: Text(
                                          chat.unreadCount.toString(),
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      )
                                    else if (chat.hasCheckmark)
                                      Icon(
                                        chat.isDoubleCheck
                                            ? Icons.done_all
                                            : Icons.check,
                                        size: 16,
                                        color: const Color(0xFF4A8FFF),
                                      ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),

      // Floating Action Button
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to new chat screen
        },
        backgroundColor: const Color(0xFF4A8FFF),
        child: const Icon(
          Icons.edit,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getAvatarColor(int index) {
    final colors = [
      const Color(0xFF8B4513),
      const Color(0xFF4A5568),
      const Color(0xFFFFA500),
      const Color(0xFFFF9068),
      const Color(0xFF6B7280),
      const Color(0xFF9C6644),
      const Color(0xFF708090),
    ];
    return colors[index % colors.length];
  }
}

class ChatItem {
  final String name;
  final String message;
  final String time;
  final String avatar;
  final bool isOnline;
  final int unreadCount;
  final bool hasCheckmark;
  final bool isDoubleCheck;

  ChatItem({
    required this.name,
    required this.message,
    required this.time,
    required this.avatar,
    this.isOnline = false,
    this.unreadCount = 0,
    this.hasCheckmark = false,
    this.isDoubleCheck = false,
  });
}
