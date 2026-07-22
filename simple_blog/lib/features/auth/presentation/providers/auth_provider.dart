import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:simple_blog/features/auth/data/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum AuthSubmissionStatus { idle, loading, success, failure }

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._authRepository)
    : _currentUser = _authRepository.currentUser {
    _authSubscription = _authRepository.authStateChanges.listen(
      _handleAuthStateChange,
    );
  }

  final AuthRepository _authRepository;
  late final StreamSubscription<AuthState> _authSubscription;

  User? _currentUser;
  AuthSubmissionStatus _status = AuthSubmissionStatus.idle;
  String? _errorMessage;

  User? get currentUser => _currentUser;

  AuthSubmissionStatus get status => _status;

  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _currentUser != null;

  bool get isLoading => _status == AuthSubmissionStatus.loading;

  Future<bool> register({
    required String email,
    required String password,
  }) async {
    if (isLoading) return false;

    _setState(status: AuthSubmissionStatus.loading, clearError: true);

    try {
      final response = await _authRepository.register(
        email: email,
        password: password,
      );

      if (response.user == null) {
        throw const AuthException('Registration did not return a user.');
      }

      if (response.session == null) {
        throw const AuthException(
          'Registration succeeded, but email confirmation is still required.',
        );
      }

      _currentUser = response.user;

      _setState(status: AuthSubmissionStatus.success, clearError: true);

      return true;
    } on AuthException catch (error) {
      return _handleFailure(error);
    } catch (_) {
      return _handleUnknownFailure();
    }
  }

  Future<bool> login({required String email, required String password}) async {
    if (isLoading) return false;

    _setState(status: AuthSubmissionStatus.loading, clearError: true);

    try {
      final response = await _authRepository.login(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw const AuthException('Login did not create a valid session.');
      }

      _currentUser = response.user;

      _setState(status: AuthSubmissionStatus.success, clearError: true);

      return true;
    } on AuthException catch (error) {
      return _handleFailure(error);
    } catch (_) {
      return _handleUnknownFailure();
    }
  }

  Future<bool> logout() async {
    if (isLoading) return false;

    _setState(status: AuthSubmissionStatus.loading, clearError: true);

    try {
      await _authRepository.logout();
      _currentUser = null;

      _setState(status: AuthSubmissionStatus.success, clearError: true);

      return true;
    } on AuthException catch (error) {
      return _handleFailure(error);
    } catch (_) {
      return _handleUnknownFailure();
    }
  }

  void clearError() {
    if (_errorMessage == null && _status != AuthSubmissionStatus.failure) {
      return;
    }

    _errorMessage = null;
    if (_status == AuthSubmissionStatus.failure) {
      _status = AuthSubmissionStatus.idle;
    }
    notifyListeners();
  }

  void _handleAuthStateChange(AuthState authState) {
    _currentUser = authState.session?.user;
    notifyListeners();
  }

  bool _handleFailure(AuthException error) {
    _setState(
      status: AuthSubmissionStatus.failure,
      errorMessage: _friendlyMessage(error),
    );

    return false;
  }

  bool _handleUnknownFailure() {
    _setState(
      status: AuthSubmissionStatus.failure,
      errorMessage: 'Something went wrong. Please try again.',
    );

    return false;
  }

  void _setState({
    required AuthSubmissionStatus status,
    String? errorMessage,
    bool clearError = false,
  }) {
    _status = status;

    if (clearError) {
      _errorMessage = null;
    } else if (errorMessage != null) {
      _errorMessage = errorMessage;
    }

    notifyListeners();
  }

  String _friendlyMessage(AuthException error) {
    return switch (error.code) {
      'user_already_exists' => 'An account already exists for this email.',
      'email_address_invalid' => 'Enter a valid email address.',
      'weak_password' => 'Choose a stronger password.',
      'invalid_credentials' => 'Incorrect email or password.',
      'email_not_confirmed' => 'Confirm your email before signing in.',
      'over_email_send_rate_limit' =>
        'Too many attempts. Please wait and try again.',
      _ => error.message,
    };
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }
}
