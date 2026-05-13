import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:amordaily/providers/love_provider.dart';
import 'package:amordaily/utils/constants.dart';
import 'package:amordaily/utils/app_localizations.dart';
import 'package:intl/intl.dart';
import 'dart:io';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<LoveProvider>(
      builder: (context, loveProvider, _) {
        final story = loveProvider.story;
        final loc = loveProvider.loc;

        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: Text(loc.t('settings_title')),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(
                left: 16,
                right: 16,
                top: 16,
                bottom: 120,
              ),
              children: [
                _sectionTitle(loc.t('your_profile')),
                _card(
                  children: [
                    _editTile(
                      context,
                      title: loc.t('your_name'),
                      value: story.partner1Name,
                      onTap: () => _editName(context, loveProvider, true, loc),
                    ),
                    _divider(),
                    _dateTile(
                      context,
                      title: loc.t('your_birthday'),
                      date: story.partner1BirthDate,
                      onTap: () =>
                          _selectDate(context, loveProvider, true, true, loc),
                    ),
                    _divider(),
                    _imageTile(
                      title: loc.t('your_photo'),
                      path: story.partner1ImagePath,
                      onTap: () => _pickImage(context, loveProvider, true),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionTitle(loc.t('partner_profile')),
                _card(
                  children: [
                    _editTile(
                      context,
                      title: loc.t('partner_name'),
                      value: story.partner2Name,
                      onTap: () => _editName(context, loveProvider, false, loc),
                    ),
                    _divider(),
                    _dateTile(
                      context,
                      title: loc.t('partner_birthday'),
                      date: story.partner2BirthDate,
                      onTap: () =>
                          _selectDate(context, loveProvider, false, true, loc),
                    ),
                    _divider(),
                    _imageTile(
                      title: loc.t('partner_photo'),
                      path: story.partner2ImagePath,
                      onTap: () => _pickImage(context, loveProvider, false),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionTitle(loc.t('love_story')),
                _card(
                  children: [
                    _dateTile(
                      context,
                      title: loc.t('love_start_date'),
                      date: story.startDate,
                      onTap: () =>
                          _selectDate(context, loveProvider, false, false, loc),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionTitle(loc.t('display')),
                _card(
                  children: [
                    SwitchListTile(
                      title: Text(
                        loc.t('show_age'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: story.showAge,
                      onChanged: (val) {
                        story.showAge = val;
                        loveProvider.updateStory(story);
                      },
                      activeColor: AppColors.primary,
                    ),
                    _divider(),
                    SwitchListTile(
                      title: Text(
                        loc.t('show_zodiac'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: story.showZodiac,
                      onChanged: (val) {
                        story.showZodiac = val;
                        loveProvider.updateStory(story);
                      },
                      activeColor: AppColors.primary,
                    ),
                    _divider(),
                    SwitchListTile(
                      title: Text(
                        loc.t('show_quotes'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      value: story.showQuotes,
                      onChanged: (val) {
                        story.showQuotes = val;
                        loveProvider.updateStory(story);
                      },
                      activeColor: AppColors.primary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionTitle(loc.t('language')),
                _card(
                  children: [
                    ListTile(
                      title: Text(
                        AppLocalizations.languageNames[story.language] ??
                            story.language,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      trailing: const Icon(
                        Icons.language_rounded,
                        color: AppColors.primary,
                      ),
                      onTap: () =>
                          _showLanguageSelectDialog(context, loveProvider, loc),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _sectionTitle(loc.t('app_info')),
                _card(
                  children: [
                    ListTile(
                      leading: const Icon(
                        Icons.person_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        loc.t('copyright'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      subtitle: const Text(
                        'vietnq191',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    _divider(),
                    ListTile(
                      leading: const Icon(
                        Icons.email_rounded,
                        color: AppColors.primary,
                      ),
                      title: Text(
                        loc.t('support'),
                        style: const TextStyle(color: Colors.white70),
                      ),
                      subtitle: const Text(
                        'vietnq191@gmail.com',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _sectionTitle(String title) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      title.toUpperCase(),
      style: const TextStyle(
        color: AppColors.primary,
        fontWeight: FontWeight.bold,
        fontSize: 11,
        letterSpacing: 1.4,
      ),
    ),
  );

  Widget _card({required List<Widget> children}) => Container(
    decoration: BoxDecoration(
      color: AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.white.withValues(alpha: 0.07)),
    ),
    child: Column(children: children),
  );

  Widget _divider() => Divider(
    height: 1,
    color: Colors.white.withValues(alpha: 0.07),
    indent: 16,
    endIndent: 16,
  );

  Widget _editTile(
    BuildContext context, {
    required String title,
    required String value,
    required VoidCallback onTap,
  }) => ListTile(
    title: Text(
      title,
      style: const TextStyle(color: Colors.white70, fontSize: 13),
    ),
    subtitle: Text(
      value,
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
    trailing: const Icon(Icons.chevron_right, color: Colors.white30),
    onTap: onTap,
  );

  Widget _dateTile(
    BuildContext context, {
    required String title,
    required dynamic date,
    required VoidCallback onTap,
  }) {
    final story = Provider.of<LoveProvider>(context, listen: false).story;
    String sub;
    if (date == null) {
      sub = '—';
    } else {
      sub = AppLocalizations.formatDate(date as DateTime, story.language);
    }
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white70, fontSize: 13),
      ),
      subtitle: Text(
        sub,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: const Icon(
        Icons.calendar_today_rounded,
        color: Colors.white30,
        size: 18,
      ),
      onTap: onTap,
    );
  }

  Widget _imageTile({
    required String title,
    String? path,
    required VoidCallback onTap,
  }) => ListTile(
    title: Text(
      title,
      style: const TextStyle(color: Colors.white70, fontSize: 13),
    ),
    trailing: path != null
        ? CircleAvatar(backgroundImage: FileImage(File(path)), radius: 22)
        : const Icon(Icons.add_a_photo_rounded, color: Colors.white30),
    onTap: onTap,
  );

  Future<void> _editName(
    BuildContext context,
    LoveProvider provider,
    bool isP1,
    AppLocalizations loc,
  ) async {
    final ctrl = TextEditingController(
      text: isP1 ? provider.story.partner1Name : provider.story.partner2Name,
    );
    await showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          isP1 ? loc.t('your_name') : loc.t('partner_name'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          autofocus: true,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(15),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.t('cancel'),
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              final story = provider.story;
              if (isP1) {
                story.partner1Name = ctrl.text;
              } else {
                story.partner2Name = ctrl.text;
              }
              provider.updateStory(story);
              Navigator.pop(ctx);
            },
            child: Text(
              loc.t('save'),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(
    BuildContext context,
    LoveProvider provider,
    bool isP1,
    bool isBirthDate,
    AppLocalizations loc,
  ) async {
    final initial = isBirthDate
        ? (isP1
                  ? provider.story.partner1BirthDate
                  : provider.story.partner2BirthDate) ??
              DateTime(2000)
        : provider.story.startDate;

    final picked = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppColors.primary,
              onPrimary: Colors.white,
              surface: Color(0xFF1E1E2E),
              onSurface: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      final story = provider.story;
      if (isBirthDate) {
        if (isP1) {
          story.partner1BirthDate = picked;
        } else {
          story.partner2BirthDate = picked;
        }
      } else {
        story.startDate = picked;
      }
      provider.updateStory(story);
    }
  }

  Future<void> _pickImage(
    BuildContext context,
    LoveProvider provider,
    bool isP1,
  ) async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (image != null) {
      if (!context.mounted) return;
      final story = provider.story;
      if (isP1) {
        story.partner1ImagePath = image.path;
      } else {
        story.partner2ImagePath = image.path;
      }
      provider.updateStory(story);
    }
  }

  Future<void> _showLanguageSelectDialog(
    BuildContext context,
    LoveProvider provider,
    AppLocalizations loc,
  ) async {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Text(
          loc.t('language'),
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView(
            shrinkWrap: true,
            children: AppLocalizations.supportedCodes.map((code) {
              final isSelected = provider.story.language == code;
              return ListTile(
                title: Text(
                  AppLocalizations.languageNames[code] ?? code,
                  style: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.white,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(
                        Icons.check_circle_rounded,
                        color: AppColors.primary,
                      )
                    : null,
                onTap: () {
                  final story = provider.story;
                  story.language = code;
                  provider.updateStory(story);
                  Navigator.pop(ctx);
                },
              );
            }).toList(),
          ),
        ),
        actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              loc.t('cancel'),
              style: const TextStyle(
                color: Colors.white54,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
