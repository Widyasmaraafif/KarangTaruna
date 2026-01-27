import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseService {
  final SupabaseClient _client = Supabase.instance.client;

  // --- Authentication ---
  Future<AuthResponse> signIn(String email, String password) async {
    return await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<AuthResponse> signUp(
    String email,
    String password, {
    Map<String, dynamic>? data,
  }) async {
    return await _client.auth.signUp(
      email: email,
      password: password,
      data: data,
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  Stream<AuthState> get authStateChanges => _client.auth.onAuthStateChange;

  User? get currentUser => _client.auth.currentUser;

  // --- Events ---
  Future<List<Map<String, dynamic>>> getEvents() async {
    final response = await _client
        .from('events')
        .select()
        .order('event_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Stream<List<Map<String, dynamic>>> streamEvents() {
    return _client
        .from('events')
        .stream(primaryKey: ['id'])
        .order('event_date', ascending: true);
  }

  // --- Finance / Bills ---
  Future<List<Map<String, dynamic>>> getBills() async {
    final response = await _client
        .from('bills')
        .select()
        .order('due_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- News ---
  Future<List<Map<String, dynamic>>> getNews() async {
    final response = await _client
        .from('news')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- Announcements ---
  Future<List<Map<String, dynamic>>> getAnnouncements() async {
    final response = await _client
        .from('announcements')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  // --- Aspirations ---
  Future<List<Map<String, dynamic>>> getAspirations() async {
    try {
      final response = await _client
          .from('aspirations')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> submitAspiration(String author, String content) async {
    await _client.from('aspirations').insert({
      'author': author,
      'content': content,
    });
  }

  // --- Profile ---
  // Mendapatkan profil user yang sedang login
  Future<Map<String, dynamic>?> getCurrentUserProfile() async {
    final user = _client.auth.currentUser;
    if (user == null) return null;

    final response = await _client
        .from('profiles')
        .select()
        .eq('id', user.id)
        .maybeSingle();

    return response;
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    await _client.from('profiles').update(updates).eq('id', user.id);
  }

  // --- Management ---
  Future<List<Map<String, dynamic>>> getManagement() async {
    try {
      final response = await _client
          .from('management')
          .select()
          .order(
            'rank',
            ascending: true,
          ); // Assuming 'rank' for ordering hierarchy
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback if table doesn't exist or error occurs, return empty list
      return [];
    }
  }

  // --- Gallery ---
  Future<List<Map<String, dynamic>>> getGallery() async {
    try {
      final response = await _client
          .from('gallery')
          .select()
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }
}
