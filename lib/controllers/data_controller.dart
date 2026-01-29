import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class DataController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  final GetStorage _storage = GetStorage();

  // Observable lists
  final RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> news = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> bills = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> management = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> gallery = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> polls = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userAspirations =
      <Map<String, dynamic>>[].obs;
  final RxList<int> votedPollIds = <int>[].obs;

  // Observable single objects
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;

  // Loading states
  final RxBool isLoadingEvents = false.obs;
  final RxBool isLoadingManagement = false.obs;
  final RxBool isLoadingGallery = false.obs;
  final RxBool isLoadingPolls = false.obs;
  final RxBool isLoadingAspirations = false.obs;
  final RxBool isLoadingProfile = false.obs;

  @override
  void onInit() {
    super.onInit();
    // 1. Load from local storage immediately
    _loadFromStorage();

    // 2. Fetch fresh data from server
    refreshData();
  }

  void _loadFromStorage() {
    _loadList('events', events);
    _loadList('news', news);
    _loadList('bills', bills);
    _loadList('management', management);
    _loadList('gallery', gallery);
    _loadList('polls', polls);
    _loadList('userAspirations', userAspirations);

    final storedVotedPolls = _storage.read<List>('votedPollIds');
    if (storedVotedPolls != null) {
      votedPollIds.assignAll(storedVotedPolls.cast<int>());
    }

    final storedProfile = _storage.read<Map>('userProfile');
    if (storedProfile != null) {
      userProfile.assignAll(Map<String, dynamic>.from(storedProfile));
    }
  }

  void _loadList(String key, RxList list) {
    final stored = _storage.read<List>(key);
    if (stored != null) {
      list.assignAll(stored.map((e) => Map<String, dynamic>.from(e)).toList());
    }
  }

  Future<void> refreshData() async {
    // Fetch global data in parallel
    await Future.wait([
      fetchEvents(),
      fetchNews(),
      fetchBills(),
      fetchManagement(),
      fetchGallery(),
      fetchPolls(),
    ]);

    // Fetch user specific data
    await fetchUserProfile();
    await fetchUserAspirations();
  }

  // --- Fetch Methods ---

  Future<void> fetchEvents() async {
    await _fetchList(
      'events',
      events,
      () => _supabaseService.getEvents(),
      isLoadingEvents,
    );
  }

  Future<void> fetchNews() async {
    await _fetchList(
      'news',
      news,
      () => _supabaseService.getNews(),
      null, // No specific loading state needed for news yet
    );
  }

  Future<void> fetchBills() async {
    await _fetchList('bills', bills, () => _supabaseService.getBills(), null);
  }

  Future<void> fetchManagement() async {
    await _fetchList(
      'management',
      management,
      () => _supabaseService.getManagement(),
      isLoadingManagement,
    );
  }

  Future<void> fetchGallery() async {
    await _fetchList(
      'gallery',
      gallery,
      () => _supabaseService.getGallery(),
      isLoadingGallery,
    );
  }

  Future<void> fetchPolls() async {
    await _fetchList(
      'polls',
      polls,
      () => _supabaseService.getActivePolls(),
      isLoadingPolls,
    );
  }

  Future<void> fetchUserAspirations() async {
    await _fetchList(
      'userAspirations',
      userAspirations,
      () => _supabaseService.getUserAspirations(),
      isLoadingAspirations,
    );
  }

  Future<void> fetchUserProfile() async {
    try {
      isLoadingProfile.value = true;
      final user = _supabaseService.currentUser;
      if (user != null) {
        // Default from auth metadata
        final Map<String, dynamic> profileData = {
          'full_name':
              user.userMetadata?['full_name'] ??
              user.email?.split('@')[0] ??
              'User',
          'email': user.email,
          'avatar_url':
              'https://ui-avatars.com/api/?name=${Uri.encodeComponent(user.email?.split('@')[0] ?? 'User')}&background=random',
          'role': 'Anggota Karang Taruna', // Default
        };

        // Fetch from DB
        final dbProfile = await _supabaseService.getCurrentUserProfile();
        if (dbProfile != null) {
          if (dbProfile['full_name'] != null)
            profileData['full_name'] = dbProfile['full_name'];
          if (dbProfile['role'] != null)
            profileData['role'] = dbProfile['role'];
          if (dbProfile['avatar_url'] != null &&
              dbProfile['avatar_url'].toString().isNotEmpty) {
            profileData['avatar_url'] = dbProfile['avatar_url'];
          }
        }

        userProfile.assignAll(profileData);
        await _storage.write('userProfile', profileData);
      }
    } catch (e) {
      print("Error fetching profile: $e");
    } finally {
      isLoadingProfile.value = false;
    }
  }

  // --- Helper ---

  Future<void> _fetchList(
    String key,
    RxList<Map<String, dynamic>> list,
    Future<List<Map<String, dynamic>>> Function() fetcher,
    RxBool? loadingState,
  ) async {
    try {
      if (list.isEmpty && loadingState != null) loadingState.value = true;

      final remoteData = await fetcher();

      list.assignAll(remoteData);
      await _storage.write(key, remoteData);
    } catch (e) {
      print("Error fetching $key: $e");
    } finally {
      if (loadingState != null) loadingState.value = false;
    }
  }

  // --- Actions ---

  Future<void> votePoll(int pollId, int optionId) async {
    try {
      await _supabaseService.submitVote(optionId);

      // Update local state
      votedPollIds.add(pollId);
      await _storage.write('votedPollIds', votedPollIds.toList());

      // Refresh polls to show updated counts
      await fetchPolls();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> createAspiration(
    String author,
    String content,
    String userId,
  ) async {
    try {
      await _supabaseService.submitAspiration(author, content, userId: userId);
      // Refresh aspirations
      await fetchUserAspirations();
    } catch (e) {
      rethrow;
    }
  }
}
