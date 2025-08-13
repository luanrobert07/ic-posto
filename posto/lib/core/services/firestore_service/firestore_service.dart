import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:posto/core/services/firestore_service/firestore_pagination.dart';

class FirestoreService {
  final FirebaseFirestore db = FirebaseFirestore.instance;
  final FirestorePagination pagination = FirestorePagination();

  Future<DocumentReference<Object?>?> add<T>(CollectionReference collection, T data) async {
    try {
      final ref = await collection.add(data as Map<String, dynamic>);
      print('Added successfully');
      return ref;
    } catch (e) {
      print('Error adding: $e');
    }
    return null;
  }

  Future<void> addAll<T>(
    CollectionReference collection,
    List<T> items,
    Map<String, dynamic> Function(T) toMap, [
    Transaction? transaction,
  ]) async {

    if (transaction != null) {
      // In a transaction: do not use batch
      for (final item in items) {
        transaction.set(collection.doc(), toMap(item));
      }
      return;
    }

    const batchSize = 500;
    final total = items.length;
    for (var i = 0; i < total; i += batchSize) {
      final batch = FirebaseFirestore.instance.batch();

      final batchItems = items.sublist(i, (i + batchSize > total) ? total : i + batchSize);

      for (final item in batchItems) {
        batch.set(collection.doc(), toMap(item));
      }

      try {
        await batch.commit();
        print('Batch added successfully: items ${i + 1} to ${i + batchItems.length}');
      } catch (e) {
        print('Error adding batch: $e');
      }
    }
  }

  Future<T?> get<T>(CollectionReference collection, String docId, FutureOr<T> Function(String, Map<String, dynamic>) fromJson) async {
    try {
      DocumentSnapshot doc = await collection.doc(docId).get();
      if (doc.exists) {
        print('Got document successfully');
        return fromJson(doc.id, doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      print('Error getting document: $e');
    }
    return null;
  }

  Future<List<T>> getAll<T>(CollectionReference collection, FutureOr<T> Function(String, Map<String, dynamic>) fromJson) async {
    try {
      QuerySnapshot querySnapshot = await collection.get();
      final futures = querySnapshot.docs.map((doc) {
        final result = fromJson(doc.id, doc.data() as Map<String, dynamic>);
        return result is Future<T> ? result : Future.value(result);
      });

      print('Got documents successfully');
      return Future.wait(futures);
    } catch (e, stackTrace) {
      print('Error getting documents: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> set(DocumentReference document, Map<String, dynamic> data, {bool merge = false}) async {
    try {
      await document.set(data, SetOptions(merge: merge));
      print('Set document successfully');
    } catch (e) {
      print('Error updating: $e');
    }
  }

  Future<void> delete(CollectionReference collection, String docId) async {
    try {
      await collection.doc(docId).delete();
      print('Deleted successfully');
    } catch (e) {
      print('Error deleting: $e');
    }
  }
}
