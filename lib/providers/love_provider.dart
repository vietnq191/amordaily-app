import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'package:amordaily/utils/app_localizations.dart';

class Milestone {
  String title;
  DateTime date;

  Milestone({required this.title, required this.date});

  Map<String, dynamic> toJson() => {
    'title': title,
    'date': date.toIso8601String(),
  };

  factory Milestone.fromJson(Map<String, dynamic> json) =>
      Milestone(title: json['title'], date: DateTime.parse(json['date']));
}

class LoveStory {
  String partner1Name;
  String partner2Name;
  DateTime? partner1BirthDate;
  DateTime? partner2BirthDate;
  DateTime startDate;
  String? partner1ImagePath;
  String? partner2ImagePath;
  bool showAge;
  bool showZodiac;
  bool showQuotes;
  String language;
  List<Milestone> customMilestones;

  LoveStory({
    String? partner1Name,
    String? partner2Name,
    this.partner1BirthDate,
    this.partner2BirthDate,
    required this.startDate,
    this.partner1ImagePath,
    this.partner2ImagePath,
    this.showAge = true,
    this.showZodiac = true,
    this.showQuotes = true,
    this.language = 'en',
    List<Milestone>? customMilestones,
  }) : partner1Name = partner1Name ?? (language == 'vi' ? 'Bạn' : 'You'),
       partner2Name =
           partner2Name ?? (language == 'vi' ? 'Người ấy' : 'Partner'),
       customMilestones = customMilestones ?? [];

  Map<String, dynamic> toJson() => {
    'partner1Name': partner1Name,
    'partner2Name': partner2Name,
    'partner1BirthDate': partner1BirthDate?.toIso8601String(),
    'partner2BirthDate': partner2BirthDate?.toIso8601String(),
    'startDate': startDate.toIso8601String(),
    'partner1ImagePath': partner1ImagePath,
    'partner2ImagePath': partner2ImagePath,
    'showAge': showAge,
    'showZodiac': showZodiac,
    'showQuotes': showQuotes,
    'language': language,
    'customMilestones': customMilestones.map((m) => m.toJson()).toList(),
  };

  factory LoveStory.fromJson(Map<String, dynamic> json) {
    final milestonesJson = json['customMilestones'] as List? ?? [];
    return LoveStory(
      partner1Name:
          json['partner1Name'] ?? (json['language'] == 'vi' ? 'Bạn' : 'You'),
      partner2Name:
          json['partner2Name'] ??
          (json['language'] == 'vi' ? 'Người ấy' : 'Partner'),
      partner1BirthDate: json['partner1BirthDate'] != null
          ? DateTime.parse(json['partner1BirthDate'])
          : null,
      partner2BirthDate: json['partner2BirthDate'] != null
          ? DateTime.parse(json['partner2BirthDate'])
          : null,
      startDate: DateTime.parse(
        json['startDate'] ?? DateTime.now().toIso8601String(),
      ),
      partner1ImagePath: json['partner1ImagePath'],
      partner2ImagePath: json['partner2ImagePath'],
      showAge: json['showAge'] ?? true,
      showZodiac: json['showZodiac'] ?? true,
      showQuotes: json['showQuotes'] ?? true,
      language: json['language'] ?? 'en',
      customMilestones: milestonesJson
          .map((m) => Milestone.fromJson(m as Map<String, dynamic>))
          .toList(),
    );
  }
}

class LoveProvider with ChangeNotifier {
  LoveStory _story = LoveStory(startDate: DateTime.now());
  bool _isLoading = true;

  LoveStory get story => _story;
  bool get isLoading => _isLoading;
  AppLocalizations get loc => AppLocalizations(_story.language);

  LoveProvider() {
    loadData();
  }

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getString('love_story');
    if (data != null) {
      _story = LoveStory.fromJson(jsonDecode(data) as Map<String, dynamic>);
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('love_story', jsonEncode(_story.toJson()));
  }

  void updateStory(LoveStory newStory) {
    _story = newStory;
    saveData();
    notifyListeners();
  }

  void addMilestone(String title, DateTime date) {
    _story.customMilestones.add(Milestone(title: title, date: date));
    saveData();
    notifyListeners();
  }

  void removeMilestone(int index) {
    _story.customMilestones.removeAt(index);
    saveData();
    notifyListeners();
  }

  void updateMilestone(int index, String title, DateTime date) {
    _story.customMilestones[index] = Milestone(title: title, date: date);
    saveData();
    notifyListeners();
  }

  int get daysTogether {
    return DateTime.now().difference(_story.startDate).inDays;
  }

