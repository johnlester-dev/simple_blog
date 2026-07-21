import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:simple_blog/features/profile/data/models/user_profile.dart';
import 'package:simple_blog/features/profile/data/profile_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class ProfileProvider extends ChangeNotifier {
  final ProfileRepository _profileRepository;

  ProfileProvider(this._profileRepository);

  UserProfile? _profile;
  bool _isLoading = false;
  bool _isSaving = false;
  String? _errorMessage;

  UserProfile? get profile => _profile;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  final ImagePicker _imagePicker = ImagePicker();

  Future<void> loadProfile() async {
    if (_isLoading) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.fetchCurrentProfile();
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } catch (_) {
      _errorMessage = 'Unable to load your profile.';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateDisplayName(String displayName) async {
    if (_isSaving) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.updateDisplayName(displayName);

      _isSaving = false;
      notifyListeners();

      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } on FormatException catch (error) {
      _errorMessage = error.message.toString();
    } catch (_) {
      _errorMessage = 'Unable to update your display name.';
    }

    _isSaving = false;
    notifyListeners();

    return false;
  }

  Future<bool> pickAndUploadAvatar() async {
    if (_isSaving) return false;

    _errorMessage = null;

    try {
      final image = kIsWeb
          ? await _imagePicker.pickImage(
              source: ImageSource.gallery,
              requestFullMetadata: false,
            )
          : await _imagePicker.pickImage(
              source: ImageSource.gallery,
              maxWidth: 1200,
              maxHeight: 1200,
              imageQuality: 85,
              requestFullMetadata: false,
            );

      if (image == null) {
        return true;
      }

      _isSaving = true;
      notifyListeners();

      _profile = await _profileRepository.uploadAvatar(image);

      _isSaving = false;
      notifyListeners();

      return true;
    } on PlatformException catch (error) {
      _errorMessage = error.message ?? 'Unable to select a profile image.';
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } on StorageException catch (error) {
      _errorMessage = error.message;
    } on FormatException catch (error) {
      _errorMessage = error.message.toString();
    } catch (error, stackTrace) {
      debugPrint('Avatar upload error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to update your profile image.';
    }

    _isSaving = false;
    notifyListeners();

    return false;
  }

  Future<bool> deleteAvatar() async {
    if (_isSaving) return false;

    _isSaving = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _profile = await _profileRepository.deleteAvatar();

      _isSaving = false;
      notifyListeners();

      return true;
    } on AuthException catch (error) {
      _errorMessage = error.message;
    } on PostgrestException catch (error) {
      _errorMessage = error.message;
    } on StorageException catch (error) {
      _errorMessage = error.message;
    } catch (error, stackTrace) {
      debugPrint('Avatar deletion error: $error');
      debugPrintStack(stackTrace: stackTrace);
      _errorMessage = 'Unable to delete your profile image.';
    }

    _isSaving = false;
    notifyListeners();

    return false;
  }
}
