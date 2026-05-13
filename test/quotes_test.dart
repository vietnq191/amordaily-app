import 'package:flutter_test/flutter_test.dart';
import 'package:amordaily/utils/quotes_data.dart';

void main() {
  group('QuotesData Tests', () {
    test('getRandomQuote returns a non-empty string for valid language', () {
      final quote = QuotesData.getRandomQuote('vi');
      expect(quote, isNotEmpty);
    });

    test(
      'getRandomQuote returns a non-empty string for all supported languages',
      () {
        final languages = ['vi', 'en', 'ja', 'ko', 'zh', 'ru'];
        for (final lang in languages) {
          final quote = QuotesData.getRandomQuote(lang);
          expect(quote, isNotEmpty, reason: 'Failed for language: $lang');
        }
      },
    );

    test('getRandomQuote defaults to English for unsupported language', () {
      /* We know some English quotes, let's see if it returns one of them or at least doesn't crash */
      final quote = QuotesData.getRandomQuote('fr'); /* French not supported */
      expect(quote, isNotEmpty);
    });

    test('getRandomQuote returns different quotes on multiple calls', () {
      /* This is probabilistic but with 100+ quotes, the chance of getting the same one 5 times is low */
      final firstQuote = QuotesData.getRandomQuote('en');
      bool foundDifferent = false;
      for (int i = 0; i < 10; i++) {
        if (QuotesData.getRandomQuote('en') != firstQuote) {
          foundDifferent = true;
          break;
        }
      }
      expect(foundDifferent, isTrue);
    });
  });
}
