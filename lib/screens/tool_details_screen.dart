import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:rentrig/models/tool_transaction_model.dart';
import 'package:rentrig/models/tools_model.dart';
import 'package:rentrig/utils/app_colors.dart';
import 'package:rentrig/utils/responsive_util.dart';
import 'package:rentrig/widgets/condition_badge_widget.dart';
import 'package:rentrig/widgets/custom_action_button.dart';
import 'package:rentrig/widgets/date_picker_button_widget.dart';
import 'package:rentrig/widgets/owner_info_widget.dart';
import 'package:rentrig/widgets/trust_badge_widget.dart';
import '../services/firestore_service.dart';

class ToolDetailScreen extends StatefulWidget {
  final dynamic tool;

  const ToolDetailScreen({super.key, required this.tool});

  @override
  State<ToolDetailScreen> createState() => _ToolDetailScreenState();
}

class _ToolDetailScreenState extends State<ToolDetailScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  DateTime _selectedStartDate = DateTime.now();
  DateTime _selectedEndDate = DateTime.now().add(const Duration(days: 1));

  late Tool _tool;

  @override
  void initState() {
    super.initState();
    _tool = widget.tool as Tool;
  }

  int _calculateDays() {
    return _selectedEndDate.difference(_selectedStartDate).inDays;
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedStartDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedStartDate = picked;
        if (_selectedEndDate.isBefore(_selectedStartDate)) {
          _selectedEndDate = _selectedStartDate.add(const Duration(days: 1));
        }
      });
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedEndDate,
      firstDate: _selectedStartDate.add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      setState(() {
        _selectedEndDate = picked;
      });
    }
  }

  Future<void> _requestToBorrow() async {
    final currentUser = _auth.currentUser;

    if (currentUser == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please login first')),
      );
      return;
    }

    if (currentUser.uid == _tool.ownerId) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You cannot borrow your own tool')),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text(
          'Confirm Borrow Request',
          style: TextStyle(color: Colors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tool: ${_tool.name}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            const SizedBox(height: 8),
            Text(
              'Duration: ${_calculateDays()} days',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            Text(
              'From: ${DateFormat('MMM dd, yyyy').format(_selectedStartDate)}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
            ),
            Text(
              'To: ${DateFormat('MMM dd, yyyy').format(_selectedEndDate)}',
              style: TextStyle(color: Colors.white.withOpacity(0.8)),
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
              backgroundColor: AppColors.accent,
              foregroundColor: AppColors.background,
            ),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      final transaction = ToolTransaction(
        toolId: _tool.id!,
        toolName: _tool.name,
        borrowerId: currentUser.uid,
        borrowerEmail: currentUser.email ?? '',
        lenderId: _tool.ownerId,
        lenderEmail: _tool.ownerEmail,
        startDate: _selectedStartDate,
        endDate: _selectedEndDate,
        status: 'pending',
      );

      await _firestoreService.createTransaction(transaction);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Borrow request sent successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
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
    final isOwnTool = currentUser?.uid == _tool.ownerId;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppDecorations.darkAppBar(title: 'Tool Details'),
      body: AppDecorations.darkBody(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (_tool.imageUrl != null && _tool.imageUrl!.isNotEmpty)
                Container(
                  height: ResponsiveUtil.height(context, 25),
                  margin: EdgeInsets.all(ResponsiveUtil.padding(context, 16)),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    color: AppColors.surface,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Image.network(
                      _tool.imageUrl!,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: AppColors.surface,
                          child: Center(
                            child: Icon(
                              Icons.build,
                              size: ResponsiveUtil.iconSize(context, 80),
                              color: Colors.white.withOpacity(0.3),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              Container(
                margin: EdgeInsets.all(ResponsiveUtil.padding(context, 16)),
                padding: EdgeInsets.all(ResponsiveUtil.padding(context, 24)),
                decoration: AppDecorations.glassCard(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _tool.name,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(context, 28),
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: ResponsiveUtil.padding(context, 12),
                            vertical: ResponsiveUtil.padding(context, 6),
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.category,
                                size: ResponsiveUtil.iconSize(context, 16),
                                color: Colors.white.withOpacity(0.6),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                _tool.category,
                                style: TextStyle(
                                  color: Colors.white.withOpacity(0.7),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        ConditionBadge(condition: _tool.condition),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Description',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _tool.description,
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(context, 15),
                        color: Colors.white.withOpacity(0.6),
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Equipment Owner Trust Profile',
                      style: TextStyle(
                        fontSize: ResponsiveUtil.fontSize(context, 18),
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    OwnerInfo(ownerEmail: _tool.ownerEmail),
                    const SizedBox(height: 12),
                    TrustBadgeWidget(userId: _tool.ownerId),
                  ],
                ),
              ),
              if (!isOwnTool) ...[
                Container(
                  margin: EdgeInsets.symmetric(
                    horizontal: ResponsiveUtil.padding(context, 16),
                  ),
                  padding: EdgeInsets.all(ResponsiveUtil.padding(context, 16)),
                  decoration: AppDecorations.glassCard(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Select Rental Period',
                        style: TextStyle(
                          fontSize: ResponsiveUtil.fontSize(context, 18),
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DatePickerButton(
                              label: 'Start Date',
                              selectedDate: _selectedStartDate,
                              onPressed: _selectStartDate,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: DatePickerButton(
                              label: 'End Date',
                              selectedDate: _selectedEndDate,
                              onPressed: _selectEndDate,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding:
                            EdgeInsets.all(ResponsiveUtil.padding(context, 16)),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Duration',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.5),
                              ),
                            ),
                            Text(
                              '${_calculateDays()} days',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize:
                                    ResponsiveUtil.fontSize(context, 16),
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
              ],
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      bottomNavigationBar: !isOwnTool
          ? SafeArea(
              child: Padding(
                padding: EdgeInsets.all(ResponsiveUtil.padding(context, 16)),
                child: CustomActionButton(
                  label: 'Request to Borrow',
                  icon: Icons.shopping_bag,
                  onPressed: _requestToBorrow,
                ),
              ),
            )
          : null,
    );
  }
}
