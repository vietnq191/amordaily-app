import 'package:flutter_test/flutter_test.dart';
import 'package:amordaily/providers/love_provider.dart';

void main() {
  group('LoveStory Model Tests', () {
    test('toJson and fromJson should be symmetrical', () {
      final originalDate = DateTime(2022, 5, 20, 10, 30);
      final milestoneDate = DateTime(2023, 1, 1);

      final originalStory = LoveStory(
        partner1Name: 'Viet',
        partner2Name: 'Ngan',
        startDate: originalDate,
        language: 'vi',
        customMilestones: [Milestone(title: 'First Trip', date: milestoneDate)],
        showAge: false,
      );

      final json = originalStory.toJson();
      final decodedStory = LoveStory.fromJson(json);

      expect(decodedStory.partner1Name, equals(originalStory.partner1Name));
      expect(decodedStory.partner2Name, equals(originalStory.partner2Name));
      expect(decodedStory.startDate, equals(originalStory.startDate));
      expect(decodedStory.language, equals(originalStory.language));
      expect(decodedStory.showAge, equals(originalStory.showAge));
      expect(decodedStory.customMilestones.length, equals(1));
      expect(decodedStory.customMilestones[0].title, equals('First Trip'));
      expect(decodedStory.customMilestones[0].date, equals(milestoneDate));
    });

    test('fromJson should handle missing fields with defaults', () {
      final json = {
        'startDate': DateTime.now().toIso8601String(),
        /* missing other fields */
      };

      final story = LoveStory.fromJson(json);

      expect(story.partner1Name, equals('You'));
      expect(story.partner2Name, equals('Partner'));
      expect(story.showAge, isTrue);
      expect(story.language, equals('en'));
    });
  });
}
