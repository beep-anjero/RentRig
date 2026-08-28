import 'package:cloud_firestore/cloud_firestore.dart';

class ToolTransaction {
  final String? id;
  final String toolId;
  final String toolName;
  final String borrowerId;
  final String borrowerEmail;
  final String lenderId;
  final String lenderEmail;
  final DateTime startDate;
  final DateTime? endDate;
  final String status; // 'pending', 'approved', 'rejected', 'active', 'completed'
  final DateTime createdAt;

  ToolTransaction({
    this.id,
    required this.toolId,
    required this.toolName,
    required this.borrowerId,
    required this.borrowerEmail,
    required this.lenderId,
    required this.lenderEmail,
    required this.startDate,
    this.endDate,
    this.status = 'pending',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  Map<String, dynamic> toMap() {
    return {
      'toolId': toolId,
      'toolName': toolName,
      'borrowerId': borrowerId,
      'borrowerEmail': borrowerEmail,
      'lenderId': lenderId,
      'lenderEmail': lenderEmail,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': endDate != null ? Timestamp.fromDate(endDate!) : null,
      'status': status,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  factory ToolTransaction.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return ToolTransaction(
      id: doc.id,
      toolId: data['toolId'] ?? '',
      toolName: data['toolName'] ?? '',
      borrowerId: data['borrowerId'] ?? '',
      borrowerEmail: data['borrowerEmail'] ?? '',
      lenderId: data['lenderId'] ?? '',
      lenderEmail: data['lenderEmail'] ?? '',
      startDate: (data['startDate'] as Timestamp).toDate(),
      endDate: data['endDate'] != null 
          ? (data['endDate'] as Timestamp).toDate() 
          : null,
      status: data['status'] ?? 'pending',
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  ToolTransaction copyWith({
    String? id,
    String? toolId,
    String? toolName,
    String? borrowerId,
    String? borrowerEmail,
    String? lenderId,
    String? lenderEmail,
    DateTime? startDate,
    DateTime? endDate,
    String? status,
    DateTime? createdAt,
  }) {
    return ToolTransaction(
      id: id ?? this.id,
      toolId: toolId ?? this.toolId,
      toolName: toolName ?? this.toolName,
      borrowerId: borrowerId ?? this.borrowerId,
      borrowerEmail: borrowerEmail ?? this.borrowerEmail,
      lenderId: lenderId ?? this.lenderId,
      lenderEmail: lenderEmail ?? this.lenderEmail,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
