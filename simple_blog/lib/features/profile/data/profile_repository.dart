import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/core/constants/storage_constants.dart';
import 'package:simple_blog/features/profile/data/models/user_profile.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileRepository {
  final SupabaseClient _supabaseClient;

  const ProfileRepository(this._supabaseClient);

  Future<UserProfile> fetchCurrentProfile() async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to view your profile.');
    }

    final response = await _supabaseClient
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    if (response == null) {
      throw StateError('Your profile could not be found.');
    }

    return UserProfile.fromJson(response);
  }

  Future<UserProfile> updateDisplayName(String displayName) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException(
        'You must be signed in to update your profile.',
      );
    }

    final trimmedName = displayName.trim();

    if (trimmedName.length < 2) {
      throw const FormatException(
        'Display name must contain at least 2 characters.',
      );
    }

    if (trimmedName.length > 50) {
      throw const FormatException('Display name cannot exceed 50 characters.');
    }

    final response = await _supabaseClient
        .from('profiles')
        .update({
          'display_name': trimmedName,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', user.id)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }

  Future<UserProfile> uploadAvatar(XFile image) async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to update your avatar.');
    }

    final currentProfile = await fetchCurrentProfile();
    final bytes = await image.readAsBytes();

    if (bytes.length > 5 * 1024 * 1024) {
      throw const FormatException('Profile image cannot exceed 5 MB.');
    }

    final contentType = _contentTypeFor(image);
    final extension = _extensionFor(contentType);

    final fileName = '${DateTime.now().microsecondsSinceEpoch}.$extension';

    final storagePath = '${user.id}/$fileName';

    final bucket = _supabaseClient.storage.from(
      StorageConstants.profileImagesBucket,
    );

    await bucket.uploadBinary(
      storagePath,
      bytes,
      fileOptions: FileOptions(contentType: contentType, upsert: false),
    );

    try {
      final response = await _supabaseClient
          .from('profiles')
          .update({
            'avatar_url': bucket.getPublicUrl(storagePath),
            'avatar_storage_path': storagePath,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('id', user.id)
          .select()
          .single();

      final updatedProfile = UserProfile.fromJson(response);
      final oldPath = currentProfile.avatarStoragePath;

      if (oldPath != null && oldPath != storagePath) {
        try {
          await bucket.remove([oldPath]);
        } catch (_) {
          // The new avatar is already active.
          // The old orphan can be cleaned up later.
        }
      }

      return updatedProfile;
    } catch (_) {
      try {
        await bucket.remove([storagePath]);
      } catch (_) {
        // Preserve the original profile update error.
      }

      rethrow;
    }
  }

  String _contentTypeFor(XFile image) {
    final mimeType = image.mimeType?.toLowerCase();

    if (mimeType == 'image/jpeg' ||
        mimeType == 'image/png' ||
        mimeType == 'image/webp') {
      return mimeType!;
    }

    final fileName = image.name.toLowerCase();

    if (fileName.endsWith('.jpg') || fileName.endsWith('.jpeg')) {
      return 'image/jpeg';
    }

    if (fileName.endsWith('.png')) {
      return 'image/png';
    }

    if (fileName.endsWith('.webp')) {
      return 'image/webp';
    }

    throw const FormatException(
      'Only JPEG, PNG, and WebP images are supported.',
    );
  }

  String _extensionFor(String contentType) {
    return switch (contentType) {
      'image/jpeg' => 'jpg',
      'image/png' => 'png',
      'image/webp' => 'webp',
      _ => throw const FormatException('Unsupported image type.'),
    };
  }

  Future<UserProfile> deleteAvatar() async {
    final user = _supabaseClient.auth.currentUser;

    if (user == null) {
      throw const AuthException('You must be signed in to delete your avatar.');
    }

    final currentProfile = await fetchCurrentProfile();
    final storagePath = currentProfile.avatarStoragePath;

    if (storagePath != null) {
      final deletedFiles = await _supabaseClient.storage
          .from(StorageConstants.profileImagesBucket)
          .remove([storagePath]);

      if (deletedFiles.length != 1) {
        throw StateError(
          'The profile image could not be deleted from storage.',
        );
      }
    }

    final response = await _supabaseClient
        .from('profiles')
        .update({
          'avatar_url': null,
          'avatar_storage_path': null,
          'updated_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('id', user.id)
        .select()
        .single();

    return UserProfile.fromJson(response);
  }
}
