import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:karang_taruna/services/supabase_service.dart';

class DataController extends GetxController {
  final SupabaseService _supabaseService = SupabaseService();
  final GetStorage _storage = GetStorage();

  // Observable lists
  final RxList<Map<String, dynamic>> events = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> news = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> announcements =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> bills = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> organizationFinances =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> financeAccounts =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> management = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> gallery = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> polls = <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> allAspirations =
      <Map<String, dynamic>>[].obs;
  final RxList<Map<String, dynamic>> userAspirations =
      <Map<String, dynamic>>[].obs;
  final RxList<int> votedPollIds = <int>[].obs;

  // Observable single objects
  final RxMap<String, dynamic> userProfile = <String, dynamic>{}.obs;
  final RxMap<String, bool> notificationSettings = <String, bool>{
    'pushEnabled': true,
    'emailEnabled': false,
    'waEnabled': true,
    'eventReminders': true,
    'newsUpdates': false,
  }.obs;

  final RxMap<String, bool> privacySettings = <String, bool>{
    'showProfile': true,
    'showPhone': false,
    'showEmail': false,
    'allowTagging': true,
  }.obs;

  // Loading states
  final RxBool isLoadingEvents = false.obs;
  final RxBool isLoadingManagement = false.obs;
  final RxBool isLoadingGallery = false.obs;
  final RxBool isLoadingPolls = false.obs;
  final RxBool isLoadingBills = false.obs;
  final RxBool isLoadingOrganizationFinances = false.obs;
  final RxBool isLoadingFinanceAccounts = false.obs;
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
    _loadList('organizationFinances', organizationFinances);
    _loadList('financeAccounts', financeAccounts);
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

    final storedSettings = _storage.read<Map>('notificationSettings');
    if (storedSettings != null) {
      notificationSettings.assignAll(Map<String, bool>.from(storedSettings));
    }

    final storedPrivacy = _storage.read<Map>('privacySettings');
    if (storedPrivacy != null) {
      privacySettings.assignAll(Map<String, bool>.from(storedPrivacy));
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
      fetchAnnouncements(),
      fetchBills(),
      fetchOrganizationFinances(),
      fetchFinanceAccounts(),
      fetchManagement(),
      fetchGallery(),
      fetchPolls(),
      fetchAspirations(),
    ]);

    // Fetch user specific data
    await fetchUserProfile();
    await fetchUserAspirations();
    await fetchVotedPolls();
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

  Future<void> fetchAnnouncements() async {
    await _fetchList(
      'announcements',
      announcements,
      () => _supabaseService.getAnnouncements(),
      null,
    );
  }

  Future<void> fetchBills() async {
    await _fetchList(
      'bills',
      bills,
      () => _supabaseService.getBills(),
      isLoadingBills,
    );
  }

  Future<void> fetchOrganizationFinances() async {
    await _fetchList(
      'organizationFinances',
      organizationFinances,
      () => _supabaseService.getOrganizationFinances(),
      isLoadingOrganizationFinances,
    );
  }

  Future<void> fetchFinanceAccounts() async {
    await _fetchList(
      'financeAccounts',
      financeAccounts,
      () => _supabaseService.getFinanceAccounts(),
      isLoadingFinanceAccounts,
    );
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

  Future<void> fetchAspirations() async {
    await _fetchList(
      'allAspirations',
      allAspirations,
      () => _supabaseService.getAspirations(),
      isLoadingAspirations,
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

  Future<void> fetchVotedPolls() async {
    try {
      final ids = await _supabaseService.getVotedPollIds();
      votedPollIds.assignAll(ids);
      await _storage.write('votedPollIds', ids);
    } catch (e) {
      print("Error fetching voted polls: $e");
    }
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
          'phone': '',
          'address': '',
          'birth_date': '',
          'bio': '',
          'gender': '',
        };

        // Fetch from DB
        final dbProfile = await _supabaseService.getCurrentUserProfile();
        if (dbProfile != null) {
          if (dbProfile['full_name'] != null)
            profileData['full_name'] = dbProfile['full_name'];
          if (dbProfile['role'] != null)
            profileData['role'] = dbProfile['role'];
          if (dbProfile['phone'] != null)
            profileData['phone'] = dbProfile['phone'];
          if (dbProfile['address'] != null)
            profileData['address'] = dbProfile['address'];
          if (dbProfile['birth_date'] != null)
            profileData['birth_date'] = dbProfile['birth_date'];
          if (dbProfile['bio'] != null) profileData['bio'] = dbProfile['bio'];
          if (dbProfile['gender'] != null)
            profileData['gender'] = dbProfile['gender'];
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
      await _supabaseService.submitVote(pollId, optionId);

      // Update local state
      votedPollIds.add(pollId);
      await _storage.write('votedPollIds', votedPollIds.toList());

      // Refresh polls to show updated counts
      await fetchPolls();
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateProfile({
    required String fullName,
    required String phone,
    String? address,
    String? birthDate,
    String? bio,
    String? gender,
    String? avatarUrl,
  }) async {
    try {
      final user = _supabaseService.currentUser;
      if (user == null) return;

      final updates = {
        'full_name': fullName,
        'phone': phone,
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (address != null) updates['address'] = address;
      if (birthDate != null) updates['birth_date'] = birthDate;
      if (bio != null) updates['bio'] = bio;
      if (gender != null) updates['gender'] = gender;
      if (avatarUrl != null) updates['avatar_url'] = avatarUrl;

      await _supabaseService.updateProfile(updates);

      // Update local state
      userProfile['full_name'] = fullName;
      userProfile['phone'] = phone;
      if (address != null) userProfile['address'] = address;
      if (birthDate != null) userProfile['birth_date'] = birthDate;
      if (bio != null) userProfile['bio'] = bio;
      if (gender != null) userProfile['gender'] = gender;
      if (avatarUrl != null) userProfile['avatar_url'] = avatarUrl;

      userProfile.refresh();
      await _storage.write('userProfile', userProfile);
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

  Future<void> deleteAspiration(int id) async {
    try {
      await _supabaseService.deleteAspiration(id);
      // Refresh aspirations
      await fetchUserAspirations();
    } catch (e) {
      rethrow;
    }
  }

  void updateNotificationSetting(String key, bool value) {
    notificationSettings[key] = value;
    _storage.write(
      'notificationSettings',
      Map<String, dynamic>.from(notificationSettings),
    );
  }

  void updatePrivacySetting(String key, bool value) {
    privacySettings[key] = value;
    _storage.write(
      'privacySettings',
      Map<String, dynamic>.from(privacySettings),
    );
  }

  void clearData() {
    // Clear lists
    events.clear();
    news.clear();
    announcements.clear();
    bills.clear();
    organizationFinances.clear();
    financeAccounts.clear();
    management.clear();
    gallery.clear();
    polls.clear();
    allAspirations.clear();
    userAspirations.clear();
    votedPollIds.clear();

    // Clear maps
    userProfile.clear();

    // Reset settings to defaults
    notificationSettings.assignAll({
      'pushEnabled': true,
      'emailEnabled': false,
      'waEnabled': true,
      'eventReminders': true,
      'newsUpdates': false,
    });

    privacySettings.assignAll({
      'showProfile': true,
      'showPhone': false,
      'showEmail': false,
      'allowTagging': true,
    });

    // Clear local storage
    _storage.erase();
  }
}
