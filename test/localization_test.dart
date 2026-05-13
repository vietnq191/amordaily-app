import 'package:flutter_test/flutter_test.dart';
import 'package:amordaily/utils/app_localizations.dart';

void main() {
  group('Localization Consistency Tests', () {
    /* Accessing private _strings is tricky in Dart without reflection, 
       but we can test the t() method for all keys. */

    final List<String> languages = AppLocalizations.supportedCodes;
    
    /* List of all known keys based on the Vietnamese source */
    final List<String> expectedKeys = [
      'app_name', 'tab_home', 'tab_anniversary', 'tab_settings',
      'days_together', 'our_love_story', 'upcoming_anniversary',
      'months_left', 'days_left', 'days_unit', 'years', 'months', 'days',
      'settings_title', 'your_profile', 'partner_profile', 'your_name',
      'partner_name', 'your_birthday', 'partner_birthday', 'your_photo',
      'partner_photo', 'love_story', 'love_start_date', 'display',
      'show_age', 'show_zodiac', 'language', 'app_info', 'copyright',
      'support', 'cancel', 'save', 'delete', 'add', 'anniversary_title',
      'add_anniversary', 'anniversary_name_hint', 'select_date',
      'delete_anniversary', 'passed', 'not_set', 'age', 'years_together',
      'months_together', 'days_together_milestone', 'since', 'show_quotes',
      'quote_1', 'quote_2', 'quote_3', 'quote_4', 'quote_5',
      'partner_birthday_event', 'your_birthday_event'
    ];

    for (final lang in languages) {
      test('Language [$lang] should have all expected keys', () {
        final loc = AppLocalizations(lang);
        for (final key in expectedKeys) {
          final translated = loc.t(key);
          
          /* For Vietnamese (source language), we expect it to be different from the key.
             For other languages, it must at least not be empty. */
          expect(translated, isNotEmpty, reason: 'Key [$key] is empty in language [$lang]');
          
          /* Check if it falls back to the key itself (except for English where keys are often the translation) */
          if (lang != 'en' && lang != 'vi') {
             /* In other languages, if translation is identical to the key, it likely means missing translation */
             /* However, some special terms like 'Amordaily' (app_name) are the same across all languages */
             if (key != 'app_name') {
               expect(translated, isNot(equals(key)), reason: 'Key [$key] might not be translated in [$lang]');
             }
          }
        }
      });
    }
  });
}
