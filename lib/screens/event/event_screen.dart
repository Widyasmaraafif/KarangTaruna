import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:karang_taruna/commons/widgets/containers/event_card.dart';
import 'package:karang_taruna/commons/widgets/texts/event_heading.dart';
import 'package:karang_taruna/controllers/data_controller.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool showUpcoming = true;
  bool showOngoing = false;
  bool showCompleted = false;

  @override
  Widget build(BuildContext context) {
    // Find the controller injected in NavigationMenu
    final controller = Get.find<DataController>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Event"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Colors.white,
      ),
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: controller.fetchEvents,
          child: Obx(() {
            // Show loading only if no data is available
            if (controller.isLoadingEvents.value && controller.events.isEmpty) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }

            final events = controller.events;
            final upcomingEvents = _filterEvents(events, 'upcoming');
            final ongoingEvents = _filterEvents(events, 'ongoing');
            final completedEvents = _filterEvents(events, 'completed');

            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 30),
              child: Column(
                children: [
                  const SizedBox(height: 16),
                  _buildSection(
                    title: 'Event Mendatang',
                    events: upcomingEvents,
                    isExpanded: showUpcoming,
                    onToggle: () =>
                        setState(() => showUpcoming = !showUpcoming),
                  ),
                  _buildSection(
                    title: 'Event Berjalan',
                    events: ongoingEvents,
                    isExpanded: showOngoing,
                    onToggle: () => setState(() => showOngoing = !showOngoing),
                  ),
                  _buildSection(
                    title: 'Event Selesai',
                    events: completedEvents,
                    isExpanded: showCompleted,
                    onToggle: () =>
                        setState(() => showCompleted = !showCompleted),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }),
        ),
      ),
    );
  }

  List<_EventItem> _filterEvents(
    List<Map<String, dynamic>> events,
    String status,
  ) {
    return events.where((e) => e['status'] == status).map((e) {
      final date = DateTime.tryParse(e['event_date'] ?? '') ?? DateTime.now();
      return _EventItem(
        title: e['title'] ?? 'No Title',
        description: e['description'] ?? '',
        date: date,
        time: TimeOfDay.fromDateTime(date),
        status: _parseStatus(status),
        location: e['location'] ?? '',
      );
    }).toList();
  }

  KTEventStatus _parseStatus(String status) {
    switch (status) {
      case 'upcoming':
        return KTEventStatus.upcoming;
      case 'ongoing':
        return KTEventStatus.ongoing;
      case 'completed':
        return KTEventStatus.completed;
      default:
        return KTEventStatus.upcoming;
    }
  }

  Widget _buildSection({
    required String title,
    required List<_EventItem> events,
    required bool isExpanded,
    required VoidCallback onToggle,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 20),
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          KTEventHeader(
            title: title,
            isExpanded: isExpanded,
            onToggle: onToggle,
          ),
          if (isExpanded)
            Column(
              children: events.isEmpty
                  ? [
                      const Padding(
                        padding: EdgeInsets.all(8.0),
                        child: Text(
                          "Tidak ada event",
                          style: TextStyle(color: Colors.white70),
                        ),
                      ),
                    ]
                  : events
                        .map(
                          (event) => KTEventCard(
                            title: event.title,
                            description: event.description,
                            date: event.date,
                            time: event.time,
                            status: event.status,
                            location: event.location,
                          ),
                        )
                        .toList(),
            ),
        ],
      ),
    );
  }
}

class _EventItem {
  final String title;
  final String description;
  final DateTime date;
  final TimeOfDay time;
  final KTEventStatus status;
  final String location;

  const _EventItem({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.location,
  });
}
