import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/feedback.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../theme/evently_theme.dart';
import '../widgets/app_controls.dart';
import '../widgets/event_art.dart';
import 'event_form_screen.dart';

class EventDetailsScreen extends StatelessWidget {
  const EventDetailsScreen({super.key, required this.eventId});
  final String eventId;

  @override
  Widget build(BuildContext context) => StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
    stream: FirebaseFirestore.instance.collection('events').doc(eventId).snapshots(),
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Scaffold(body: SafeArea(child: Column(children: [
          ScreenTitle(title: 'Event details'),
          Expanded(child: EmptyEvents(message: 'Unable to load this event')),
        ])));
      }
      if (!snapshot.hasData) {
        return const Scaffold(body: Center(child: CircularProgressIndicator()));
      }
      if (snapshot.data?.exists != true) {
        return const Scaffold(body: SafeArea(child: Column(children: [
          ScreenTitle(title: 'Event details'),
          Expanded(child: EmptyEvents(message: 'This event is no longer available')),
        ])));
      }
      return _EventDetailContent(event: EventModel.fromFirestore(snapshot.data!));
    },
  );
}

class _EventDetailContent extends StatelessWidget {
  const _EventDetailContent({required this.event});
  final EventModel event;

  Future<void> deleteEvent(BuildContext context) async {
    final decision = await showDialog<bool>(context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete event?'),
        content: const Text('This action cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Delete', style: TextStyle(color: EventlyColors.red))),
        ],
      ),
    );
    if (decision != true || !context.mounted) return;
    try {
      final user = AuthService.instance.user;
      if (user == null) throw StateError('Please log in again.');
      await EventService.instance.delete(event, user.uid);
      if (context.mounted) Navigator.of(context).pop();
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context) {
    final primary = EventlyColors.primary(context);
    final owner = event.ownerId == AuthService.instance.user?.uid;
    return Scaffold(
      body: SafeArea(child: Column(children: [
        ScreenTitle(title: 'Event details', actions: owner ? [
          IconButton(
            tooltip: 'Edit event', padding: EdgeInsets.zero,
            onPressed: () => Navigator.push(context, MaterialPageRoute<void>(
                builder: (_) => EventFormScreen(event: event))),
            icon: Icon(Icons.edit_outlined, size: 20, color: primary),
          ),
          IconButton(
            tooltip: 'Delete event', padding: EdgeInsets.zero,
            onPressed: () => deleteEvent(context),
            icon: const Icon(Icons.delete_outline, size: 20,
                color: EventlyColors.red),
          ),
        ] : const []),
        Expanded(child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 25),
          children: [
            EventArt(category: event.category),
            const SizedBox(height: 18),
            Text(event.title, style: const TextStyle(
                fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: EventlyColors.outline(context)),
              ),
              child: Row(children: [
                Container(
                  width: 44, height: 44, alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(Icons.event_available_outlined,
                      size: 22, color: primary),
                ),
                const SizedBox(width: 11),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(DateFormat('dd MMMM yyyy').format(event.dateTime),
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600,
                          color: primary)),
                  const SizedBox(height: 3),
                  Text(DateFormat('hh:mm a').format(event.dateTime),
                      style: TextStyle(fontSize: 12,
                          color: EventlyColors.secondaryText(context))),
                ]),
              ]),
            ),
            const SizedBox(height: 20),
            const Text('Description', style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: EventlyColors.outline(context)),
              ),
              child: Text(event.description,
                  style: const TextStyle(fontSize: 12, height: 1.5)),
            ),
          ],
        )),
      ])),
    );
  }
}
