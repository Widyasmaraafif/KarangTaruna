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

  // Get all paid bills for organization transparency
  Future<List<Map<String, dynamic>>> getOrganizationFinances() async {
    try {
      final response = await _client
          .from('bills')
          .select('*, profiles(full_name)')
          .eq('is_paid', true)
          .order('updated_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // --- Organization Finance Accounts ---
  Future<List<Map<String, dynamic>>> getFinanceAccounts() async {
    try {
      final response = await _client
          .from('finance_accounts')
          .select()
          .order('id', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getFinanceTransactions(
    int accountId,
  ) async {
    try {
      final response = await _client
          .from('finance_transactions')
          .select()
          .eq('account_id', accountId)
          .order('transaction_date', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  Future<void> addFinanceAccount(Map<String, dynamic> data) async {
    await _client.from('finance_accounts').insert(data);
  }

  Future<void> updateFinanceAccount(int id, Map<String, dynamic> data) async {
    await _client.from('finance_accounts').update(data).eq('id', id);
  }

  Future<void> deleteFinanceAccount(int id) async {
    await _client.from('finance_accounts').delete().eq('id', id);
  }

  Future<void> addFinanceTransaction(Map<String, dynamic> data) async {
    await _client.from('finance_transactions').insert(data);
  }

  Future<void> deleteFinanceTransaction(int id) async {
    await _client.from('finance_transactions').delete().eq('id', id);
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

  Future<void> createAnnouncement(Map<String, dynamic> data) async {
    await _client.from('announcements').insert(data);
  }

  Future<void> updateAnnouncement(int id, Map<String, dynamic> data) async {
    await _client.from('announcements').update(data).eq('id', id);
  }

  Future<void> deleteAnnouncement(int id) async {
    await _client.from('announcements').delete().eq('id', id);
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
    String? title,
    String? category,
    String? imageUrl,
  }) async {
    final data = {
      'author': author,
      'content': content,
      'title': title,
      'category': category ?? 'Umum',
      'image_url': imageUrl,
      'status': 'Menunggu Tindak Lanjut', // Default status
    };
    if (userId != null) {
      data['user_id'] = userId;
    }
    await _client.from('aspirations').insert(data);
  }

  Future<void> createAspirationFull(Map<String, dynamic> data) async {
    await _client.from('aspirations').insert(data);
  }

  Future<void> updateAspiration(int id, Map<String, dynamic> data) async {
    await _client.from('aspirations').update(data).eq('id', id);
  }

  Future<void> deleteAspiration(int id) async {
    await _client.from('aspirations').delete().eq('id', id);
  }

  Future<String> uploadAspirationImage(File file) async {
    final fileExt = file.path.split('.').last;
    final fileName =
        'aspirations/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _client.storage
        .from('news_images') // Using same bucket for now
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    final imageUrl = _client.storage.from('news_images').getPublicUrl(fileName);
    return imageUrl;
  }

  Future<String> uploadEventImage(File file) async {
    final fileExt = file.path.split('.').last;
    final fileName = 'events/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _client.storage
        .from('news_images')
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    final imageUrl = _client.storage.from('news_images').getPublicUrl(fileName);
    return imageUrl;
  }

  // --- Profile ---
  // Mendapatkan semua profil user (untuk admin)
  Future<List<Map<String, dynamic>>> getUsers() async {
    return getAllProfiles();
  }

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

    // Sync full_name to auth metadata if present
    if (updates.containsKey('full_name')) {
      try {
        await _client.auth.updateUser(
          UserAttributes(data: {'full_name': updates['full_name']}),
        );
      } catch (e) {
        // Ignore auth update errors, main profile update succeeded
        print('Failed to sync auth metadata: $e');
      }
    }
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
      'role': 'User',
      'updated_at': DateTime.now().toIso8601String(),
    });
  }

  // --- Management ---
  Future<List<Map<String, dynamic>>> getManagement() async {
    try {
      // Fetch directly from profiles, filtering out regular members and admin
      final response = await _client
          .from('profiles')
          .select()
          .neq('role', 'Anggota')
          .neq('role', 'Admin');

      var members = List<Map<String, dynamic>>.from(response);

      // Define role priority for sorting
      final rolePriority = {
        'Ketua': 1,
        'Wakil Ketua': 2,
        'Sekretaris': 3,
        'Bendahara': 4,
        // Add other roles here with appropriate rank
      };

      // Sort members
      members.sort((a, b) {
        final roleA = a['role'] ?? '';
        final roleB = b['role'] ?? '';

        final rankA = rolePriority[roleA] ?? 99; // Default low priority
        final rankB = rolePriority[roleB] ?? 99;

        if (rankA != rankB) {
          return rankA.compareTo(rankB);
        }
        return (a['full_name'] ?? '').compareTo(b['full_name'] ?? '');
      });

      return members;
    } catch (e) {
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

  Future<void> createGalleryItem(Map<String, dynamic> data) async {
    await _client.from('gallery').insert(data);
  }

  Future<void> deleteGalleryItem(int id) async {
    await _client.from('gallery').delete().eq('id', id);
  }

  Future<String> uploadGalleryImage(File file) async {
    final fileExt = file.path.split('.').last;
    final fileName =
        'gallery/${DateTime.now().millisecondsSinceEpoch}.$fileExt';

    await _client.storage
        .from('news_images') // Reusing existing bucket
        .upload(fileName, file, fileOptions: const FileOptions(upsert: true));

    final imageUrl = _client.storage.from('news_images').getPublicUrl(fileName);
    return imageUrl;
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

  Future<List<int>> getVotedPollIds() async {
    final user = _client.auth.currentUser;
    if (user == null) return [];

    try {
      final response = await _client
          .from('polling_votes')
          .select('polling_id')
          .eq('user_id', user.id);

      return (response as List).map((e) => e['polling_id'] as int).toList();
    } catch (e) {
      // Table might not exist or other error
      print('Error fetching voted polls: $e');
      return [];
    }
  }

  Future<Map<int, int>> getVotedSelections() async {
    final user = _client.auth.currentUser;
    if (user == null) return {};

    try {
      final response = await _client
          .from('polling_votes')
          .select('polling_id, option_id')
          .eq('user_id', user.id);

      final list = List<Map<String, dynamic>>.from(response as List);
      final result = <int, int>{};
      for (final row in list) {
        final pid = row['polling_id'] as int?;
        final oid = row['option_id'] as int?;
        if (pid != null && oid != null) {
          result[pid] = oid;
        }
      }
      return result;
    } catch (e) {
      print('Error fetching voted selections: $e');
      return {};
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
      // Fallback: fetch polls and options separately if join fails
      try {
        final pollsResponse = await _client
            .from('pollings')
            .select()
            .eq('is_active', true)
            .order('created_at', ascending: false);

        final polls = List<Map<String, dynamic>>.from(pollsResponse);
        if (polls.isEmpty) return [];

        final pollIds = polls.map((p) => p['id']).toList();

        // Try to fetch options
        List<Map<String, dynamic>> options = [];
        try {
          final optionsResponse = await _client
              .from('polling_options')
              .select()
              .filter('polling_id', 'in', pollIds);
          options = List<Map<String, dynamic>>.from(optionsResponse);
        } catch (_) {
          // Ignore if options table missing or error
        }

        // Group options by polling_id
        final optionsMap = <dynamic, List<Map<String, dynamic>>>{};
        for (var opt in options) {
          final pid = opt['polling_id'];
          if (!optionsMap.containsKey(pid)) {
            optionsMap[pid] = [];
          }
          optionsMap[pid]!.add(opt);
        }

        // Merge back
        return polls.map((poll) {
          final pid = poll['id'];
          final newPoll = Map<String, dynamic>.from(poll);
          newPoll['polling_options'] = optionsMap[pid] ?? [];
          return newPoll;
        }).toList();
      } catch (e2) {
        return [];
      }
    }
  }

  Future<void> submitVote(int pollId, int optionId) async {
    final user = _client.auth.currentUser;
    if (user == null) throw Exception('Not authenticated');

    final hasVoted = await _client
        .from('polling_votes')
        .select()
        .eq('user_id', user.id)
        .eq('polling_id', pollId)
        .maybeSingle();
    if (hasVoted != null) {
      throw Exception('Anda sudah memilih pada polling ini');
    }
    await _client.from('polling_votes').insert({
      'user_id': user.id,
      'polling_id': pollId,
      'option_id': optionId,
      'created_at': DateTime.now().toIso8601String(),
    });

    // 3. Increment vote count
    try {
      await _client.rpc('increment_vote', params: {'option_id': optionId});
    } catch (_) {
      // Fallback if RPC doesn't exist
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
