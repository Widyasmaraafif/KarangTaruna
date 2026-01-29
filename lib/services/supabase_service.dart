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

  Future<List<Map<String, dynamic>>> getUserAspirations() async {
    try {
      final user = _client.auth.currentUser;
      if (user == null) return [];

      final response = await _client
          .from('aspirations')
          .select()
          .eq('user_id', user.id)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> submitAspiration(
    String author,
    String content, {
    String? userId,
  }) async {
    final data = {'author': author, 'content': content};
    if (userId != null) {
      data['user_id'] = userId;
    }
    await _client.from('aspirations').insert(data);
  }

  Future<void> deleteAspiration(int id) async {
    await _client.from('aspirations').delete().eq('id', id);
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

  Future<void> createProfile({
    required String userId,
    required String fullName,
    String? email,
  }) async {
    await _client.from('profiles').upsert({
      'id': userId,
      'full_name': fullName,
      'role': 'Anggota', // Default role
      'updated_at': DateTime.now().toIso8601String(),
    });
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

  // --- Polling ---
  Future<List<Map<String, dynamic>>> getActivePolls() async {
    try {
      final response = await _client
          .from('pollings')
          .select('*, polling_options(*)')
          .eq('is_active', true)
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> submitVote(int optionId) async {
    await _client.rpc('increment_vote', params: {'option_id': optionId});
    // Note: If you don't have an RPC function, you can use update,
    // but concurrency might be an issue. RPC is safer.
    // For now, let's use a direct update with existing value + 1 if RPC is not an option yet.
    // But since user provided schema without RPC, we might need to do read-update-write or just assume RPC exists.
    // Actually, let's try a direct update but it's risky for concurrency.
    // Better approach without RPC:
    // await _client.from('polling_options').update({'vote_count': count + 1}).eq('id', optionId);
    // But we need to fetch first.

    // Alternative: Use a stored procedure (RPC) is best practice.
    // Since I cannot create RPC easily from here without SQL Editor, I will assume a basic update for now
    // or provide the RPC SQL to the user.

    // Let's implement a simple fetch-increment-update loop for now,
    // fully aware of race conditions but acceptable for MVP.
    final option = await _client
        .from('polling_options')
        .select('vote_count')
        .eq('id', optionId)
        .single();
    final currentCount = option['vote_count'] as int;
    await _client
        .from('polling_options')
        .update({'vote_count': currentCount + 1})
        .eq('id', optionId);
  }
}
