import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentrig/models/tools_model.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/responsive_util.dart';
import 'package:rentrig/widgets/category_bar_widget.dart';
import 'package:rentrig/widgets/drawer_widget.dart';
import 'package:rentrig/widgets/empty_state_widget.dart';
import 'package:rentrig/widgets/search_bar_widget.dart';
import 'package:rentrig/widgets/tech_monogram_logo.dart';
import 'package:rentrig/widgets/tool_card_widget.dart';
import '../services/firestore_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';

  final List<String> _categories = [
    'All',
    'Cameras & Optics',
    'Audio & Sound',
    'VR & AR',
    'Drones & Robotics',
    'Laptops & Workstations',
    'Dev Kits & IoT',
    'Servers & Networking',
    '3D Printers',
    'Power & Batteries',
    'Tools & Machinery',
    'Other Tech',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _logout() async {
    await _auth.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/log_in');
    }
  }

  void _handleSearch(String value) {
    setState(() {
      _searchQuery = value;
    });
  }

  void _handleClearSearch() {
    setState(() {
      _searchController.clear();
      _searchQuery = '';
    });
  }

  void _handleCategoryChange(String category) {
    setState(() {
      _selectedCategory = category;
    });
  }

  List<Tool> _filterTools(List<Tool> tools) {
    List<Tool> filtered = tools;

    if (_selectedCategory != 'All') {
      filtered =
          filtered.where((t) => t.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered
          .where((t) =>
              t.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              t.category.toLowerCase().contains(_searchQuery.toLowerCase()))
          .toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        toolbarHeight: ResponsiveUtil.isMobile(context) ? 70 : 80,
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const TechMonogramLogo(
          size: 28,
          showText: true,
          isVertical: false,
        ),
        actions: [
          if (_auth.currentUser != null)
            StreamBuilder<Map<String, dynamic>?>(
              stream: _firestoreService.getUserProfileStream(_auth.currentUser!.uid),
              builder: (context, snapshot) {
                final userData = snapshot.data;
                final profileImageUrl = userData?['profileImageUrl'] as String?;
                final name = (userData?['name'] as String?) ?? _auth.currentUser?.email ?? 'U';
                final initial = name.isNotEmpty ? name[0].toUpperCase() : 'U';

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/profile');
                  },
                  child: Container(
                    margin: const EdgeInsets.only(right: 12),
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [AppColors.accent, AppColors.accentSecondary],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.accent.withOpacity(0.3),
                          blurRadius: 8,
                          spreadRadius: 1,
                        ),
                      ],
                    ),
                    child: CircleAvatar(
                      radius: ResponsiveUtil.iconSize(context, 18),
                      backgroundColor: AppColors.surface,
                      backgroundImage: profileImageUrl != null && profileImageUrl.isNotEmpty
                          ? NetworkImage(profileImageUrl)
                          : null,
                      child: profileImageUrl == null || profileImageUrl.isEmpty
                          ? Text(
                              initial,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: AppColors.accent,
                              ),
                            )
                          : null,
                    ),
                  ),
                );
              },
            )
          else
            IconButton(
              icon: const Icon(
                Icons.account_circle_outlined,
                color: Colors.white,
              ),
              iconSize: ResponsiveUtil.iconSize(context, 35),
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
            ),
          const SizedBox(width: 6),
        ],
      ),
      drawer: DrawerWidget(onLogout: _logout),
      body: AppDecorations.darkBody(
        child: Column(
          children: [
            SearchBarWidget(
              controller: _searchController,
              onChanged: _handleSearch,
              onClear: _handleClearSearch,
            ),
            CategoryBarWidget(
              categories: _categories,
              selectedCategory: _selectedCategory,
              onCategorySelected: _handleCategoryChange,
            ),
            Expanded(
              child: StreamBuilder<List<Tool>>(
                stream: _firestoreService.getAllAvailableTools(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(color: AppColors.accent),
                    );
                  }

                  if (snapshot.hasError) {
                    return EmptyState(
                      icon: Icons.error_outline,
                      title: 'Error loading tools',
                      subtitle: snapshot.error.toString(),
                    );
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const EmptyState(
                      icon: Icons.search_off,
                      title: 'No tools available',
                      subtitle: 'Be the first to add a tool!',
                    );
                  }

                  final filteredTools = _filterTools(snapshot.data!);

                  if (filteredTools.isEmpty) {
                    return const EmptyState(
                      icon: Icons.filter_alt_off,
                      title: 'No matching tools',
                      subtitle: 'Try adjusting your filters',
                    );
                  }

                  return ListView.builder(
                    padding:
                        EdgeInsets.all(ResponsiveUtil.padding(context, 16)),
                    itemCount: filteredTools.length,
                    itemBuilder: (context, index) {
                      final tool = filteredTools[index];
                      return ToolCardWidget(
                        tool: tool,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/tool_detail',
                            arguments: tool,
                          );
                        },
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/add_tool');
        },
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.background,
        icon: const Icon(Icons.add),
        label: const Text(
          'Add Tool',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
