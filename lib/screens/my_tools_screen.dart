import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:rentrig/models/tools_model.dart';
import 'package:rentrig/services/firestore_service.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/widgets/custom_action_button.dart';
import 'package:rentrig/widgets/empty_state_widget.dart';
import 'package:rentrig/widgets/my_tool_card_widget.dart';

class MyToolsScreen extends StatefulWidget {
  const MyToolsScreen({super.key});

  @override
  State<MyToolsScreen> createState() => _MyToolsScreenState();
}

class _MyToolsScreenState extends State<MyToolsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _deleteTool(String toolId, String toolName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('Delete Tool', style: TextStyle(color: Colors.white)),
        content: Text(
          'Are you sure you want to delete "$toolName"?',
          style: TextStyle(color: Colors.white.withOpacity(0.7)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestoreService.deleteTool(toolId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tool deleted successfully'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting tool: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _toggleAvailability(Tool tool) async {
    try {
      await _firestoreService.updateTool(
        tool.id!,
        {'isAvailable': !tool.isAvailable},
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            tool.isAvailable
                ? 'Tool marked as unavailable'
                : 'Tool marked as available',
          ),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error updating tool: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppDecorations.darkAppBar(title: 'My Tools'),
        body: Center(
          child: Text(
            'Please login to view your tools',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppDecorations.darkAppBar(title: 'My Tools'),
      body: AppDecorations.darkBody(
        child: StreamBuilder<List<Tool>>(
          stream: _firestoreService.getToolsByOwner(currentUser.uid),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.accent),
              );
            }

            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: TextStyle(color: Colors.white.withOpacity(0.7)),
                ),
              );
            }

            final tools = snapshot.data ?? [];

            if (tools.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const EmptyState(
                      icon: Icons.construction_outlined,
                      title: 'No tools listed yet',
                      subtitle: 'Tap the button below to add your first tool',
                    ),
                    const SizedBox(height: 24),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 48),
                      child: CustomActionButton(
                        label: 'Add Tool',
                        icon: Icons.add,
                        onPressed: () {
                          Navigator.pushNamed(context, '/add_tool');
                        },
                      ),
                    ),
                  ],
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return MyToolCard(
                  tool: tool,
                  onToggleAvailability: () => _toggleAvailability(tool),
                  onDelete: () => _deleteTool(tool.id!, tool.name),
                );
              },
            );
          },
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
