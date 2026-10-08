import 'package:flutter_test/flutter_test.dart';
import 'package:evently/models/event_category.dart';

void main() {
  test('category keys round trip', () {
    for (final category in EventCategory.values) {
      expect(EventCategoryX.fromKey(category.key), category);
      expect(category.banner(true), contains('_dark.svg'));
      expect(category.banner(false), contains('_light.svg'));
    }
  });
}
