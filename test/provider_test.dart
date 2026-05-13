import 'package:flutter_test/flutter_test.dart';
import 'package:amordaily/providers/love_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  /* Mock SharedPreferences */
  TestWidgetsFlutterBinding.ensureInitialized();

  group('LoveProvider Functionality Tests', () {
    late LoveProvider provider;

    setUp(() async {
      SharedPreferences.setMockInitialValues({});
      provider = LoveProvider();
      /* Wait for initial loadData */
      await Future.delayed(Duration.zero);
    });

    test('Initial state should have default names', () {
      expect(provider.story.partner1Name, equals('You'));
      expect(provider.story.partner2Name, equals('Partner'));
    });

    test('Update story should change names and save', () {
      final newStory = LoveStory(
        partner1Name: 'Anh',
        partner2Name: 'Em',
        startDate: DateTime(2023, 1, 1),
      );
      provider.updateStory(newStory);
      expect(provider.story.partner1Name, equals('Anh'));
      expect(provider.story.partner2Name, equals('Em'));
    });

    test('Add milestone should increase customMilestones list', () {
      final initialCount = provider.story.customMilestones.length;
      provider.addMilestone('Kỷ niệm 1', DateTime.now());
      expect(provider.story.customMilestones.length, equals(initialCount + 1));
      expect(provider.story.customMilestones.last.title, equals('Kỷ niệm 1'));
    });

    test('Remove milestone should decrease customMilestones list', () {
      provider.addMilestone('Kỷ niệm 1', DateTime.now());
      final countAfterAdd = provider.story.customMilestones.length;
      provider.removeMilestone(0);
      expect(provider.story.customMilestones.length, equals(countAfterAdd - 1));
    });

    test('Update milestone should change title and date', () {
      provider.addMilestone('Kỷ niệm 1', DateTime(2024, 1, 1));
      provider.updateMilestone(0, 'Kỷ niệm mới', DateTime(2025, 1, 1));
      expect(provider.story.customMilestones[0].title, equals('Kỷ niệm mới'));
      expect(provider.story.customMilestones[0].date, equals(DateTime(2025, 1, 1)));
    });

    test('daysTogether calculation', () {
      final startDate = DateTime.now().subtract(const Duration(days: 100));
      provider.updateStory(LoveStory(startDate: startDate));
      /* Should be 100 or 101 depending on time of day, but approximately 100 */
      expect(provider.daysTogether, closeTo(100, 1));
    });

    test('Zodiac calculation', () {
      /* Aries: March 21 – April 19 */
      final ariesDate = DateTime(1995, 3, 25);
      final zodiac = provider.getZodiacSign(ariesDate, lang: 'en');
      expect(zodiac, contains('Aries'));
    });
  });
}
