import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../main.dart';

class SupabaseService {
  // --- Upload Gambar ---
  Future<String> uploadImage(File file, String bucketName, String fileName) async {
    final bytes = await file.readAsBytes();
    await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  Future<String> uploadImageBytes(Uint8List bytes, String bucketName, String fileName) async {
    await supabase.storage.from(bucketName).uploadBinary(
      fileName,
      bytes,
      fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
    );
    return supabase.storage.from(bucketName).getPublicUrl(fileName);
  }

  // --- CRUD Notes ---
  Future<List<Map<String, dynamic>>> getNotes() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('notes')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false);
    return data;
  }

  Future<void> addNote({
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required String priority,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('notes').insert({
      'user_id': userId,
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'priority': priority,
    });
  }

  Future<void> updateNote({
    required int id,
    required String title,
    required String description,
    required DateTime startDate,
    required DateTime endDate,
    required String startTime,
    required String endTime,
    required String priority,
  }) async {
    final updates = {
      'title': title,
      'description': description,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate.toIso8601String(),
      'start_time': startTime,
      'end_time': endTime,
      'priority': priority,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await supabase.from('notes').update(updates).eq('id', id);
  }

  Future<void> deleteNote(int id) async {
    await supabase.from('notes').delete().eq('id', id);
  }

  // --- CRUD Categories ---
  Future<List<Map<String, dynamic>>> getCategories() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('categories')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: true);
    return data;
  }

  Future<void> addCategory({required String category}) async {
    final userId = supabase.auth.currentUser!.id;
    await supabase.from('categories').insert({
      'user_id': userId,
      'category': category,
    });
  }

  Future<void> deleteCategory(int id) async {
    await supabase.from('categories').delete().eq('id', id);
  }

  // --- Profil Pengguna ---
  Future<Map<String, dynamic>?> getProfile() async {
    final userId = supabase.auth.currentUser!.id;
    final data = await supabase.from('profiles').select().eq('id', userId).single();
    return data;
  }

  Future<void> updateProfile({
    required String username,
    String? avatarUrl,
  }) async {
    final userId = supabase.auth.currentUser!.id;
    final updates = {
      'id': userId,
      'username': username,
      'avatar_url': avatarUrl,
      'updated_at': DateTime.now().toIso8601String(),
    };
    await supabase.from('profiles').upsert(updates);
  }
}
