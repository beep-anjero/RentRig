import 'package:cloud_firestore/cloud_firestore.dart';

class Tool {
  final String? id;
  final String ownerId;
  final String ownerEmail;
  final String name;
  final String category;
  final String description;
  final String condition;
  final String? imageUrl;
  final bool isAvailable;
  final DateTime createdAt;

  Tool({
    this.id,
    required this.ownerId,
    required this.ownerEmail,
    required this.name,
    required this.category,
    required this.description,
    required this.condition,
    this.imageUrl,
    this.isAvailable = true,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();


  Map<String, dynamic> toMap() {
    return {
      'ownerId': ownerId,
      'ownerEmail': ownerEmail,
      'name': name,
      'category': category,
      'description': description,
      'condition': condition,
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }


  factory Tool.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    return Tool(
      id: doc.id,
      ownerId: data['ownerId'] ?? '',
      ownerEmail: data['ownerEmail'] ?? '',
      name: data['name'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      condition: data['condition'] ?? '',
      imageUrl: data['imageUrl'],
      isAvailable: data['isAvailable'] ?? true,
      createdAt: (data['createdAt'] as Timestamp).toDate(),
    );
  }

  Tool copyWith({
    String? id,
    String? ownerId,
    String? ownerEmail,
    String? name,
    String? category,
    String? description,
    String? condition,
    String? imageUrl,
    bool? isAvailable,
    DateTime? createdAt,
  }) {
    return Tool(
      id: id ?? this.id,
      ownerId: ownerId ?? this.ownerId,
      ownerEmail: ownerEmail ?? this.ownerEmail,
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      condition: condition ?? this.condition,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
