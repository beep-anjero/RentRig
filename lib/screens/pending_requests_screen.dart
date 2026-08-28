import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rentrig/models/tool_transaction_model.dart';
import 'package:rentrig/services/firestore_service.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/widgets/empty_state_widget.dart';
import 'package:rentrig/widgets/pending_request_card_widget.dart';

class PendingRequestsScreen extends StatefulWidget {
  const PendingRequestsScreen({super.key});

  @override
  State<PendingRequestsScreen> createState() => _PendingRequestsScreenState();
}

class _PendingRequestsScreenState extends State<PendingRequestsScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> _handleRequest(
    ToolTransaction transaction,
    String action,
  ) async {
    final actionText = action == 'approved' ? 'approve' : 'reject';
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: Text(
          '${actionText[0].toUpperCase()}${actionText.substring(1)} Request',
          style: const TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tool: ${transaction.toolName}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Text(
              'Borrower: ${transaction.borrowerEmail}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Text(
              'From: ${DateFormat('MMM dd, yyyy').format(transaction.startDate)}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            Text(
              'To: ${DateFormat('MMM dd, yyyy').format(transaction.endDate ?? transaction.startDate)}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 12),
            Text(
              'Are you sure you want to $actionText this request?',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: Colors.white.withOpacity(0.9),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  action == 'approved' ? Colors.green : Colors.red,
            ),
            child: Text(
              actionText[0].toUpperCase() + actionText.substring(1),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _firestoreService.updateTransactionStatus(
        transaction.id!,
        action,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Request $action!'),
          backgroundColor: action == 'approved' ? Colors.green : Colors.orange,
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
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
        appBar: AppDecorations.darkAppBar(title: 'Pending Requests'),
        body: Center(
          child: Text(
            'Please login first',
            style: TextStyle(color: Colors.white.withOpacity(0.6)),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppDecorations.darkAppBar(title: 'Pending Requests'),
      body: AppDecorations.darkBody(
        child: StreamBuilder<List<ToolTransaction>>(
          stream:
              _firestoreService.getPendingTransactionsByLender(currentUser.uid),
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

            final transactions = snapshot.data ?? [];

            if (transactions.isEmpty) {
              return const EmptyState(
                icon: Icons.inbox,
                title: 'No Pending Requests',
                subtitle: 'You don\'t have any pending borrow requests',
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final transaction = transactions[index];

                return PendingRequestCard(
                  transaction: transaction,
                  onApprove: () => _handleRequest(transaction, 'approved'),
                  onReject: () => _handleRequest(transaction, 'rejected'),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
