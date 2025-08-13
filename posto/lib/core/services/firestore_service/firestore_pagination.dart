import 'package:cloud_firestore/cloud_firestore.dart';

class FirestorePagination {
  final Map<String, DocumentSnapshot> _lastLoadedItem = {};
  static const int pageSize = 10;

  Future<List<T>> loadItems<T>(
      Query query,
      String id,
      T Function(String id, Map<String, dynamic> data) fromMap, {
        int limit = pageSize,
      }) async {
    print('Loading items with pagination for id $id');

    if (_lastLoadedItem.containsKey(id)) {
      final lastDoc = _lastLoadedItem[id];
      if (lastDoc != null) {
        query = query.startAfterDocument(lastDoc);
      }
    }

    final querySnapshot = await query
        .limit(limit)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      _lastLoadedItem[id] = querySnapshot.docs.last;
    }

    return querySnapshot.docs.map((doc) => fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
  }

  Stream<List<T>> streamItems<T>(
      Query query,
      String id,
      T Function(String id, Map<String, dynamic> data) fromMap, {
        int limit = pageSize,
      }) {
    print('Streaming items with pagination for id $id');

    return query
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty && !_lastLoadedItem.containsKey(id)) {
            _lastLoadedItem[id] = snapshot.docs.last;
          }

          return snapshot.docs.map((doc) => fromMap(doc.id, doc.data() as Map<String, dynamic>)).toList();
        });
  }

  void reset(String id) {
    _lastLoadedItem.remove(id);
  }
}
