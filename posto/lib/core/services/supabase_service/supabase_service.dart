import 'dart:async';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient client = Supabase.instance.client;

  Future<Map<String, dynamic>?> get(String table, String id) async {
    try {
      final response = await client
          .from(table)
          .select()
          .eq('id', id)
          .maybeSingle();

      print('Got document successfully');
      return response;
    } catch (e) {
      print('Error getting document: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getAll(String table, {String? orderBy}) async {
    try {
      var query = client.from(table).select();

      if (orderBy != null) {
        query = query.order(orderBy);
      }

      final response = await query;
      print('Got documents successfully');
      return List<Map<String, dynamic>>.from(response);
    } catch (e, stackTrace) {
      print('Error getting documents: $e');
      print('Stack trace: $stackTrace');
      return [];
    }
  }

  Future<void> insert(String table, Map<String, dynamic> data) async {
    try {
      await client.from(table).insert(data);
      print('Inserted successfully');
    } catch (e) {
      print('Error inserting: $e');
      rethrow;
    }
  }

  Future<void> update(String table, String id, Map<String, dynamic> data) async {
    try {
      await client.from(table).update(data).eq('id', id);
      print('Updated successfully');
    } catch (e) {
      print('Error updating: $e');
      rethrow;
    }
  }

  Future<void> delete(String table, String id) async {
    try {
      await client.from(table).delete().eq('id', id);
      print('Deleted successfully');
    } catch (e) {
      print('Error deleting: $e');
      rethrow;
    }
  }

  Stream<List<Map<String, dynamic>>> streamTable(String table, {String? orderBy}) {
    return client
        .from(table)
        .stream(primaryKey: ['id'])
        .order(orderBy ?? 'created_at');
  }

  Stream<Map<String, dynamic>?> streamDocument(String table, String id) {
    return client
        .from(table)
        .stream(primaryKey: ['id'])
        .eq('id', id)
        .map((list) => list.isEmpty ? null : list.first);
  }

  Future<List<Map<String, dynamic>>> query(
    String table, {
    String? column,
    dynamic value,
    int? limit,
    String? orderBy,
    bool ascending = true,
  }) async {
    try {
      var query = client.from(table).select();

      if (column != null && value != null) {
        query = query.eq(column, value);
      }

      if (orderBy != null) {
        query = query.order(orderBy, ascending: ascending);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query;
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error querying: $e');
      return [];
    }
  }
}
