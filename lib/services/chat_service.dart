import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rentrig/models/chat_message_model.dart';

abstract interface class IChatService {
  Stream<List<ChatMessage>> streamMessages(String rentalId);
  Future<void> sendMessage(ChatMessage message);
}

class ChatService implements IChatService {
  final FirebaseFirestore _db;

  ChatService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  @override
  Stream<List<ChatMessage>> streamMessages(String rentalId) {
    return _db
        .collection('messages')
        .where('rentalId', isEqualTo: rentalId)
        .snapshots()
        .map((snapshot) {
      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
      messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      return messages;
    });
  }

  @override
  Future<void> sendMessage(ChatMessage message) async {
    try {
      await _db.collection('messages').add(message.toMap());
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }
}
