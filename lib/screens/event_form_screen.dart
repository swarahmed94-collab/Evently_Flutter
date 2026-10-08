import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../core/feedback.dart';
import '../models/event_category.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../theme/evently_theme.dart';
import '../widgets/app_controls.dart';
import '../widgets/category_selector.dart';
import '../widgets/event_art.dart';

class EventFormScreen extends StatefulWidget {
  const EventFormScreen({super.key, this.event});
  final EventModel? event;

  @override
  State<EventFormScreen> createState() => _EventFormScreenState();
}

class _EventFormScreenState extends State<EventFormScreen> {
  final formKey = GlobalKey<FormState>();
  late final TextEditingController title;
  late final TextEditingController description;
  late EventCategory category;
  DateTime? chosenDate;
  TimeOfDay? chosenTime;
  bool busy = false;

  @override
  void initState() {
    super.initState();
    final existing = widget.event;
    title = TextEditingController(text: existing?.title ?? '');
    description = TextEditingController(text: existing?.description ?? '');
    category = existing?.category ?? EventCategory.bookClub;
    chosenDate = existing?.dateTime;
    chosenTime = existing == null ? null : TimeOfDay.fromDateTime(existing.dateTime);
  }

  @override
  void dispose() {
    title.dispose();
    description.dispose();
    super.dispose();
  }

  Future<void> pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: chosenDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) setState(() => chosenDate = date);
  }

  Future<void> pickTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: chosenTime ?? TimeOfDay.now(),
    );
    if (time != null && mounted) setState(() => chosenTime = time);
  }

  Future<void> submit() async {
    if (busy || formKey.currentState?.validate() != true) return;
    if (chosenDate == null || chosenTime == null) {
      showError(context, StateError('Choose an event date and time.'));
      return;
    }
    final user = AuthService.instance.user;
    if (user == null) {
      showError(context, StateError('Please log in again.'));
      return;
    }
    final dateTime = DateTime(chosenDate!.year, chosenDate!.month,
        chosenDate!.day, chosenTime!.hour, chosenTime!.minute);
    setState(() => busy = true);
    try {
      final previous = widget.event;
      if (previous == null) {
        await EventService.instance.add(
          userId: user.uid,
          title: title.text,
          description: description.text,
          category: category,
          dateTime: dateTime,
        );
      } else {
        await EventService.instance.update(previous,
          userId: user.uid,
          title: title.text,
          description: description.text,
          category: category,
          dateTime: dateTime,
        );
      }
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) showError(context, e);
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final editing = widget.event != null;
    return Scaffold(
      body: SafeArea(child: Column(children: [
        ScreenTitle(title: editing ? 'Edit event' : 'Add event'),
        Expanded(child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.only(bottom: 24),
          child: Form(key: formKey, child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(padding: const EdgeInsets.symmetric(horizontal: 16),
                child: EventArt(category: category)),
              const SizedBox(height: 13),
              CategorySelector(selected: category,
                  onSelected: (v) { if (v != null) setState(() => category = v); }),
              const SizedBox(height: 13),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Title', style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600)),
                  const SizedBox(height: 7),
                  EventlyTextField(controller: title, hint: 'Event Title',
                    validator: (v) => v?.trim().isNotEmpty == true
                        ? null : 'Enter an event title'),
                  const SizedBox(height: 12),
                  const Text('Description', style: TextStyle(fontSize: 13,
                      fontWeight: FontWeight.w600)),
                  const SizedBox(height: 7),
                  EventlyTextField(controller: description,
                    hint: 'Event Description...', maxLines: 6,
                    validator: (v) => v?.trim().isNotEmpty == true
                        ? null : 'Enter an event description'),
                  const SizedBox(height: 12),
                  _PickerRow(icon: Icons.event_available_outlined,
                    label: 'Event Date',
                    value: chosenDate == null ? 'Choose date'
                        : DateFormat('MMM d, yyyy').format(chosenDate!),
                    onTap: pickDate),
                  _PickerRow(icon: Icons.access_time_outlined,
                    label: 'Event Time',
                    value: chosenTime?.format(context) ?? 'Choose time',
                    onTap: pickTime),
                ]),
              ),
            ],
          )),
        )),
      ])),
      bottomNavigationBar: SafeArea(top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
          child: EventlyActionButton(
            label: editing ? 'Update event' : 'Add event',
            loading: busy,
            onPressed: submit,
          ),
        ),
      ),
    );
  }
}

class _PickerRow extends StatelessWidget {
  const _PickerRow({required this.icon, required this.label,
      required this.value, required this.onTap});
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => SizedBox(height: 39,
    child: Row(children: [
      Icon(icon, size: 21, color: EventlyColors.primary(context)),
      const SizedBox(width: 7),
      Expanded(child: Text(label, style: const TextStyle(
        fontWeight: FontWeight.w500, fontSize: 13))),
      TextButton(onPressed: onTap,
        child: Text(value, style: const TextStyle(
          fontSize: 12, decoration: TextDecoration.underline))),
    ]),
  );
}
