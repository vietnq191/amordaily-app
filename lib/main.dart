import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:amordaily/providers/love_provider.dart';
import 'package:amordaily/screens/home_screen.dart';
import 'package:amordaily/screens/settings_screen.dart';
import 'package:amordaily/screens/anniversary_screen.dart';
import 'package:amordaily/utils/constants.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:amordaily/widgets/particle_background.dart';
import 'package:amordaily/widgets/custom_bottom_nav.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:amordaily/utils/app_localizations.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => LoveProvider(),
      child: const AmorDailyApp(),
    ),
  );
}

class AmorDailyApp extends StatelessWidget {
  const AmorDailyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final loveProvider = Provider.of<LoveProvider>(context);
    return MaterialApp(
      title: 'Amordaily',
      debugShowCheckedModeBanner: false,
      locale: Locale(loveProvider.story.language),
      supportedLocales: AppLocalizations.supportedCodes
          .map((code) => Locale(code))
          .toList(),
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      theme: AppThemes.darkTheme.copyWith(
        textTheme: GoogleFonts.montserratTextTheme(ThemeData.dark().textTheme),
      ),
      home: const MainNavigation(),
    );
  }
}

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _selectedIndex = 0;
  late PageController _pageController;
  DateTime? _lastQuitTime;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: _selectedIndex);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = Provider.of<LoveProvider>(context).loc;
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        final now = DateTime.now();
        if (_lastQuitTime == null ||
            now.difference(_lastQuitTime!) > const Duration(seconds: 2)) {
          _lastQuitTime = now;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Nhấn lần nữa để thoát'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
        exit(0);
      },
      child: Scaffold(
        extendBody: true,
        body: ParticleBackground(
          child: Stack(
            children: [
              PageView(
                controller: _pageController,
                onPageChanged: (index) =>
                    setState(() => _selectedIndex = index),
                children: const [
                  HomeScreen(),
                  AnniversaryScreen(),
                  SettingsScreen(),
                ],
              ),
              CustomBottomNav(
                currentIndex: _selectedIndex,
                onTap: (index) {
                  setState(() => _selectedIndex = index);
                  _pageController.animateToPage(
                    index,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeInOutCubic,
                  );
                },
                loc: loc,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
