import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentrig/models/tool_transaction_model.dart';
import 'package:rentrig/models/tools_model.dart';

abstract interface class IFirestoreService {
  Future<String> createTool(Tool tool);
  Stream<List<Tool>> getAllAvailableTools();
  Stream<Map<String, dynamic>?> getUserProfileStream(String uid);
  Stream<List<Tool>> getToolsByOwner(String ownerId);
  Future<Tool?> getToolById(String toolId);
  Future<void> updateTool(String toolId, Map<String, dynamic> data);
  Future<void> deleteTool(String toolId);
  Stream<List<Tool>> searchTools(String query);
  Future<String> createTransaction(ToolTransaction transaction);
  Stream<List<ToolTransaction>> getTransactionsByBorrower(String borrowerId);
  Stream<List<ToolTransaction>> getTransactionsByLender(String lenderId);
  Stream<List<ToolTransaction>> getPendingTransactionsByLender(String lenderId);
  Future<void> updateTransactionStatus(String transactionId, String status);
}

class FirestoreService implements IFirestoreService {
  final FirebaseFirestore _db;

  FirestoreService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  @override
  Future<String> createTool(Tool tool) async {
    try {
      final docRef = await _db.collection('tools').add(tool.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create tool: $e');
    }
  }

  @override
  Stream<List<Tool>> getAllAvailableTools() {
    return _db
        .collection('tools')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Tool.fromFirestore(doc)).toList());
  }

  @override
  Stream<Map<String, dynamic>?> getUserProfileStream(String uid) {
    return _db
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) => snapshot.data());
  }

  @override
  Stream<List<Tool>> getToolsByOwner(String ownerId) {
    return _db
        .collection('tools')
        .where('ownerId', isEqualTo: ownerId)
        .snapshots()
        .map((snapshot) {
      final tools = snapshot.docs.map((doc) => Tool.fromFirestore(doc)).toList();
      tools.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return tools;
    });
  }

  @override
  Future<Tool?> getToolById(String toolId) async {
    try {
      final doc = await _db.collection('tools').doc(toolId).get();
      if (doc.exists) {
        return Tool.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get tool: $e');
    }
  }

  @override
  Future<void> updateTool(String toolId, Map<String, dynamic> data) async {
    try {
      await _db.collection('tools').doc(toolId).update(data);
    } catch (e) {
      throw Exception('Failed to update tool: $e');
    }
  }

  @override
  Future<void> deleteTool(String toolId) async {
    try {
      await _db.collection('tools').doc(toolId).delete();
    } catch (e) {
      throw Exception('Failed to delete tool: $e');
    }
  }

  @override
  Stream<List<Tool>> searchTools(String query) {
    return _db
        .collection('tools')
        .where('isAvailable', isEqualTo: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Tool.fromFirestore(doc))
          .where((tool) =>
              tool.name.toLowerCase().contains(query.toLowerCase()) ||
              tool.category.toLowerCase().contains(query.toLowerCase()) ||
              tool.description.toLowerCase().contains(query.toLowerCase()))
          .toList();
    });
  }

  @override
  Future<String> createTransaction(ToolTransaction transaction) async {
    try {
      final docRef = await _db.collection('transactions').add(transaction.toMap());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create transaction: $e');
    }
  }

  @override
  Stream<List<ToolTransaction>> getTransactionsByBorrower(String borrowerId) {
    return _db
        .collection('transactions')
        .where('borrowerId', isEqualTo: borrowerId)
        .snapshots()
        .map((snapshot) {
      final txs = snapshot.docs.map((doc) => ToolTransaction.fromFirestore(doc)).toList();
      txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return txs;
    });
  }

  @override
  Stream<List<ToolTransaction>> getTransactionsByLender(String lenderId) {
    return _db
        .collection('transactions')
        .where('lenderId', isEqualTo: lenderId)
        .snapshots()
        .map((snapshot) {
      final txs = snapshot.docs.map((doc) => ToolTransaction.fromFirestore(doc)).toList();
      txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return txs;
    });
  }

  @override
  Stream<List<ToolTransaction>> getPendingTransactionsByLender(String lenderId) {
    return _db
        .collection('transactions')
        .where('lenderId', isEqualTo: lenderId)
        .snapshots()
        .map((snapshot) {
      final txs = snapshot.docs
          .map((doc) => ToolTransaction.fromFirestore(doc))
          .where((tx) => tx.status == 'pending')
          .toList();
      txs.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return txs;
    });
  }

  @override
  Future<void> updateTransactionStatus(String transactionId, String status) async {
    try {
      final docRef = _db.collection('transactions').doc(transactionId);
      final docSnap = await docRef.get();

      if (docSnap.exists) {
        final data = docSnap.data() as Map<String, dynamic>;
        final String? toolId = data['toolId'];

        await docRef.update({'status': status});

        if (toolId != null && toolId.isNotEmpty) {
          if (status == 'approved' || status == 'active') {
            await _db.collection('tools').doc(toolId).update({'isAvailable': false});
          } else if (status == 'completed' || status == 'rejected' || status == 'cancelled') {
            await _db.collection('tools').doc(toolId).update({'isAvailable': true});
          }
        }
      }
    } catch (e) {
      throw Exception('Failed to update transaction: $e');
    }
  }
}
