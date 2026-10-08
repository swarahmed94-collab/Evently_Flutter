import 'package:cloud_firestore/cloud_firestore.dart';
import 'event_category.dart';

class EventModel {
  final String id;
  final String ownerId;
  final String title;
  final String description;
  final EventCategory category;
  final DateTime dateTime;
  final DateTime createdAt;
  final DateTime updatedAt;

  const EventModel({required this.id, required this.ownerId, required this.title, required this.description, required this.category, required this.dateTime, required this.createdAt, required this.updatedAt});

  factory EventModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    DateTime parse(dynamic value) => value is Timestamp ? value.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
    return EventModel(
      id: doc.id,
      ownerId: (data['ownerId'] as String?) ?? '',
      title: (data['title'] as String?) ?? '',
      description: (data['description'] as String?) ?? '',
      category: EventCategoryX.fromKey(data['category'] as String?),
      dateTime: parse(data['dateTime']),
      createdAt: parse(data['createdAt']),
      updatedAt: parse(data['updatedAt']),
    );
  }

  Map<String, dynamic> toFirestore() => {
    'ownerId': ownerId,
    'title': title.trim(),
    'description': description.trim(),
    'category': category.key,
    'dateTime': Timestamp.fromDate(dateTime),
    'createdAt': Timestamp.fromDate(createdAt),
    'updatedAt': Timestamp.fromDate(updatedAt),
  };
}
