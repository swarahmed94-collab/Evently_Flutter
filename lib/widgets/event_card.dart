import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../models/event_category.dart';
import '../models/event_model.dart';
import '../theme/evently_theme.dart';

class EventCard extends StatelessWidget {
  const EventCard({super.key, required this.event, required this.isFavorite,
    required this.onFavoriteTap, required this.onTap});
  final EventModel event;
  final bool isFavorite;
  final VoidCallback onFavoriteTap;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final dark = EventlyColors.isDark(context);
    final primary = EventlyColors.primary(context);
    final surface = Theme.of(context).colorScheme.surface;
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        color: surface,
        borderRadius: BorderRadius.circular(15),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(15),
          child: Container(
            height: 193,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: EventlyColors.outline(context)),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(fit: StackFit.expand, children: [
                SvgPicture.asset(event.category.banner(dark),
                  fit: BoxFit.cover,
                  semanticsLabel: '${event.category.label} event illustration'),
                Positioned(top: 6, left: 7, child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 9),
                  decoration: BoxDecoration(
                    color: dark ? EventlyColors.navy : EventlyColors.lightBackground,
                    border: Border.all(color: EventlyColors.outline(context)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(DateFormat('dd MMM').format(event.dateTime),
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: primary)),
                )),
                Positioned(bottom: 6, left: 6, right: 6, child: Container(
                  constraints: const BoxConstraints(minHeight: 40),
                  decoration: BoxDecoration(
                    color: dark ? EventlyColors.navy : EventlyColors.lightBackground,
                    border: Border.all(color: EventlyColors.outline(context)),
                    borderRadius: BorderRadius.circular(9),
                  ),
                  child: Row(children: [
                    Expanded(child: Padding(
                      padding: const EdgeInsets.fromLTRB(8, 8, 2, 8),
                      child: Text(event.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
                    )),
                    IconButton(
                      onPressed: onFavoriteTap,
                      tooltip: isFavorite ? 'Remove from favorites' : 'Add to favorites',
                      icon: Icon(isFavorite ? Icons.favorite_rounded : Icons.favorite_border,
                        size: 23, color: primary),
                      visualDensity: VisualDensity.compact,
                      constraints: const BoxConstraints(minHeight: 38, minWidth: 38),
                      padding: EdgeInsets.zero,
                    ),
                  ]),
                )),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}
