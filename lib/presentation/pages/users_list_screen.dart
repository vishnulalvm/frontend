import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/di/injection.dart';
import '../../domain/entities/user.dart';
import '../bloc/auth_bloc.dart';
import '../bloc/auth_state.dart';
import '../bloc/online_status_bloc.dart';
import '../bloc/online_status_state.dart';
import '../bloc/users_bloc.dart';
import '../bloc/users_event.dart';
import '../bloc/users_state.dart';
import 'chat_screen.dart';

class UsersListScreen extends StatefulWidget {
  const UsersListScreen({super.key});

  @override
  State<UsersListScreen> createState() => _UsersListScreenState();
}

class _UsersListScreenState extends State<UsersListScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
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

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider.value(
          value: Injection.usersBloc..add(const LoadAllUsersEvent()),
        ),
        BlocProvider.value(
          value: Injection.onlineStatusBloc,
        ),
      ],
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F5F7),
        appBar: AppBar(
          backgroundColor: const Color(0xFFF5F5F7),
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF1C1C1E)),
            onPressed: () => Navigator.pop(context),
          ),
          title: const Text(
            'All Users',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1C1C1E),
            ),
          ),
        ),
        body: BlocBuilder<UsersBloc, UsersState>(
          builder: (context, state) {
            if (state is UsersLoading) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF4A8FFF),
                ),
              );
            } else if (state is UsersError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 60,
                      color: Colors.red,
                    ),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8E8E93),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        context.read<UsersBloc>().add(
                              const LoadAllUsersEvent(forceRefresh: true),
                            );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4A8FFF),
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            } else if (state is AllUsersLoaded) {
              return Column(
                children: [
                  // Search Bar
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: TextField(
                      controller: _searchController,
                      onChanged: (query) {
                        context.read<UsersBloc>().add(SearchUsersEvent(query));
                      },
                      decoration: InputDecoration(
                        hintText: 'Search users...',
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
                                  context.read<UsersBloc>().add(
                                        const SearchUsersEvent(''),
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

                  // Users List
                  Expanded(
                    child: state.filteredUsers.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.people_outline,
                                  size: 80,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  state.searchQuery.isNotEmpty
                                      ? 'No users found'
                                      : 'No users available',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Color(0xFF8E8E93),
                                  ),
                                ),
                              ],
                            ),
                          )
                        : RefreshIndicator(
                            onRefresh: () async {
                              context.read<UsersBloc>().add(
                                    const LoadAllUsersEvent(forceRefresh: true),
                                  );
                            },
                            child: ListView.builder(
                              itemCount: state.filteredUsers.length,
                              itemBuilder: (context, index) {
                                final user = state.filteredUsers[index];
                                return _UserListItem(
                                  user: user,
                                  avatarColor: _getAvatarColor(index),
                                  initials: _getInitials(user.username),
                                  onTap: () async {
                                    // Select the user
                                    context.read<UsersBloc>().add(
                                          SelectUserEvent(user.id),
                                        );

                                    // Navigate to chat screen - use regular push so we can go back
                                    final authState = context.read<AuthBloc>().state;
                                    if (authState is AuthAuthenticated && context.mounted) {
                                      // Pop the users list screen first
                                      Navigator.pop(context);

                                      // Then push the chat screen
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
                                        Injection.usersBloc.add(LoadSelectedUsersEvent());
                                      }
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                  ),
                ],
              );
            }

            return const Center(child: Text('Something went wrong'));
          },
        ),
      ),
    );
  }
}

class _UserListItem extends StatelessWidget {
  final User user;
  final Color avatarColor;
  final String initials;
  final VoidCallback onTap;

  const _UserListItem({
    required this.user,
    required this.avatarColor,
    required this.initials,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 12,
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: avatarColor,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Center(
                    child: Text(
                      initials,
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
                  ),
                ],
              ),
            ),

            // Status Badge
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 8,
                vertical: 4,
              ),
              decoration: BoxDecoration(
                color: user.status.toLowerCase() == 'online'
                    ? const Color(0xFF34C759).withOpacity(0.1)
                    : const Color(0xFF8E8E93).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                user.status.toUpperCase(),
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: user.status.toLowerCase() == 'online'
                      ? const Color(0xFF34C759)
                      : const Color(0xFF8E8E93),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
