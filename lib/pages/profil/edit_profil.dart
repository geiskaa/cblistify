import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';
import 'package:temaa/theme_pallete.dart';
import 'package:temaa/theme_notifier.dart';
import 'package:temaa/pages/profil/pangkas_foto.dart';

class EditProfilPage extends StatefulWidget {
  const EditProfilPage({super.key});

  @override
  State<EditProfilPage> createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  File? _imageFile;
  String? _avatarUrl;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = Supabase.instance.client.auth.currentUser;
    final response = await Supabase.instance.client
        .from('profiles')
        .select()
        .eq('id', user!.id)
        .single();

    setState(() {
      _usernameController.text = response['full_name'] ?? '';
      _emailController.text = user.email ?? '';
      _avatarUrl = response['avatar_url'];
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final palette = Provider.of<ThemeNotifier>(context, listen: false).palette;

      final cropped = await cropImage(
        imageFile: File(pickedFile.path),
        toolbarColor: palette.base,
        toolbarWidgetColor: palette.lighter,
      );

      if (cropped != null) {
        setState(() => _imageFile = cropped);
      }
    }
  }


  Future<String?> _uploadAvatar(File file) async {
    final userId = Supabase.instance.client.auth.currentUser!.id;
    final fileExt = file.path.split('.').last;
    final filePath = '$userId-${const Uuid().v4()}.$fileExt';

    final bytes = await file.readAsBytes();

    await Supabase.instance.client.storage
        .from('avatars')
        .uploadBinary(filePath, bytes, fileOptions: const FileOptions(upsert: true));

    final publicUrl = Supabase.instance.client.storage
        .from('avatars')
        .getPublicUrl(filePath);

    return publicUrl;
  }

  Future<void> _updateProfile() async {
    setState(() => _isLoading = true);

    final user = Supabase.instance.client.auth.currentUser;
    String? uploadedUrl;
    if (_imageFile != null) {
      uploadedUrl = await _uploadAvatar(_imageFile!);
    }

    await Supabase.instance.client.from('profiles').update({
      'full_name': _usernameController.text.trim(),
      if (uploadedUrl != null) 'avatar_url': uploadedUrl,
      'update_at': DateTime.now().toIso8601String(),
    }).eq('id', user!.id);

    if (_passwordController.text.isNotEmpty) {
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(password: _passwordController.text.trim()),
      );
    }

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Profil berhasil diperbarui')),
    );
    Navigator.pop(context, true);

  }

  @override
  Widget build(BuildContext context) {
    final palette = Provider.of<ThemeNotifier>(context).palette;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profil'),
        backgroundColor: palette.base,
        foregroundColor: palette.darker,
        elevation: 1,
      ),
      backgroundColor: palette.lighter,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 30),
              decoration: BoxDecoration(
                color: palette.base.withOpacity(0.2),
                borderRadius: const BorderRadius.vertical(bottom: Radius.circular(16)),
              ),
              child: Column(
                children: [
                  Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundImage: _imageFile != null
                            ? FileImage(_imageFile!)
                            : (_avatarUrl != null ? NetworkImage(_avatarUrl!) : null)
                                as ImageProvider?,
                        backgroundColor: Colors.white,
                        child: _avatarUrl == null && _imageFile == null
                            ? Icon(Icons.person, size: 50, color: palette.darker)
                            : null,
                      ),
                      Container(
                        decoration: BoxDecoration(
                          color: palette.lighter,
                          shape: BoxShape.circle,
                          border: Border.all(color: palette.base, width: 1),
                        ),
                        child: IconButton(
                          icon: Icon(Icons.camera_alt_outlined, color: palette.darker),
                          onPressed: _pickImage,
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text('Ubah Foto Profil', style: TextStyle(color: palette.darker)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  TextField(
                    controller: _usernameController,
                    decoration: InputDecoration(
                      labelText: 'Username',
                      labelStyle: TextStyle(color: palette.darker),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _emailController,
                    enabled: false,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      labelStyle: TextStyle(color: palette.darker),
                      border: const OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 20),
                  TextField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Kata Sandi Baru (opsional)',
                      hintText: 'Isi untuk mengganti password',
                      labelStyle: TextStyle(color: palette.darker),
                      border: const OutlineInputBorder(),
                      suffixIcon: Icon(Icons.lock, color: palette.darker),
                    ),
                  ),
                  const SizedBox(height: 30),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: palette.base,
                        foregroundColor: palette.lighter,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: _isLoading ? null : _updateProfile,
                      child: _isLoading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Update'),
                    ),
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}