  String getZodiacSign(DateTime? birthDate, {String? lang}) {
    if (birthDate == null) return '';
    final int day = birthDate.day;
    final int month = birthDate.month;
    final code = lang ?? _story.language;

    final Map<String, List<String>> zodiacNames = {
      'vi': [
        'Bảo Bình',
        'Song Ngư',
        'Bạch Dương',
        'Kim Ngưu',
        'Song Tử',
        'Cự Giải',
        'Sư Tử',
        'Xử Nữ',
        'Thiên Bình',
        'Bọ Cạp',
        'Nhân Mã',
        'Ma Kết',
      ],
      'en': [
        'Aquarius',
        'Pisces',
        'Aries',
        'Taurus',
        'Gemini',
        'Cancer',
        'Leo',
        'Virgo',
        'Libra',
        'Scorpio',
        'Sagittarius',
        'Capricorn',
      ],
      'ja': [
        '水瓶座',
        '魚座',
        '牡羊座',
        '牡牛座',
        '双子座',
        '蟹座',
        '獅子座',
        '乙女座',
        '天秤座',
        '蠍座',
        '射手座',
        '山羊座',
      ],
      'ko': [
        '물병자리',
        '물고기자리',
        '양자리',
        '황소자리',
        '쌍둥이자리',
        '게자리',
        '사자자리',
        '처녀자리',
        '천칭자리',
        '전갈자리',
        '사수자리',
        '염소자리',
      ],
      'zh': [
        '水瓶座',
        '双鱼座',
        '白羊座',
        '金牛座',
        '双子座',
        '巨蟹座',
        '狮子座',
        '处女座',
        '天秤座',
        '天蝎座',
        '射手座',
        '摩羯座',
      ],
      'ru': [
        'Водолей',
        'Рыбы',
        'Овен',
        'Телец',
        'Близнецы',
        'Рак',
        'Лев',
        'Дева',
        'Весы',
        'Скорпион',
        'Стрелец',
        'Козерог',
      ],
    };

    final names = zodiacNames[code] ?? zodiacNames['vi']!;
    final emojis = ['♒', '♓', '♈', '♉', '♊', '♋', '♌', '♍', '♎', '♏', '♐', '♑'];

    int idx;
    if ((month == 1 && day >= 20) || (month == 2 && day <= 18)) {
      idx = 0;
    } else if ((month == 2 && day >= 19) || (month == 3 && day <= 20)) {
      idx = 1;
    } else if ((month == 3 && day >= 21) || (month == 4 && day <= 19)) {
      idx = 2;
    } else if ((month == 4 && day >= 20) || (month == 5 && day <= 20)) {
      idx = 3;
    } else if ((month == 5 && day >= 21) || (month == 6 && day <= 20)) {
      idx = 4;
    } else if ((month == 6 && day >= 21) || (month == 7 && day <= 22)) {
      idx = 5;
    } else if ((month == 7 && day >= 23) || (month == 8 && day <= 22)) {
      idx = 6;
    } else if ((month == 8 && day >= 23) || (month == 9 && day <= 22)) {
      idx = 7;
    } else if ((month == 9 && day >= 23) || (month == 10 && day <= 22)) {
      idx = 8;
    } else if ((month == 10 && day >= 23) || (month == 11 && day <= 21)) {
      idx = 9;
    } else if ((month == 11 && day >= 22) || (month == 12 && day <= 21)) {
      idx = 10;
    } else {
      idx = 11;
    }

    return '${emojis[idx]} ${names[idx]}';
  }

  int getAge(DateTime? birthDate) {
    if (birthDate == null) return 0;
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  List<Map<String, dynamic>> getFilteredMilestones({
    bool includeAllCustom = false,
  }) {
    final now = DateTime.now();
    final List<Map<String, dynamic>> all = [];
    final start = _story.startDate;

    /* 1. Default Yearly Milestones (Only next 3) */
    int yearlyCount = 0;
    for (int i = 1; i <= 50; i++) {
      final d = DateTime(start.year + i, start.month, start.day);
      if (d.isAfter(now)) {
        all.add({
          'title': '$i ${loc.t('years_together')}',
          'date': d,
          'isDefault': true,
        });
        yearlyCount++;
        if (yearlyCount >= 3) break;
      }
    }

    /* 2. Custom Milestones */
    for (int i = 0; i < _story.customMilestones.length; i++) {
      final m = _story.customMilestones[i];
      final diff = m.date.difference(now).inDays;
      if (includeAllCustom || (diff > 0 && diff <= 60)) {
        all.add({
          'title': m.title,
          'date': m.date,
          'isDefault': false,
          'customIndex': i,
        });
      }
    }

    /* 3. Birthdays (Always show if within 60 days) */
    if (_story.partner1BirthDate != null) {
      DateTime bd1 = DateTime(
        now.year,
        _story.partner1BirthDate!.month,
        _story.partner1BirthDate!.day,
      );
      if (bd1.isBefore(now)) bd1 = DateTime(now.year + 1, bd1.month, bd1.day);
      if (includeAllCustom || bd1.difference(now).inDays <= 60) {
        all.add({
          'title': loc.t('your_birthday_event'),
          'date': bd1,
          'isDefault': false,
        });
      }
    }
    if (_story.partner2BirthDate != null) {
      DateTime bd2 = DateTime(
        now.year,
        _story.partner2BirthDate!.month,
        _story.partner2BirthDate!.day,
      );
      if (bd2.isBefore(now)) bd2 = DateTime(now.year + 1, bd2.month, bd2.day);
      if (includeAllCustom || bd2.difference(now).inDays <= 60) {
        all.add({
          'title': loc.t('partner_birthday_event'),
          'date': bd2,
          'isDefault': false,
        });
      }
    }

    all.sort(
      (a, b) => (a['date'] as DateTime).compareTo(b['date'] as DateTime),
    );
    return all;
  }
}
