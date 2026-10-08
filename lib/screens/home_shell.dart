import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../core/app_settings.dart';
import '../core/feedback.dart';
import '../models/event_category.dart';
import '../models/event_model.dart';
import '../services/auth_service.dart';
import '../services/event_service.dart';
import '../theme/evently_theme.dart';
import '../widgets/app_controls.dart';
import '../widgets/category_selector.dart';
import '../widgets/event_card.dart';
import '../widgets/evently_tab_icon.dart';
import 'event_details_screen.dart';
import 'event_form_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});
  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int tab = 0;
  EventCategory? category;
  final search = TextEditingController();

  @override
  void initState() {
    super.initState();
    search.addListener(_refresh);
  }

  void _refresh() { if (mounted) setState(() {}); }

  @override
  void dispose() {
    search.removeListener(_refresh);
    search.dispose();
    super.dispose();
  }

  void addEvent() => Navigator.of(context).push(MaterialPageRoute<void>(
      builder: (_) => const EventFormScreen()));

  @override
  Widget build(BuildContext context) {
    final user = AuthService.instance.user;
    if (user == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    final dark = EventlyColors.isDark(context);
    final primary = EventlyColors.primary(context);
    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: tab == 2
          ? _ProfileTab(user: user)
          : Column(children: [
              if (tab == 0) ...[
                Padding(padding: const EdgeInsets.fromLTRB(16, 26, 16, 22),
                  child: Row(children: [
                    Expanded(child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Welcome Back ✨', style: TextStyle(fontSize: 13,
                            color: EventlyColors.secondaryText(context))),
                        const SizedBox(height: 5),
                        Text((user.displayName?.trim().isNotEmpty ?? false)
                            ? user.displayName! : user.email?.split('@').first ?? 'Evently',
                          style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 19)),
                      ],
                    )),
                    IconButton(
                      onPressed: () => AppSettings.instance.setDark(!dark),
                      tooltip: 'Change theme',
                      icon: Icon(dark ? Icons.dark_mode_outlined : Icons.wb_sunny_outlined,
                          size: 24, color: primary),
                    ),
                    Material(
                      color: primary,
                      borderRadius: BorderRadius.circular(9),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(9),
                        onTap: () => AppSettings.instance.setLanguage(
                          AppSettings.instance.language == 'en' ? 'ar' : 'en'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                          child: Text(AppSettings.instance.language.toUpperCase(),
                              style: const TextStyle(color: Colors.white, fontSize: 12,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                    ),
                  ]),
                ),
                CategorySelector(showAll: true, selected: category,
                    onSelected: (v) => setState(() => category = v)),
                const SizedBox(height: 23),
              ] else ...[
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 13),
                  child: TextField(
                    controller: search,
                    textInputAction: TextInputAction.search,
                    decoration: InputDecoration(
                      hintText: 'Search for event',
                      suffixIcon: Icon(Icons.search_rounded, color: primary, size: 23),
                    ),
                  ),
                ),
              ],
              Expanded(child: _EventFeed(
                userId: user.uid,
                category: tab == 0 ? category : null,
                onlyFavorites: tab == 1,
                searchQuery: tab == 1 ? search.text : '',
                onAdd: addEvent,
              )),
            ]),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: FloatingActionButton.small(
        onPressed: addEvent,
        tooltip: 'Add event',
        elevation: 5,
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: const CircleBorder(),
        child: const Icon(Icons.add, size: 24),
      ),
      bottomNavigationBar: SafeArea(top: false,
        child: Container(
          decoration: BoxDecoration(
            color: dark ? EventlyColors.navy : Colors.white,
            borderRadius: dark ? BorderRadius.zero : const BorderRadius.vertical(top: Radius.circular(19)),
            border: dark ? null : const Border(top: BorderSide(color: EventlyColors.lightOutline, width: .5)),
          ),
          child: BottomNavigationBar(
            currentIndex: tab,
            onTap: (i) => setState(() => tab = i),
            items: const [
              BottomNavigationBarItem(
                icon: EventlyTabIcon(glyph: EventlyTabGlyph.home),
                activeIcon: EventlyTabIcon(glyph: EventlyTabGlyph.home, filled: true), label: 'Home'),
              BottomNavigationBarItem(
                icon: EventlyTabIcon(glyph: EventlyTabGlyph.favorite),
                activeIcon: EventlyTabIcon(glyph: EventlyTabGlyph.favorite, filled: true), label: 'Favorite'),
              BottomNavigationBarItem(
                icon: EventlyTabIcon(glyph: EventlyTabGlyph.profile),
                activeIcon: EventlyTabIcon(glyph: EventlyTabGlyph.profile, filled: true), label: 'profile'),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventFeed extends StatefulWidget {
  const _EventFeed({required this.userId, required this.category,
    required this.onlyFavorites, required this.searchQuery, required this.onAdd});
  final String userId;
  final EventCategory? category;
  final bool onlyFavorites;
  final String searchQuery;
  final VoidCallback onAdd;

  @override
  State<_EventFeed> createState() => _EventFeedState();
}

class _EventFeedState extends State<_EventFeed> {
  late Stream<List<EventModel>> eventsStream;
  late Stream<Set<String>> favoriteStream;
  @override
  void initState() {
    super.initState();
    eventsStream = EventService.instance.watchEvents(category: widget.category);
    favoriteStream = EventService.instance.watchFavoriteIds(widget.userId);
  }
  @override
  void didUpdateWidget(covariant _EventFeed oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.category != widget.category) {
      eventsStream = EventService.instance.watchEvents(category: widget.category);
    }
    if (oldWidget.userId != widget.userId) {
      favoriteStream = EventService.instance.watchFavoriteIds(widget.userId);
    }
  }

  @override
  Widget build(BuildContext context) => StreamBuilder<List<EventModel>>(
    stream: eventsStream,
    builder: (context, eventsSnapshot) {
      if (eventsSnapshot.hasError) {
        return EmptyEvents(message: 'Unable to load events. ${eventsSnapshot.error}');
      }
      if (!eventsSnapshot.hasData) {
        return const Center(child: CircularProgressIndicator());
      }
      return StreamBuilder<Set<String>>(
        stream: favoriteStream,
        builder: (context, favoritesSnapshot) {
          if (favoritesSnapshot.hasError) {
            return EmptyEvents(message: 'Unable to load favorites. ${favoritesSnapshot.error}');
          }
          if (!favoritesSnapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final favorites = favoritesSnapshot.data!;
          final needle = widget.searchQuery.trim().toLowerCase();
          final events = eventsSnapshot.data!.where((e) =>
            (!widget.onlyFavorites || favorites.contains(e.id)) &&
            (needle.isEmpty || e.title.toLowerCase().contains(needle))
          ).toList();
          if (events.isEmpty) {
            return EmptyEvents(
              message: widget.onlyFavorites ? 'No favorite events yet' :
                'No events yet. Create the first one!',
              action: widget.onlyFavorites ? null : widget.onAdd,
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return EventCard(
                key: ValueKey(event.id),
                event: event,
                isFavorite: favorites.contains(event.id),
                onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                  builder: (_) => EventDetailsScreen(eventId: event.id))),
                onFavoriteTap: () async {
                  try {
                    await EventService.instance.setFavorite(
                      userId: widget.userId, eventId: event.id,
                      favorite: !favorites.contains(event.id));
                  } catch (e) {
                    if (context.mounted) showError(context, e);
                  }
                },
              );
            },
          );
        },
      );
    },
  );
}

class _ProfileTab extends StatelessWidget {
  const _ProfileTab({required this.user});
  final User user;

  @override
  Widget build(BuildContext context) {
    final dark = EventlyColors.isDark(context);
    final primary = EventlyColors.primary(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Column(children: [
        CircleAvatar(radius: 52,
          backgroundColor: EventlyColors.deepBlue,
          child: const Text('ROUTE', style: TextStyle(color: Colors.white,
            fontWeight: FontWeight.w900, fontSize: 22, letterSpacing: -1))),
        const SizedBox(height: 10),
        Text((user.displayName?.isNotEmpty ?? false) ? user.displayName! : 'Evently User',
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
        const SizedBox(height: 3),
        Text(user.email ?? '', style: TextStyle(fontSize: 12,
            color: EventlyColors.secondaryText(context))),
        const SizedBox(height: 38),
        _ProfileItem(label: 'Dark mode', child: Switch.adaptive(
          value: dark, activeTrackColor: primary,
          onChanged: AppSettings.instance.setDark,
        )),
        const SizedBox(height: 14),
        _ProfileItem(label: 'Language', onTap: () async {
          final lang = await showModalBottomSheet<String>(
            context: context,
            builder: (ctx) => SafeArea(child: Column(mainAxisSize: MainAxisSize.min, children: [
              ListTile(title: const Text('English'), onTap: () => Navigator.pop(ctx, 'en')),
              ListTile(title: const Text('العربية'), onTap: () => Navigator.pop(ctx, 'ar')),
            ])),
          );
          if (lang != null) await AppSettings.instance.setLanguage(lang);
        }, child: Icon(Icons.chevron_right, color: primary)),
        const SizedBox(height: 14),
        _ProfileItem(label: 'Logout', onTap: () async {
          try {
            await AuthService.instance.logout();
          } catch (e) {
            if (context.mounted) showError(context, e);
          }
        }, child: const Icon(Icons.logout_outlined, color: EventlyColors.red)),
      ]),
    );
  }
}

class _ProfileItem extends StatelessWidget {
  const _ProfileItem({required this.label, required this.child, this.onTap});
  final String label;
  final Widget child;
  final VoidCallback? onTap;
  @override
  Widget build(BuildContext context) => Material(
    color: Theme.of(context).colorScheme.surface,
    borderRadius: BorderRadius.circular(13),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          border: Border.all(color: EventlyColors.outline(context)),
          borderRadius: BorderRadius.circular(13),
        ),
        child: Row(children: [
          Expanded(child: Text(label, style: const TextStyle(fontSize: 13,
              fontWeight: FontWeight.w500))),
          child,
        ]),
      ),
    ),
  );
}
