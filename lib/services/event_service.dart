import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/event_model.dart';
import '../models/event_category.dart';

class EventService {
  EventService._();
  static final EventService instance = EventService._();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _events => _db.collection('events');
  CollectionReference<Map<String, dynamic>> _favorites(String uid) => _db.collection('users').doc(uid).collection('favorites');

  Stream<List<EventModel>> watchEvents({EventCategory? category}) {
    Query<Map<String, dynamic>> query = _events;
    if (category != null) query = query.where('category', isEqualTo: category.key);
    return query.snapshots().map((snap) {
      final list = snap.docs.map(EventModel.fromFirestore).toList();
      list.sort((a, b) => a.dateTime.compareTo(b.dateTime));
      return list;
    });
  }

  Stream<Set<String>> watchFavoriteIds(String userId) => _favorites(userId)
      .snapshots().map((snap) => snap.docs.map((d) => d.id).toSet());

  Future<String> add({required String userId, required String title, required String description, required EventCategory category, required DateTime dateTime}) async {
    final ref = _events.doc();
    final now = DateTime.now();
    await ref.set(EventModel(id: ref.id, ownerId: userId, title: title, description: description, category: category, dateTime: dateTime, createdAt: now, updatedAt: now).toFirestore());
    return ref.id;
  }

  Future<void> update(EventModel event, {required String userId, required String title, required String description, required EventCategory category, required DateTime dateTime}) async {
    if (event.ownerId != userId) throw StateError('You can edit only your events.');
    await _events.doc(event.id).update({
      'title': title.trim(),
      'description': description.trim(),
      'category': category.key,
      'dateTime': Timestamp.fromDate(dateTime),
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  Future<void> delete(EventModel event, String userId) async {
    if (event.ownerId != userId) throw StateError('You can delete only your events.');
    final batch = _db.batch();
    batch.delete(_events.doc(event.id));
    batch.delete(_favorites(userId).doc(event.id));
    await batch.commit();
  }

  Future<void> setFavorite({required String userId, required String eventId, required bool favorite}) async {
    final ref = _favorites(userId).doc(eventId);
    if (favorite) {
      await ref.set({'eventId': eventId, 'createdAt': FieldValue.serverTimestamp()});
    } else {
      await ref.delete();
    }
  }
}
