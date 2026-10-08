import 'package:flutter/material.dart';
import '../models/event_category.dart';
import '../theme/evently_theme.dart';
import 'evently_category_icon.dart';

class CategorySelector extends StatelessWidget {
  const CategorySelector({
    super.key,
    required this.selected,
    required this.onSelected,
    this.showAll = false,
  });

  final EventCategory? selected;
  final ValueChanged<EventCategory?> onSelected;
  final bool showAll;

  @override
  Widget build(BuildContext context) {
    final dark = EventlyColors.isDark(context);
    final primary = EventlyColors.primary(context);
    final items = <EventCategory?>[if (showAll) null, ...EventCategory.values];
    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: items.length,
        separatorBuilder: (context, index) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final category = items[index];
          final active = selected == category;
          return Semantics(
            button: true,
            selected: active,
            child: Material(
              color: active ? primary : (dark ? EventlyColors.navy : Colors.white),
              shape: StadiumBorder(side: BorderSide(
                color: active ? primary : (dark ? EventlyColors.borderBlue : EventlyColors.lightOutline),
              )),
              child: InkWell(
                customBorder: const StadiumBorder(),
                onTap: () => onSelected(category),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    EventlyCategoryIcon(
                      category: category, color: active ? Colors.white : primary, size: 20),
                    const SizedBox(width: 7),
                    Text(category?.label ?? 'All', style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w500,
                      color: active ? Colors.white : Theme.of(context).colorScheme.onSurface,
                    )),
                  ]),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
