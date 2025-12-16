import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/online_status_bloc.dart';
import '../bloc/online_status_state.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';
import '../widgets/profile_dialog.dart';
import 'chat_screen.dart';
import 'users_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with WidgetsBindingObserver {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounceTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _searchController.addListener(() {
      setState(() {}); // Update UI when text changes for clear button
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    _searchController.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Reload selected users when app comes to foreground
      context.read<UsersBloc>().add(LoadSelectedUsersEvent());
    }
  }

  void _onSearchChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Create new timer for debouncing
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      Injection.usersBloc.add(SearchSelectedUsersEvent(query));
    });
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: Injection.usersBloc..add(LoadSelectedUsersEvent()),
        ),
        BlocProvider.value(
          value: Injection.onlineStatusBloc,
        ),
      ],
      child: Scaffold(
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
                  GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => const ProfileDialog(),
                      );
                    },
                    child: Stack(
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
                  ),
                ],
              ),
            ),

            // Search Bar
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
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
                  suffixIcon: _searchController.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(
                            Icons.clear,
                            color: Color(0xFFC7C7CC),
                          ),
                          onPressed: () {
                            _searchController.clear();
                            _debounceTimer?.cancel();
                            Injection.usersBloc.add(
                                  const SearchSelectedUsersEvent(''),
                                );
                          },
                        )
                      : null,
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
              child: BlocBuilder<UsersBloc, UsersState>(
                buildWhen: (previous, current) {
                  print('🏗️ BlocBuilder buildWhen: ${previous.runtimeType} -> ${current.runtimeType}');
                  if (current is SelectedUsersLoaded) {
                    print('   Filtered count: ${current.filteredUsers.length}');
                  }
                  // Rebuild whenever state changes
                  return true;
                },
                builder: (context, state) {
                  print('🎨 BlocBuilder rebuild with state: ${state.runtimeType}');
                  if (state is SelectedUsersLoaded) {
                    print('   Showing ${state.filteredUsers.length} of ${state.users.length} users');
                  }

                  if (state is UsersLoading) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF4A8FFF),
                      ),
                    );
                  } else if (state is SelectedUsersLoaded) {
                    if (state.users.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.chat_bubble_outline,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No conversations yet',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Start a chat by selecting users',
                              style: TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const UsersListScreen(),
                                  ),
                                );
                                // Reload selected users after returning
                                if (context.mounted) {
                                  context.read<UsersBloc>().add(LoadSelectedUsersEvent());
                                }
                              },
                              icon: const Icon(Icons.person_add),
                              label: const Text('Browse Users'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF4A8FFF),
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 24,
                                  vertical: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    if (state.filteredUsers.isEmpty && state.searchQuery.isNotEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.search_off,
                              size: 80,
                              color: Colors.grey[300],
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No conversations found',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w600,
                                color: Color(0xFF1C1C1E),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'No matches for "${state.searchQuery}"',
                              style: const TextStyle(
                                fontSize: 14,
                                color: Color(0xFF8E8E93),
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return RefreshIndicator(
                      onRefresh: () async {
                        context.read<UsersBloc>().add(LoadSelectedUsersEvent());
                      },
                      child: ListView.builder(
                        itemCount: state.filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = state.filteredUsers[index];
                          return InkWell(
                            onTap: () async {
                              final authState = context.read<AuthBloc>().state;
                              if (authState is AuthAuthenticated) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ChatScreen(
                                      receiver: user,
                                      token: authState.user.token,
                                    ),
                                  ),
                                );
                                // Reload selected users after returning from chat
                                if (context.mounted) {
                                  context.read<UsersBloc>().add(LoadSelectedUsersEvent());
                                }
                              }
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
                                            _getInitials(user.username),
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                      ),
                                      BlocBuilder<OnlineStatusBloc, OnlineStatusState>(
                                        builder: (context, onlineState) {
                                          final isOnline = onlineState.isUserOnline(user.id);
                                          return isOnline
                                              ? Positioned(
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
                                                )
                                              : const SizedBox.shrink();
                                        },
                                      ),
                                    ],
                                  ),
                                  const SizedBox(width: 12),

                                  // User Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.username,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            color: Color(0xFF1C1C1E),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          user.email,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            color: Color(0xFF8E8E93),
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Status Badge
                                  Icon(
                                    Icons.chevron_right,
                                    color: Colors.grey[400],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }

                  return const Center(
                    child: Text('Something went wrong'),
                  );
                },
              ),
            ),
            ],
          ),
        ),

        // Floating Action Button
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UsersListScreen(),
              ),
            );
            // Reload selected users after returning
            if (context.mounted) {
              context.read<UsersBloc>().add(LoadSelectedUsersEvent());
            }
          },
          backgroundColor: const Color(0xFF4A8FFF),
          child: const Icon(
            Icons.person_add,
            color: Colors.white,
          ),
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
      const Color(0xFF4A8FFF),
    ];
    return colors[index % colors.length];
  }
}
