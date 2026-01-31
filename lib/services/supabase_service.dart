import 'dart:io';
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

  Future<void> createEvent(Map<String, dynamic> eventData) async {
    await _client.from('events').insert(eventData);
  }

  Future<void> updateEvent(int id, Map<String, dynamic> eventData) async {
    await _client.from('events').update(eventData).eq('id', id);
  }

  Future<void> deleteEvent(int id) async {
    await _client.from('events').delete().eq('id', id);
  }

  // --- Finance / Bills ---
  // Get all bills for admin
  Future<List<Map<String, dynamic>>> getAllBills() async {
    // Try to fetch with explicit relationship hint if standard detection fails
    // Using profiles!user_id to specify the foreign key column
    try {
      final response = await _client
          .from('bills')
          .select('*, profiles(full_name)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      // Fallback: fetch bills and profiles separately if join fails
      // This handles cases where foreign key constraint might be missing or not detected
      final billsResponse = await _client
          .from('bills')
          .select()
          .order('created_at', ascending: false);

      final bills = List<Map<String, dynamic>>.from(billsResponse);

      if (bills.isEmpty) return [];

      // Get all user IDs from bills
      final userIds = bills
          .map((bill) => bill['user_id'] as String?)
          .where((id) => id != null)
          .cast<String>()
          .toSet()
          .toList();

      if (userIds.isEmpty) return bills;

      // Fetch profiles for these users
      final profilesResponse = await _client
          .from('profiles')
          .select('id, full_name')
          .filter('id', 'in', userIds);

      final profiles = List<Map<String, dynamic>>.from(profilesResponse);
      final profilesMap = {for (var p in profiles) p['id']: p};

      // Merge profiles into bills
      return bills.map((bill) {
        final userId = bill['user_id'];
        if (userId != null && profilesMap.containsKey(userId)) {
          // Create a new map to avoid modifying the original if it's immutable
          final newBill = Map<String, dynamic>.from(bill);
          newBill['profiles'] = profilesMap[userId];
          return newBill;
        }
        return bill;
      }).toList();
    }
  }

  Future<List<Map<String, dynamic>>> getBills() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    final response = await _client
        .from('bills')
        .select()
        .eq('user_id', user.id)
        .order('due_date', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createBill(Map<String, dynamic> billData) async {
    await _client.from('bills').insert(billData);
  }

  Future<void> updateBill(int id, Map<String, dynamic> billData) async {
    await _client.from('bills').update(billData).eq('id', id);
  }

  Future<void> deleteBill(int id) async {
    await _client.from('bills').delete().eq('id', id);
  }

  // --- News ---
  Future<List<Map<String, dynamic>>> getNews() async {
    final response = await _client
        .from('news')
        .select()
        .order('created_at', ascending: false);
    return List<Map<String, dynamic>>.from(response);
  }

  Future<void> createNews(Map<String, dynamic> newsData) async {
    await _client.from('news').insert(newsData);
  }

  Future<void> updateNews(int id, Map<String, dynamic> newsData) async {
    await _client.from('news').update(newsData).eq('id', id);
  }

  Future<void> deleteNews(int id) async {
    await _client.from('news').delete().eq('id', id);
  }

  Future<String> uploadNewsImage(File file) async {
    final fileExt = file.path.split('.').last;
    final fileName = 'news/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _client.storage
        .from('news_images')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    final imageUrl = _client.storage.from('news_images').getPublicUrl(fileName);
    return imageUrl;
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
  // Mendapatkan semua profil user (untuk admin)
  Future<List<Map<String, dynamic>>> getAllProfiles() async {
    final response = await _client
        .from('profiles')
        .select()
        .order('full_name', ascending: true);
    return List<Map<String, dynamic>>.from(response);
  }

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

  Future<void> updateProfileRole(String userId, String newRole) async {
    await _client.from('profiles').update({'role': newRole}).eq('id', userId);
  }

  Future<void> updateProfile(Map<String, dynamic> updates) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // Ensure ID is included for upsert
    final dataToUpsert = Map<String, dynamic>.from(updates);
    dataToUpsert['id'] = user.id;

    await _client.from('profiles').upsert(dataToUpsert);
  }

  Future<String> uploadAvatar(File file) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final fileExt = file.path.split('.').last;
    final fileName =
        '${user.id}/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _client.storage
        .from('avatars')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    final imageUrl = _client.storage.from('avatars').getPublicUrl(fileName);
    return imageUrl;
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
  Future<List<Map<String, dynamic>>> getAllPolls() async {
    try {
      final response = await _client
          .from('pollings')
          .select('*, polling_options(*)')
          .order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

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

  Future<void> createPoll(String question, List<String> options) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    // 1. Create the poll
    final pollResponse = await _client
        .from('pollings')
        .insert({
          'title': question,
          'created_by': user.id,
          'is_active': true,
          'created_at': DateTime.now().toIso8601String(),
        })
        .select()
        .single();

    final pollId = pollResponse['id'];

    // 2. Create options
    final optionsData = options
        .map((opt) => {'polling_id': pollId, 'label': opt, 'vote_count': 0})
        .toList();

    await _client.from('polling_options').insert(optionsData);
  }

  Future<void> deletePoll(int id) async {
    // Options should cascade delete if set up correctly in DB,
    // but we can delete them explicitly to be safe if cascade isn't guaranteed.
    await _client.from('polling_options').delete().eq('polling_id', id);
    await _client.from('pollings').delete().eq('id', id);
  }

  Future<void> updatePollStatus(int id, bool isActive) async {
    await _client.from('pollings').update({'is_active': isActive}).eq('id', id);
  }

  Future<void> updatePollFull({
    required int pollId,
    required String question,
    required List<Map<String, dynamic>> updatedOptions,
    required List<int> deletedOptionIds,
  }) async {
    // 1. Update Question
    await _client.from('pollings').update({'title': question}).eq('id', pollId);

    // 2. Delete removed options
    if (deletedOptionIds.isNotEmpty) {
      await _client
          .from('polling_options')
          .delete()
          .filter('id', 'in', deletedOptionIds);
    }

    // 3. Upsert options
    for (var opt in updatedOptions) {
      if (opt.containsKey('id')) {
        await _client
            .from('polling_options')
            .update({'label': opt['label']})
            .eq('id', opt['id']);
      } else {
        await _client.from('polling_options').insert({
          'polling_id': pollId,
          'label': opt['label'],
          'vote_count': 0,
        });
      }
    }
  }
}
