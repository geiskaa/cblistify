import 'dart:io';
import 'dart:typed_data'; // Diperlukan untuk Uint8List
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter/foundation.dart'; 

class SupabaseService {
  // --- Upload Gambar dari File ---
  Future<String> uploadImage(File file, String bucketName, String fileName) async {
    try {
      // ✅ GANTI: Gunakan Supabase.instance.client untuk mendapatkan client.
      final supabase = Supabase.instance.client;

      // Baca file menjadi bytes.
      final bytes = await file.readAsBytes();

      // Upload bytes ke Supabase Storage.
      await supabase.storage.from(bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Ambil URL publik dari file yang baru diupload.
      final imageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);
      
      // Print URL di console untuk debugging.
      if (kDebugMode) {
        print("Upload berhasil. URL: $imageUrl");
      }
      
      return imageUrl;

    } catch (e) {
      // ✅ TAMBAHAN: Penanganan error yang lebih baik.
      if (kDebugMode) {
        print("Error saat upload gambar: $e");
      }
      // Lemparkan kembali error agar bisa ditangani di UI jika perlu.
      throw 'Gagal mengupload gambar. Silakan coba lagi.';
    }
  }

  // --- Upload Gambar dari Bytes (Uint8List) ---
  Future<String> uploadImageBytes(Uint8List bytes, String bucketName, String fileName) async {
    try {
      // ✅ GANTI: Gunakan Supabase.instance.client untuk mendapatkan client.
      final supabase = Supabase.instance.client;

      // Upload bytes langsung ke Supabase Storage.
      await supabase.storage.from(bucketName).uploadBinary(
            fileName,
            bytes,
            fileOptions: const FileOptions(cacheControl: '3600', upsert: false),
          );

      // Ambil URL publik dari file yang baru diupload.
      final imageUrl = supabase.storage.from(bucketName).getPublicUrl(fileName);

      if (kDebugMode) {
        print("Upload bytes berhasil. URL: $imageUrl");
      }

      return imageUrl;

    } catch (e) {
      // ✅ TAMBAHAN: Penanganan error yang lebih baik.
      if (kDebugMode) {
        print("Error saat upload bytes gambar: $e");
      }
      throw 'Gagal mengupload gambar. Silakan coba lagi.';
    }
  }
}
