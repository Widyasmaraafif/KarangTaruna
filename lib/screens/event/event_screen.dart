import 'package:flutter/material.dart';
import 'package:karang_taruna/commons/widgets/containers/event_card.dart';
import 'package:karang_taruna/commons/widgets/texts/event_heading.dart';

class EventScreen extends StatefulWidget {
  const EventScreen({super.key});

  @override
  State<EventScreen> createState() => _EventScreenState();
}

class _EventScreenState extends State<EventScreen> {
  bool showUpcoming = true;
  bool showOngoing = false;
  bool showCompleted = false;

  final List<_EventItem> upcomingEvents = [
    _EventItem(
      title: 'Kerja Bakti Lingkungan',
      description:
          'Kegiatan kerja bakti membersihkan selokan dan lingkungan sekitar RT 03.',
      date: DateTime(2026, 1, 20),
      time: TimeOfDay(hour: 8, minute: 0),
      status: KTEventStatus.upcoming,
    ),
    _EventItem(
      title: 'Rapat Koordinasi Bulanan',
      description:
          'Rapat koordinasi pengurus karang taruna untuk evaluasi kegiatan bulan ini.',
      date: DateTime(2026, 1, 25),
      time: TimeOfDay(hour: 19, minute: 30),
      status: KTEventStatus.upcoming,
    ),
  ];

  final List<_EventItem> ongoingEvents = [
    _EventItem(
      title: 'Pelatihan Keterampilan Digital',
      description:
          'Pelatihan dasar desain grafis dan pengelolaan media sosial untuk pemuda.',
      date: DateTime(2026, 1, 18),
      time: TimeOfDay(hour: 9, minute: 0),
      status: KTEventStatus.ongoing,
    ),
  ];

  final List<_EventItem> completedEvents = [
    _EventItem(
      title: 'Lomba Kebersihan Lingkungan',
      description:
          'Penilaian lomba kebersihan lingkungan antar RT yang telah selesai dilaksanakan.',
      date: DateTime(2025, 12, 30),
      time: TimeOfDay(hour: 16, minute: 0),
      status: KTEventStatus.completed,
    ),
    _EventItem(
      title: 'Donor Darah',
      description:
          'Kegiatan donor darah bekerja sama dengan PMI di balai RW 05.',
      date: DateTime(2025, 11, 15),
      time: TimeOfDay(hour: 8, minute: 30),
      status: KTEventStatus.completed,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF00BA9B),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.only(bottom: 30),
          child: Column(
            children: [
              const SizedBox(height: 16),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    KTEventHeader(
                      title: 'Event Mendatang',
                      isExpanded: showUpcoming,
                      onToggle: () {
                        setState(() {
                          showUpcoming = !showUpcoming;
                        });
                      },
                    ),
                    if (showUpcoming)
                      Column(
                        children: upcomingEvents
                            .map(
                              (event) => KTEventCard(
                                title: event.title,
                                description: event.description,
                                date: event.date,
                                time: event.time,
                                status: event.status,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    KTEventHeader(
                      title: 'Event Berjalan',
                      isExpanded: showOngoing,
                      onToggle: () {
                        setState(() {
                          showOngoing = !showOngoing;
                        });
                      },
                    ),
                    if (showOngoing)
                      Column(
                        children: ongoingEvents
                            .map(
                              (event) => KTEventCard(
                                title: event.title,
                                description: event.description,
                                date: event.date,
                                time: event.time,
                                status: event.status,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                padding: const EdgeInsets.symmetric(horizontal: 30),
                child: Column(
                  children: [
                    KTEventHeader(
                      title: 'Event Selesai',
                      isExpanded: showCompleted,
                      onToggle: () {
                        setState(() {
                          showCompleted = !showCompleted;
                        });
                      },
                    ),
                    if (showCompleted)
                      Column(
                        children: completedEvents
                            .map(
                              (event) => KTEventCard(
                                title: event.title,
                                description: event.description,
                                date: event.date,
                                time: event.time,
                                status: event.status,
                              ),
                            )
                            .toList(),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
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

  const _EventItem({
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
  });
}
