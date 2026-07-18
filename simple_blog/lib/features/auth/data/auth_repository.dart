import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepository {
  const AuthRepository(this._supabase);

  final SupabaseClient _supabase;

  User? get currentUser => _supabase.auth.currentUser;
  Session? get currentSession => _supabase.auth.currentSession;

  Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signUp(email: email.trim(), password: password);
  }

  Future<AuthResponse> login({
    required String email,
    required String password,
  }) {
    return _supabase.auth.signInWithPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<void> logout() {
    return _supabase.auth.signOut();
  }
}
