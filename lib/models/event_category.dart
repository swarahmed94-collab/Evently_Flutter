import 'package:flutter/material.dart';

// Banner artwork is the supplied category-specific SVG, not a screen capture.
enum EventCategory { bookClub, sport, birthday, meeting, exhibition }

extension EventCategoryX on EventCategory {
  String get label => switch (this) {
    EventCategory.bookClub => 'Book club',
    EventCategory.sport => 'Sport',
    EventCategory.birthday => 'Birthday',
    EventCategory.meeting => 'Meeting',
    EventCategory.exhibition => 'Exhibition',
  };
  String get key => switch (this) {
    EventCategory.bookClub => 'book_club',
    EventCategory.sport => 'sport',
    EventCategory.birthday => 'birthday',
    EventCategory.meeting => 'meeting',
    EventCategory.exhibition => 'exhibition',
  };
  IconData get icon => switch (this) {
    EventCategory.bookClub => Icons.menu_book_outlined,
    EventCategory.sport => Icons.directions_bike_outlined,
    EventCategory.birthday => Icons.cake_outlined,
    EventCategory.meeting => Icons.groups_outlined,
    EventCategory.exhibition => Icons.museum_outlined,
  };
  String banner(bool dark) => 'assets/event_art/${key}_${dark ? 'dark' : 'light'}.svg';
  static EventCategory fromKey(String? value) => EventCategory.values.firstWhere((c) => c.key == value, orElse: () => EventCategory.birthday);
}
