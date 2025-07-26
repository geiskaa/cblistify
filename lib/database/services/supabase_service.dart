import 'dart:io';
import 'dart:typed_data'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; 

class SupabaseService {
  Future<String> uploadImage(File file, String bucketName, String fileName) async {
    try {
      final supabase = Supabase.instance.client;
      final bytes = await file.readAsBytes();

      await supabase.storage.from(bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
      if (kDebugMode) {
        print("Upload berhasil. URL: $imageUrl");
      }
      
      return imageUrl;

    } catch (e) {
      if (kDebugMode) {
        print("Error saat upload gambar: $e");
      }
      throw 'Gagal mengupload gambar. Silakan coba lagi.';
    }
  }

  Future<String> uploadImageBytes(Uint8List bytes, String bucketName, String fileName) async {
    try {
      final supabase = Supabase.instance.client;
      await supabase.storage.from(bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      final imageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);

      if (kDebugMode) {
        print("Upload bytes berhasil. URL: $imageUrl");
      }

      return imageUrl;

    } catch (e) {
      if (kDebugMode) {
        print("Error saat upload bytes gambar: $e");
      }
      throw 'Gagal mengupload gambar. Silakan coba lagi.';
    }
  }
}
